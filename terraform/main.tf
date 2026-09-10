# ==========================================
# 1. Data Sources - Default VPC, Subnet & AMI
# ==========================================
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}



# ==========================================
# 2. ECR Repository
# ==========================================
resource "aws_ecr_repository" "crm_repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

# ==========================================
# 3. IAM Role for EC2 to access ECR
# ==========================================
resource "aws_iam_role" "ecr_pull_role" {
  name = "${var.project_name}-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ecr_pull_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ecr_pull_profile" {
  name = "${var.project_name}-ecr-profile"
  role = aws_iam_role.ecr_pull_role.name
}

# ==========================================
# 4. SSH Key Pair
# ==========================================
resource "tls_private_key" "crm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "crm_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.crm_key.public_key_openssh
}

# Save the private key locally
resource "local_file" "pem_file" {
  content         = tls_private_key.crm_key.private_key_pem
  filename        = "${var.project_name}.pem"
  file_permission = "0400"
}

# ==========================================
# 5. Security Group
# ==========================================
resource "aws_security_group" "crm_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Twenty CRM"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port (3000)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port (2020)"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ==========================================
# 6. EC2 Instance with User Data (Includes Retry Loop)
# ==========================================
resource "aws_instance" "crm_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  # ... rest stays the same
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.crm_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ecr_pull_profile.name
  associate_public_ip_address = true
  key_name                    = aws_key_pair.crm_key.key_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

      user_data = <<-EOF
              #!/bin/bash
              set -x
              exec > /var/log/user-data.log 2>&1

              # 1. Add 4GB swap file
              if [ ! -f /swapfile ]; then
                fallocate -l 4G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                echo '/swapfile none swap sw 0 0' >> /etc/fstab
              fi

              # 2. Install Docker (Amazon Linux uses dnf)
              dnf update -y
              dnf install -y docker awscli git docker-compose
              systemctl enable docker && systemctl start docker

              # 3. Login to ECR
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.crm_repo.repository_url}

              # 4. Clone repo (harish-task5 branch)
              cd /opt
              git clone -b harish-task5 https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
              cd devops-crm-project

              # 5. Create .env (Note the $$ to escape bash variables from Terraform)
              APP_SECRET=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)
              cat << ENVFILE > .env
              PG_DATABASE_USER=postgres
              PG_DATABASE_PASSWORD=postgrespassword123
              PG_DATABASE_NAME=default
              APP_SECRET=$${APP_SECRET}
              TWENTY_PORT=3000
              SERVER_URL=http://localhost:3000
              TWENTY_VERSION=latest
              ENVFILE

              # 6. Replace 'build:' with the ECR image URL in docker-compose.yml
              sed -i "s|build:.*|image: ${aws_ecr_repository.crm_repo.repository_url}:latest|g" docker-compose.yml
              sed -i "/context:/d" docker-compose.yml
              sed -i "/dockerfile:/d" docker-compose.yml

              # 7. RETRY LOOP
              echo "Waiting for image to be available in ECR..."
              MAX_RETRIES=30
              RETRY_COUNT=0
              
              while [ $${RETRY_COUNT} -lt $${MAX_RETRIES} ]; do
                if docker pull ${aws_ecr_repository.crm_repo.repository_url}:latest; then
                  echo "Image pulled successfully!"
                  break
                else
                  echo "Image not yet available in ECR. Retrying in 10 seconds..."
                  sleep 10
                  RETRY_COUNT=$$((RETRY_COUNT+1))
                fi
              done

              if [ $${RETRY_COUNT} -eq $${MAX_RETRIES} ]; then
                echo "Failed to pull image after $${MAX_RETRIES} attempts."
                exit 1
              fi

              # 8. Start Docker Compose
              docker-compose up -d
              
              echo "Bootstrap completed at $$(date)."
              EOF

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2"
  })
}
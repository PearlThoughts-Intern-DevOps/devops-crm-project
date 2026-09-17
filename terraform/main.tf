# --- Data Sources ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- Security Group ---
resource "aws_security_group" "twenty_crm_sg" {
  name        = "twenty-crm-sg"
  description = "Allow SSH and Twenty CRM traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Amazon ECR ---
resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# --- IAM Role for EC2 to access ECR ---
resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-role-task12"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_ecr_profile" {
  name = "ec2-ecr-profile-task12"
  role = aws_iam_role.ec2_ecr_role.name
}

# --- EC2 Instance with User Data ---
resource "aws_instance" "twenty_crm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.twenty_crm_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ecr_profile.name

  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y docker.io awscli
              systemctl start docker
              usermod -aG docker ubuntu
              
              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Wait for ECR image
              for i in {1..30}; do
                if aws ecr describe-images --repository-name ${var.ecr_repo_name} --image-ids imageTag=latest --region ${var.aws_region} > /dev/null 2>&1; then
                  break
                fi
                sleep 10
              done
              
              # Login to ECR
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.twenty_crm.repository_url}
              
              # Create docker-compose.yml
              mkdir -p /home/ubuntu/twenty-crm
              cd /home/ubuntu/twenty-crm
              
              cat > docker-compose.yml << 'COMPOSEOF'
              version: "3.8"
              services:
                postgres:
                  image: twentycrm/twenty-postgres:latest
                  environment:
                    POSTGRES_USER: postgres
                    POSTGRES_PASSWORD: postgres
                    POSTGRES_DB: default
                  volumes:
                    - pgdata:/var/lib/postgresql/data
                  healthcheck:
                    test: ["CMD-SHELL", "pg_isready -U postgres"]
                    interval: 10s
                    timeout: 5s
                    retries: 5
                  
                redis:
                  image: redis:alpine
                  healthcheck:
                    test: ["CMD", "redis-cli", "ping"]
                    interval: 10s
                    timeout: 5s
                    retries: 5
                  
                server:
                  image: ${aws_ecr_repository.twenty_crm.repository_url}:latest
                  ports:
                    - "2020:3000"
                  environment:
                    SERVER_URL: http://localhost:2020
                    FRONTEND_URL: http://localhost:2020
                    PG_DATABASE_URL: postgres://postgres:postgres@postgres:5432/default
                    REDIS_URL: redis://redis:6379
                  depends_on:
                    postgres:
                      condition: service_healthy
                    redis:
                      condition: service_healthy
                  restart: unless-stopped
              
              volumes:
                pgdata:
              COMPOSEOF
              
              # Run docker-compose
              docker-compose up -d
              EOF

  tags = {
    Name = "Twenty-CRM"
  }
}

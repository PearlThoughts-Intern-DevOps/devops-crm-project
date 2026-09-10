# Task 12: Terraform + AWS Infrastructure

**Name:** Harish

**Task:** Terraform + AWS Infrastructure

**Date:** September 9, 2026

**PR Link** https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project/pull/285


# PROJECT OVERVIEW
----------------
Deployment of Twenty CRM application to AWS using Terraform and Docker.
Infrastructure is 100% AWS Free Tier eligible with automated EC2 User 
Data and ECR retry loop.


ARCHITECTURE & AWS RESOURCES
-----------------------------
- Compute: EC2 Instance (t3.small, Amazon Linux 2023)
- Storage: 20GB GP3 EBS Volume
- Container Registry: AWS ECR
- Networking: Default VPC, Public Subnet, Security Group (22, 3000)
- IAM: Custom IAM Role with ECR ReadOnly access


========================================================================
ISSUES ENCOUNTERED & SOLUTIONS (WITH COMMANDS)
========================================================================

ISSUE #1: Terraform "Invalid reference" Error
----------------------------------------------
Problem: Terraform was trying to interpolate bash variables like 
         $APP_SECRET and $RETRY_COUNT, causing validation errors.

Error Message:
  "A reference to a resource type must be followed by at least one 
   attribute access, specifying the resource name."

Solution Command:
  In main.tf user_data block, escape bash variables with double $$:
  
  WRONG:  APP_SECRET=${APP_SECRET}
  FIXED:  APP_SECRET=$${APP_SECRET}
  
  WRONG:  RETRY_COUNT=$((RETRY_COUNT+1))
  FIXED:  RETRY_COUNT=$$((RETRY_COUNT+1))
  
  WRONG:  echo "Bootstrap completed at $(date)."
  FIXED:  echo "Bootstrap completed at $$(date)."


ISSUE #2: AMI Not Found / Marketplace OptIn Required
-----------------------------------------------------
Problem: Hardcoded AMI IDs were either expired or required marketplace 
         subscription in the KodeKloud sandbox.

Error Messages:
  "Your query returned no results."
  "OptInRequired: In order to use this AWS Marketplace product..."
  "InvalidAMIID.Malformed: Invalid id: ami-xxxxx"

Solution Commands:
  1. Use dynamic AMI lookup in main.tf:
  
     data "aws_ami" "amazon_linux" {
       most_recent = true
       owners      = ["amazon"]
       filter {
         name   = "name"
         values = ["al2023-ami-2023.*-x86_64"]
       }
     }
  
  2. Or use a known Free Tier AMI ID in variables.tf:
     variable "ami_id" {
       default = "ami-0354c98ae10b02961"  # Amazon Linux 2023
     }
  
  3. Clear broken Terraform state:
     terraform state rm aws_instance.crm_server
     terraform apply -auto-approve


ISSUE #3: docker-compose.yml Not Found
---------------------------------------
Problem: The git clone was pulling the main branch instead of the 
         harish-task5 branch where docker-compose.yml exists.

Error Message:
  "sed: can't read docker-compose.yml: No such file or directory"

Solution Commands:
  # On EC2 instance, clone the correct branch:
  cd /opt
  rm -rf devops-crm-project
  git clone -b harish-task5 https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
  cd devops-crm-project
  ls -l docker-compose.yml  # Verify file exists


ISSUE #4: docker-compose Command Not Found
-------------------------------------------
Problem: Amazon Linux 2023 doesn't have docker-compose in default repos,
         and the docker compose plugin was missing.

Error Messages:
  "No match for argument: docker-compose"
  "unknown shorthand flag: 'd' in -d"

Solution Commands:
  # Download standalone docker-compose binary:
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose --version  # Verify installation


ISSUE #5: APP_SECRET Missing in .env File
------------------------------------------
Problem: The .env file wasn't created properly, causing docker-compose
         to fail when starting containers.

Error Message:
  "error while interpolating services.twenty-server.environment.APP_SECRET: 
   required variable APP_SECRET is missing a value"

Solution Commands:
  # Generate random APP_SECRET and create .env file:
  APP_SECRET=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)
  
  sudo bash -c "cat << EOF > .env
  PG_DATABASE_USER=postgres
  PG_DATABASE_PASSWORD=postgrespassword123
  PG_DATABASE_NAME=default
  APP_SECRET=${APP_SECRET}
  TWENTY_PORT=3000
  SERVER_URL=http://localhost:3000
  TWENTY_VERSION=latest
  EOF"
  
  cat .env  # Verify file contents


ISSUE #6: Instance Type Not Free Tier
--------------------------------------
Problem: Initially used t3.medium which is NOT Free Tier eligible.

Solution Command:
  # In variables.tf, change instance type:
  variable "instance_type" {
    default = "t3.small"  # Changed from t3.medium
  }
  
  # Apply the change:
  terraform apply -auto-approve


ISSUE #7: Connection Refused on Port 3000
------------------------------------------
Problem: App not responding even after terraform apply completed.

Error Message:
  "curl: (7) Failed to connect to 52.90.230.102 port 3000: Could not connect"

Solution Commands:
  # SSH into instance and check logs:
  ssh -i twenty-crm-harish.pem ec2-user@52.90.230.102
  sudo tail -n 50 /var/log/user-data.log
  
  # Check if containers are running:
  sudo docker ps
  
  # If containers not running, manually start them:
  cd /opt/devops-crm-project
  sudo docker-compose up -d
  
  # Verify from local machine:
  curl -I http://52.90.230.102:3000
  # Expected: HTTP/1.1 200 OK


========================================================================
COMPLETE DEPLOYMENT WORKFLOW
========================================================================

Step 1: Terraform Infrastructure
---------------------------------
cd ~/devops-crm-project/terraform
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# Note the outputs:
# - ecr_repository_url
# - ec2_public_ip


Step 2: Build and Push Docker Image
------------------------------------
# On local machine
ECR_URL="891376908875.dkr.ecr.us-east-1.amazonaws.com/twenty-crm-harish"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

docker tag devops-crm-project-app:latest $ECR_URL:latest

docker push $ECR_URL:latest


Step 3: Manual EC2 Setup (If User Data Fails)
----------------------------------------------
# SSH into EC2
ssh -i twenty-crm-harish.pem ec2-user@<EC2_PUBLIC_IP>

# Clone correct branch
cd /opt
sudo git clone -b harish-task5 https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project

# Install docker-compose
sudo curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Modify docker-compose.yml to use ECR image
ECR_URL="891376908875.dkr.ecr.us-east-1.amazonaws.com/twenty-crm-harish"
sudo sed -i "s|build:.*|image: $ECR_URL:latest|g" docker-compose.yml
sudo sed -i "/context:/d" docker-compose.yml
sudo sed -i "/dockerfile:/d" docker-compose.yml

# Create .env file
APP_SECRET=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)
sudo bash -c "cat << EOF > .env
PG_DATABASE_USER=postgres
PG_DATABASE_PASSWORD=postgrespassword123
PG_DATABASE_NAME=default
APP_SECRET=${APP_SECRET}
TWENTY_PORT=3000
SERVER_URL=http://localhost:3000
TWENTY_VERSION=latest
EOF"

# Login to ECR and pull image
aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin $ECR_URL
sudo docker pull $ECR_URL:latest

# Start containers
sudo docker-compose up -d

# Verify
sudo docker ps


Step 4: Verification
--------------------
# On local machine
curl -I http://<EC2_PUBLIC_IP>:3000

# Expected Output:
# HTTP/1.1 200 OK
# X-Powered-By: Express
# Access-Control-Allow-Origin: *


Step 5: Cleanup (IMPORTANT!)
-----------------------------
cd ~/devops-crm-project/terraform
terraform destroy -auto-approve


========================================================================
GIT COMMIT & PULL REQUEST
========================================================================

cd ~/devops-crm-project
git checkout -b harish-task-12
git add terraform/provider.tf terraform/variables.tf terraform/main.tf terraform/outputs.tf
git commit -m "Add Terraform infrastructure for Task 12 with ECR retry loop"
git push -u origin harish-task-12

# Then create Pull Request on GitHub from harish-task-12 to main


========================================================================
LOOM VIDEO CHECKLIST
========================================================================

1. [ ] Webcam ON (face visible)
2. [ ] Show main.tf file - highlight user_data script
3. [ ] Point out the 4GB swap file creation
4. [ ] Point out the ECR retry loop (30 attempts)
5. [ ] Point out the git clone -b harish-task5 command
6. [ ] Show terraform apply output with ECR URL and EC2 IP
7. [ ] Show docker push command on local machine
8. [ ] Show curl -I http://<IP>:3000 with HTTP/1.1 200 OK
9. [ ] OR show the app running in browser at http://<IP>:3000
10. [ ] Mention that infrastructure is Free Tier compliant


========================================================================
FINAL VERIFICATION
========================================================================

✅ Terraform infrastructure created successfully
✅ Docker image pushed to AWS ECR
✅ EC2 instance pulling image from ECR (not building locally)
✅ Application running on port 3000 with GRID layout
✅ HTTP/1.1 200 OK response confirmed
✅ Free Tier resources only (t3.small, 20GB gp3, Ubuntu/Amazon Linux)
✅ Git branch created and PR ready
✅ Cleanup command ready (terraform destroy)


========================================================================
END OF DOCUMENTATION
========================================================================
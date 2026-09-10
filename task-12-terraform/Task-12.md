# Task 12 – Terraform, ECR & EC2 Deployment

## Objective

Provision the Twenty CRM infrastructure using Terraform, store the Docker image in Amazon ECR, deploy it automatically on EC2 using User Data, verify the application, and clean up the resources.

## Infrastructure

- AWS Region: `us-east-1`
- Existing default VPC and subnet
- EC2 instance: `t3.small`
- OS: Ubuntu
- ECR repository: `twenty-crm`
- Application port: `2020`
- Existing IAM instance profile: `EC2ECRPullRole`

Terraform uses variables for the AWS region, instance configuration, ECR repository name, SSH/CRM CIDRs, and EC2 key pair.

Terraform outputs:

- EC2 instance ID
- EC2 public IP
- ECR repository URL
- VPC ID
- Subnet ID

## Terraform Workflow

```bash
terraform init
terraform validate
terraform plan -var="key_name=task-10-purva"
terraform apply -var="key_name=task-10-purva"
```

The ECR repository already existed in AWS, so it was imported into Terraform state:

```bash
terraform import -var="key_name=task-10-purva" \
  aws_ecr_repository.twenty_crm twenty-crm
```

## Docker Image & ECR

The Twenty CRM development image used was:

```text
twentycrm/twenty-app-dev:latest
```

It was tagged and pushed to ECR:

```bash
docker tag twentycrm/twenty-app-dev:latest \
  579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest

aws ecr get-login-password --region us-east-1 | \
  docker login \
  --username AWS \
  --password-stdin \
  579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm

docker push \
  579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest
```

The `latest` image was verified in ECR using AWS CLI.

## EC2 User Data

EC2 User Data automatically:

1. Installs Docker and AWS CLI.
2. Starts Docker.
3. Authenticates with ECR using `EC2ECRPullRole`.
4. Attempts to pull the Twenty CRM image.
5. Retries every 30 seconds if the image is unavailable.
6. Starts the container after a successful pull.

The container publishes port `2020`:

```text
2020:2020
```

## Verification

Terraform outputs:

```text
ec2_instance_id = i-0157445faa9e9cb15
ec2_public_ip = 98.92.97.71
ecr_repository_url = 579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm
subnet_id = subnet-078d52bfe579c74f2
vpc_id = vpc-0c241509159132524
```

EC2 container verification:

```bash
sudo docker ps
```

The Twenty CRM container was running from the ECR image with port `2020` exposed.

Application verification:

```bash
curl -I http://localhost:2020
```

Result:

```text
HTTP/1.1 200 OK
```

The Twenty CRM web interface was also successfully verified through the EC2 public IP.

## Issue Encountered

The `t3.small` instance experienced memory pressure because it has approximately 2 GiB RAM. Docker reported an OOM kill during startup.

A 2 GiB swap file was added to the EC2 instance:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

After enabling swap, Twenty CRM started successfully and returned `HTTP/1.1 200 OK`.

## Cleanup

After completing the PR and documentation, destroy the Terraform-managed resources:

```bash
terraform destroy -var="key_name=task-10-purva"
```

Verify that the EC2 instance, security group, and ECR repository have been removed.


### Thank you!

# Task 17 – Ansible and AWS EC2 Deployment

## 1. Objective

The objective of Task 17 was to provision one AWS EC2 instance using Terraform and deploy Twenty CRM on the instance using Ansible and Docker.

The workflow was:

Terraform → AWS EC2 → SSH → Ansible → Docker → Twenty CRM → Health Check → Verification → Terraform Destroy

## 2. Environment Used

- Operating System: Windows with Ubuntu WSL
- Ansible Version: 2.20.1
- AWS Region: us-east-1
- Instance Type: t3.small
- Approved AMI: ami-081b0a6eac00b4f53
- VPC: Default VPC
- Application Port: 2020
- Docker Image: twentycrm/twenty-app-dev:v2.35
- Git Branch: Kaushal-Sharma-Task-17

## 3. Ansible Environment Setup

Ansible was installed inside Ubuntu WSL because Ansible was not available directly in Git Bash.

### Update Ubuntu packages

Command:

    sudo apt update

Use case:

Updates the available Ubuntu package information before installing software.

### Install Ansible

Command:

    sudo apt install -y ansible

Use case:

Installs Ansible and its required dependencies.

### Verify Ansible

Command:

    ansible --version

Result:

Ansible 2.20.1 was installed successfully.

## 4. Terraform Configuration

Terraform was used to provision one EC2 instance and one security group.

### Navigate to Terraform directory

Command:

    cd ~/devops-crm-project/terraform

### Initialize Terraform

Command:

    terraform init

Use case:

Initializes the Terraform working directory and downloads the required AWS provider.

### Validate Terraform configuration

Command:

    terraform validate

Use case:

Checks the Terraform configuration for syntax and configuration errors.

### Generate Terraform plan

Command:

    terraform plan

The final plan showed:

    Plan: 2 to add, 0 to change, 0 to destroy.

The resources planned for creation were:

- One EC2 instance
- One security group

## 5. Terraform Configuration Values

The deployment used the following values:

    aws_region       = "us-east-1"
    instance_type    = "t3.small"
    ami_id           = "ami-081b0a6eac00b4f53"
    instance_name    = "twenty-crm-task17"
    allowed_ssh_cidr = "0.0.0.0/0"
    key_name         = "kaushal-task17-kkl-key"

The Terraform configuration used the default VPC and one of its default subnets.

The AMI and instance type were restricted according to the Task 17 requirements.

## 6. Terraform Apply

Command:

    terraform apply

The deployment was confirmed by entering:

    yes

Terraform successfully created the infrastructure.

Result:

    Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Created EC2 instance:

- Instance ID: i-02875852b3efd3f47
- Public IP: 18.208.201.161
- Public DNS: ec2-18-208-201-161.compute-1.amazonaws.com

Use case:

terraform apply creates the resources defined in the Terraform configuration.

## 7. SSH Key Configuration

A dedicated EC2 key pair was created:

    kaushal-task17-kkl-key

The private key was copied from Windows into WSL.

Commands:

    mkdir -p ~/.ssh
    cp /mnt/c/Users/DELL/.ssh/kaushal-task17-kkl-key.pem ~/.ssh/
    chmod 400 ~/.ssh/kaushal-task17-kkl-key.pem

Use case:

- mkdir creates the SSH directory if it does not exist.
- cp copies the private key from Windows to WSL.
- chmod 400 restricts access to the private key.

## 8. SSH Connectivity Verification

The EC2 instance was accessed using:

    ssh -i ~/.ssh/kaushal-task17-kkl-key.pem ec2-user@18.208.201.161

A timeout-limited SSH test was also used:

    ssh -o ConnectTimeout=10 -i ~/.ssh/kaushal-task17-kkl-key.pem ec2-user@18.208.201.161

SSH connectivity was successfully established.

Use case:

SSH provides remote access to the EC2 instance and verifies that the configured key pair works correctly.

## 9. Ansible Inventory

The inventory file was created at:

    ansible/inventory.ini

During deployment it contained the EC2 public IP and SSH configuration.

Example:

    [twenty_crm]
    twenty ansible_host=<EC2_PUBLIC_IP> ansible_user=ec2-user ansible_ssh_private_key_file=/home/dell/.ssh/kaushal-task17-kkl-key.pem

Use case:

The inventory tells Ansible which server to manage and which SSH credentials to use.

After the temporary EC2 instance was destroyed, the inventory was changed to use a placeholder instead of the destroyed public IP.

## 10. Ansible Connectivity Test

Command:

    ansible -i inventory.ini twenty_crm -m ping

Result:

    twenty | SUCCESS
    "ping": "pong"

Use case:

The Ansible ping module verifies that Ansible can connect to the remote server and execute modules successfully.

## 11. Ansible Playbook

The deployment playbook was created at:

    ansible/playbook.yml

The playbook automated the following operations:

1. Update server packages.
2. Install Docker.
3. Install required Docker dependencies.
4. Start and enable Docker.
5. Create the Twenty CRM application directory.
6. Configure Twenty CRM environment variables.
7. Pull the Twenty CRM Docker image.
8. Remove any existing Twenty CRM container.
9. Deploy the Twenty CRM container.
10. Configure Docker restart policy.
11. Configure Docker health check.
12. Wait for the application to start.
13. Display Docker container status.
14. Display application logs.
15. Verify the container is running.
16. Display the health status.

## 12. Playbook Syntax Check

Command:

    ansible-playbook -i inventory.ini playbook.yml --syntax-check

Result:

    playbook: playbook.yml

Use case:

The syntax check confirms that the YAML playbook can be parsed correctly before making changes to the EC2 server.

## 13. Initial Playbook Issue

The first playbook execution encountered an Amazon Linux 2023 package conflict.

The conflict was between:

    curl-minimal

and:

    curl

The EC2 image already contained curl-minimal, so installing the separate curl package caused a dependency conflict.

The unnecessary curl dependency was removed from the playbook because it was not required for the Twenty CRM deployment.

The playbook was then syntax-checked again successfully.

## 14. Successful Ansible Deployment

The corrected playbook was executed using:

    ansible-playbook -i inventory.ini playbook.yml

The final result was:

    PLAY RECAP
    twenty : ok=17 changed=6 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0

This confirmed:

- 17 tasks completed successfully.
- 6 tasks made changes.
- The host was reachable.
- No task failed.

Most important result:

    failed=0

## 15. Docker Deployment

Twenty CRM was deployed using the image:

    twentycrm/twenty-app-dev:v2.35

Container configuration:

- Container name: twenty-crm
- Application port: 2020
- Restart policy: unless-stopped
- Docker health check: configured

The application port was mapped as:

    0.0.0.0:2020->2020/tcp

## 16. Docker Container Verification

Docker status was checked on the EC2 instance using:

    sudo docker ps -a

The result showed:

    twenty-crm
    Up 25 minutes (healthy)
    0.0.0.0:2020->2020/tcp

This confirmed:

- The container existed.
- The container was running.
- Port 2020 was exposed.
- The Docker health check reported healthy.

Use case:

docker ps -a displays all Docker containers and their current status.

## 17. Docker Health Check

The Ansible playbook configured a Docker health check for Twenty CRM.

The verification showed:

    Up 25 minutes (healthy)

Use case:

The Docker health check provides an automated indication that the application container is operational.

## 18. Docker Restart Policy

The Twenty CRM container was configured using:

    --restart unless-stopped

Use case:

The restart policy allows Docker to automatically restart the container if it exits unexpectedly or when the Docker service restarts, unless the container was explicitly stopped.

## 19. Application Logs

The playbook included a task to display application logs.

Command:

    docker logs --tail 50 twenty-crm

Manual verification with elevated Docker permissions:

    sudo docker logs --tail 50 twenty-crm

Use case:

Docker logs help verify application startup and identify runtime errors.

The application log display task was executed successfully by the Ansible playbook.

## 20. Application Port

Twenty CRM used port:

    2020

Docker exposed:

    0.0.0.0:2020->2020/tcp

The Terraform security group allowed inbound TCP traffic on port 2020.

Use case:

This allows access to the Twenty CRM application through the EC2 public IP while the application listens on port 2020.

## 21. Terraform Destroy Plan

After deployment and verification, the infrastructure cleanup was prepared using:

    terraform plan -destroy

The destroy plan showed:

    Plan: 0 to add, 0 to change, 2 to destroy.

The resources scheduled for deletion were:

- aws_instance.twenty_crm
- aws_security_group.ansible_ec2

Use case:

terraform plan -destroy previews which resources Terraform will remove.

## 22. Terraform Destroy

The infrastructure was removed using:

    terraform destroy

The final result was:

    aws_instance.twenty_crm: Destruction complete
    aws_security_group.ansible_ec2: Destruction complete

    Destroy complete! Resources: 2 destroyed.

Use case:

terraform destroy removes the infrastructure created for the task and prevents unnecessary AWS resources from remaining active.

## 23. Final Task Result

Task 17 successfully demonstrated:

- Terraform-based AWS EC2 provisioning.
- Default VPC and subnet usage.
- Approved AMI usage.
- t3.small EC2 configuration.
- SSH connectivity.
- Ansible inventory configuration.
- Ansible connectivity verification.
- Automated server package updates.
- Docker installation.
- Docker service configuration.
- Twenty CRM Docker deployment.
- Docker restart policy configuration.
- Docker health check configuration.
- Docker container verification.
- Application log display.
- Successful Ansible execution with failed=0.
- Terraform infrastructure cleanup.

The EC2 instance and security group were successfully destroyed after verification.

## 24. Evidence / Screenshots

Recommended screenshots for Task 17:

1. Terraform plan showing:
   - us-east-1
   - t3.small
   - approved AMI
   - key pair
   - 2 to add

2. Terraform apply showing:
   - Instance ID
   - Public IP
   - Resources: 2 added

3. Ansible connectivity showing:
   - ping: pong

4. Ansible successful playbook result:
   - failed=0

5. Docker container status showing:
   - twenty-crm
   - Up
   - healthy
   - port 2020

6. Twenty CRM application logs.

7. Terraform destroy plan showing:
   - 0 to add
   - 0 to change
   - 2 to destroy

8. Terraform destroy result showing:
   - Destroy complete! Resources: 2 destroyed.

## 25. Files Added

    ansible/
    ├── inventory.ini
    └── playbook.yml

    docs/
    └── task-17-ansible-aws-deployment.md

The final inventory uses a placeholder for the temporary EC2 public IP because the Task 17 EC2 instance has already been destroyed.

Private keys must never be committed to the repository.

## 26. Conclusion

Task 17 was completed by combining Terraform and Ansible.

Terraform was responsible for provisioning the AWS infrastructure, while Ansible automated server configuration and deployment of Twenty CRM using Docker.

Twenty CRM was successfully deployed with a Docker restart policy and health check. The final Ansible run completed with zero failures.

After verification, Terraform successfully destroyed the EC2 instance and security group, completing the required cleanup.

# Task 17 - Ansible and AWS EC2 Deployment



### &#x20;1. Overview



This task demonstrates an automated AWS EC2 deployment of the Twenty CRM application using \*\*Terraform, Ansible, and Docker\*\*.



The infrastructure is provisioned using Terraform, while Ansible is responsible for configuring the EC2 instance and deploying Twenty CRM as a Docker container.



The deployment is designed to be repeatable and automated, reducing the need for manual server configuration.



\### Technologies Used



\- AWS EC2

\- AWS VPC

\- AWS Security Groups

\- Terraform

\- Ansible

\- Docker

\- Ubuntu

\- PowerShell

\- WSL

\- Twenty CRM



\---



### &#x20;2. Task Objective



The main objective of Task 17 is to:



1\. Provision an AWS EC2 instance using Terraform.

2\. Use the `us-east-1` AWS region.

3\. Use a `t3.small` EC2 instance.

4\. Use an Ubuntu AMI.

5\. Deploy the EC2 instance inside the default VPC.

6\. Use a subnet from the default VPC.

7\. Configure SSH access to the EC2 instance.

8\. Obtain the EC2 public IP address.

9\. Add the EC2 public IP to the Ansible inventory.

10\. Connect to the EC2 instance using Ansible.

11\. Configure the Ubuntu operating system.

12\. Configure additional swap memory.

13\. Install Docker and required dependencies.

14\. Create application directories.

15\. Configure Twenty CRM environment variables.

16\. Pull the Twenty CRM Docker image.

17\. Deploy Twenty CRM using Docker.

18\. Configure a Docker restart policy.

19\. Configure a Docker health check.

20\. Verify that Twenty CRM is healthy.

21\. Verify the application health endpoint.

22\. Display Docker container status.

23\. Display application logs.

24\. Verify the final deployment.

25\. Destroy the temporary AWS infrastructure after completing the task.



\---



### &#x20;**3. Architecture**



The deployment follows this architecture:



```text

&#x20;                   AWS

&#x20;                    |

&#x20;                    |

&#x20;             Default VPC

&#x20;                    |

&#x20;                    |

&#x20;             Default Subnet

&#x20;                    |

&#x20;                    |

&#x20;             Security Group

&#x20;            /               \\

&#x20;           /                 \\

&#x20;       SSH :22            HTTP :2020

&#x20;          |                   |

&#x20;          |                   |

&#x20;          +-------- EC2 ------+

&#x20;                   |

&#x20;              Ubuntu Linux

&#x20;                   |

&#x20;                Ansible

&#x20;                   |

&#x20;      +------------+-------------+

&#x20;      |                          |

&#x20;  Docker Engine             2 GB Swap

&#x20;      |

&#x20;      |

&#x20; Twenty CRM Container

&#x20;      |

&#x20;      +-------------------------+

&#x20;      |                         |

&#x20;  Port 2020              Health Check

&#x20;      |                         |

&#x20;      |                      /healthz

&#x20;      |

&#x20; Twenty CRM Application



 4. **Deployment Flow**
---



The complete deployment flow is:



Terraform

&#x20;   |

&#x20;   v

AWS EC2 Instance

&#x20;   |

&#x20;   v

Get Public IP

&#x20;   |

&#x20;   v

Update Ansible Inventory

&#x20;   |

&#x20;   v

Ansible SSH Connection

&#x20;   |

&#x20;   v

Configure Ubuntu

&#x20;   |

&#x20;   +---- Configure 2 GB Swap

&#x20;   |

&#x20;   +---- Update APT Cache

&#x20;   |

&#x20;   +---- Install Docker Dependencies

&#x20;   |

&#x20;   +---- Install Docker

&#x20;   |

&#x20;   +---- Start Docker

&#x20;   |

&#x20;   +---- Create Application Directories

&#x20;   |

&#x20;   +---- Generate .env

&#x20;   |

&#x20;   v

Pull Twenty CRM Image

&#x20;   |

&#x20;   v

Create Docker Container

&#x20;   |

&#x20;   +---- Port 2020

&#x20;   |

&#x20;   +---- Restart Policy

&#x20;   |

&#x20;   +---- Health Check

&#x20;   |

&#x20;   +---- Persistent Storage

&#x20;   |

&#x20;   v

Wait for Healthy Status

&#x20;   |

&#x20;   v

Verify /healthz

&#x20;   |

&#x20;   v

Verify Application Root

&#x20;   |

&#x20;   v

Display Docker Status

&#x20;   |

&#x20;   v

Display Application Logs

&#x20;   |

&#x20;   v

Deployment Complete



### &#x20;5. **Project Structure**



The Task 17 project is organized as follows:



Task-17-Ansible-AWS/

│

├── ansible/

│   ├── inventory.ini

│   ├── playbook.yml

│   │

│   ├── group\_vars/

│   │   └── twenty\_crm.yml

│   │

│   └── templates/

│       └── .env.j2

│

├── terraform/

│   ├── provider.tf

│   ├── variables.tf

│   ├── main.tf

│   ├── outputs.tf

│   └── terraform.tfvars

│

├── .gitignore

└── README.md



**Terraform-generated files such as the .terraform directory and Terraform state files are intentionally excluded from source control.**



**6. AWS Infrastructure**
---



##### **6.1 AWS Region**



The deployment uses:



us-east-1



##### **6.2 EC2 Instance**



The EC2 instance is configured with:



Instance Type: t3.small

Operating System: Ubuntu

Public IP: Enabled



The EC2 instance is provisioned using Terraform.



##### **6.3 VPC**



Terraform discovers the AWS default VPC automatically.



The configuration uses:



data "aws\_vpc" "default" {

&#x20; default = true

}



This avoids hard-coding a VPC ID.



##### **6.4 Subnet**



Terraform retrieves subnets belonging to the default VPC:



data "aws\_subnets" "default" {

&#x20; filter {

&#x20;   name   = "vpc-id"

&#x20;   values = \[data.aws\_vpc.default.id]

&#x20; }

}



The first available subnet is used for the EC2 instance.



### **7. Security Group**



A dedicated security group is created for the Twenty CRM EC2 instance.



Inbound Rules

SSH

Protocol: TCP

Port: 22

Source: 0.0.0.0/0



SSH is required so that Ansible and the administrator can connect to the EC2 instance.



Twenty CRM

Protocol: TCP

Port: 2020

Source: 0.0.0.0/0



Port 2020 is used by the Twenty CRM application.



Outbound Rules



All outbound traffic is allowed:



Protocol: All

Destination: 0.0.0.0/0



For a production deployment, SSH access should ideally be restricted to a trusted IP range instead of allowing 0.0.0.0/0.



### **8. Terraform Configuration**



Terraform is responsible only for provisioning the AWS infrastructure.



It does not configure Docker or deploy Twenty CRM.



The Terraform configuration consists of:



provider.tf

variables.tf

main.tf

outputs.tf

terraform.tfvars



#### **8.1 provider.tf**



The AWS provider is configured for us-east-1.



Example:



terraform {

&#x20; required\_providers {

&#x20;   aws = {

&#x20;     source  = "hashicorp/aws"

&#x20;     version = "\~> 6.0"

&#x20;   }

&#x20; }

}



provider "aws" {

&#x20; region = var.aws\_region

}



### **9. Terraform Variables**



The Terraform variables include:



aws\_region

instance\_type

ami\_id

key\_name

allowed\_ssh\_cidr



Example values:



AWS Region:      us-east-1

Instance Type:   t3.small

Key Pair:        puneet-90

SSH CIDR:        0.0.0.0/0



The AMI ID is supplied through terraform.tfvars.



### **10. Terraform Outputs**



Terraform exposes the following outputs:



instance\_id

public\_ip

public\_dns



This makes it easy to obtain the EC2 public IP after provisioning.



Example:



terraform output



### **11. Terraform Deployment Commands**



**Navigate to the Terraform directory:**



cd .\\Task-17-Ansible-AWS\\terraform



**Initialize Terraform:**



terraform init



**Format the configuration:**



terraform fmt



**Validate the configuration:**



terraform validate



**Create a plan:**



terraform plan



**Apply the infrastructure:**



terraform apply



**After successful provisioning:**



terraform output



### **12. Ansible Configuration**



After Terraform creates the EC2 instance, the public IP address is added to the Ansible inventory.



Ansible is then used to automate the complete server configuration.



### **13. Ansible Inventory**



The inventory contains the EC2 public IP and SSH configuration.



Example:



\[twenty\_crm]

twenty ansible\_host=184.193.17.107 ansible\_user=ubuntu ansible\_ssh\_private\_key\_file=/home/puneet90/.ssh/puneet-90.pem



The private key is stored locally and is not committed to Git.



### **14. Ansible Playbook**



The main Ansible playbook is:



ansible/playbook.yml



The playbook performs the complete deployment.



#### **14.1 Wait for EC2 SSH**



The playbook first waits for the EC2 instance to become reachable over SSH.



\- name: Wait for EC2 SSH connection

&#x20; ansible.builtin.wait\_for\_connection:

&#x20;   delay: 5

&#x20;   timeout: 300



This is useful because an EC2 instance may require some time after creation before SSH becomes available.



### **15. Configure 2 GB Swap**



The EC2 instance is a t3.small with approximately 2 GB of RAM.



To improve memory stability during the Twenty CRM deployment, the playbook creates a 2 GB swap file.



Swap Size: 2 GB

File: /swapfile



The swap file is:



Created using fallocate

Given secure permissions

Formatted using mkswap

Enabled using swapon

Added to /etc/fstab for persistence



Verification is performed using:



free -h



Example verification:



Swap: 2.0Gi



### **16. Update APT Package Cache**



The playbook updates the package cache:



\- name: Update APT package cache

&#x20; ansible.builtin.apt:

&#x20;   update\_cache: true

&#x20;   cache\_valid\_time: 3600



A full dist-upgrade is intentionally not performed because the EC2 root filesystem is small and a complete operating-system upgrade may require significant additional disk space.



The task only requires the package environment to be updated sufficiently for the Docker deployment.



### **17. Docker Installation**



The playbook installs the required Docker dependencies.



Packages include:



apt-transport-https

ca-certificates

curl

gnupg

lsb-release

software-properties-common

python3

python3-pip

python3-docker



Docker Engine is then installed:



docker.io



The Docker service is enabled and started automatically.



### **18. Docker Service**



The playbook ensures Docker is running:



\- name: Enable and start Docker

&#x20; ansible.builtin.systemd:

&#x20;   name: docker

&#x20;   enabled: true

&#x20;   state: started



This ensures Docker starts automatically when the EC2 instance boots.



### **19. Docker Group Configuration**



The Ubuntu user is added to the Docker group:



\- name: Add ubuntu user to docker group

&#x20; ansible.builtin.user:

&#x20;   name: ubuntu

&#x20;   groups:

&#x20;     - docker

&#x20;   append: true



This allows the Ubuntu user to interact with Docker without requiring sudo after the group membership is refreshed.



### **20. Application Directories**



The playbook creates:



/opt/twenty

/opt/twenty/data



The directories are used for application configuration and persistent local application storage.



### **21. Twenty CRM Environment Configuration**



The .env file is generated automatically using the Ansible template:



ansible/templates/.env.j2



The template configures variables such as:



NODE\_ENV

PORT

NODE\_PORT

SERVER\_URL

FRONT\_BASE\_URL

APP\_SECRET

SIGN\_IN\_PREFILLED

STORAGE\_TYPE

STORAGE\_LOCAL\_PATH



The generated environment file is stored on the EC2 instance at:



/opt/twenty/.env



The file is configured with restrictive permissions:



0600



### **22. Twenty CRM Docker Image**



The deployment uses the pinned Twenty CRM development image:



twentycrm/twenty-app-dev:v2.35



A fixed image version is used instead of latest to make the deployment more predictable and reproducible.



The image is pulled using:



docker pull twentycrm/twenty-app-dev:v2.35



### **23. Docker Container**



The application container is named:



twenty-crm



The container exposes:



2020:2020



Therefore, the application is accessible through:



http://<EC2\_PUBLIC\_IP>:2020



For this deployment:



http://184.193.17.107:2020



### **24. Docker Restart Policy**



The container uses:



unless-stopped



Configuration:



\--restart unless-stopped



This allows Docker to automatically restart the container after Docker or the EC2 host restarts, unless the container has been explicitly stopped.



Verification:



docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' twenty-crm



Expected:



unless-stopped



### **25. Docker Health Check**



A Docker health check is configured for Twenty CRM.



The health check calls:



http://127.0.0.1:2020/healthz



Configuration:



Health interval:      30 seconds

Health timeout:       10 seconds

Health start period:  180 seconds

Health retries:       5



The extended start period gives Twenty CRM sufficient time to initialize its services.



### **26. Persistent Storage**



The deployment uses persistent storage for application data:



/opt/twenty/data



This is mounted into the container at:



/app/.local-storage



A Docker volume is also used for PostgreSQL data:



twenty-postgres-data



This helps preserve application data if the container is recreated.



### **27. Ansible Health Verification**



Instead of depending on the Ansible Docker SDK, the deployment uses the Docker CLI.



This approach was selected because the EC2 environment previously produced a Docker SDK connection error involving:



http+docker



Using the Docker CLI avoids that dependency issue.



The playbook checks:



.State.Health.Status



and waits until the status becomes:



healthy



### **28. Application Health Endpoint**



After the Docker container becomes healthy, the playbook verifies:



http://127.0.0.1:2020/healthz



Successful response:



{

&#x20; "status": "ok",

&#x20; "info": {},

&#x20; "error": {},

&#x20; "details": {}

}



The expected HTTP status is:



200



### **29. Root Application Verification**



The playbook also verifies the application root:



http://127.0.0.1:2020/



The deployment successfully returned:



HTTP 200



This provides an additional verification that the application is serving HTTP traffic.



### **30. Docker Container Verification**



The following command was used on the EC2 instance:



docker ps



Successful output showed:



twentycrm/twenty-app-dev:v2.35

Up

healthy

0.0.0.0:2020->2020/tcp

twenty-crm



The container was also inspected using:



docker inspect --format '{{.State.Status}} | {{.State.Health.Status}} | Restart={{.HostConfig.RestartPolicy.Name}}' twenty-crm



Successful result:



running | healthy | Restart=unless-stopped



### **31. Application Logs**



Application logs were collected using:



docker logs --tail 35 twenty-crm



The logs showed successful application initialization.



Important log evidence included:



Nest application successfully started



The logs also showed normal background job and Redis activity after startup.



### **32. Memory and Swap Verification**



The EC2 instance was checked using:



free -h



The deployment showed:



Mem:   approximately 1.9Gi

Swap:  2.0Gi



Example:



&#x20;              total        used        free      shared  buff/cache   available

Mem:           1.9Gi       1.4Gi       327Mi        12Mi       297Mi       439Mi

Swap:          2.0Gi       708Mi       1.3Gi



This confirms that the 2 GB swap configuration was successfully enabled.



### **33. Final Deployment Result**



The Ansible playbook completed successfully.



Final recap:



ok=25

changed=7

failed=0

unreachable=0

skipped=3

rescued=0

ignored=0



This indicates:



Ansible connection:      SUCCESS

Server configuration:    SUCCESS

Docker installation:     SUCCESS

Twenty CRM deployment:   SUCCESS

Health check:             SUCCESS

HTTP health endpoint:     SUCCESS

Application root:         SUCCESS

Deployment logs:          SUCCESS

34\. Final Deployment Information

EC2

Instance ID:

i-0816066de0862f42d

Public IP:

184.193.17.107

Instance Type:

t3.small

Region:

us-east-1

Twenty CRM

Container:

twenty-crm

Image:

twentycrm/twenty-app-dev:v2.35

Port:

2020

Restart Policy:

unless-stopped

Container Health:

healthy

Application URLs



Application:



http://184.193.17.107:2020



Health endpoint:



http://184.193.17.107:2020/healthz



Health response:



{

&#x20; "status": "ok",

&#x20; "info": {},

&#x20; "error": {},

&#x20; "details": {}

}



### **35. Verification Commands**



Verify EC2 from AWS CLI

aws ec2 describe-instances `

&#x20; --instance-ids i-0816066de0862f42d `

&#x20; --region us-east-1 `

&#x20; --query "Reservations\[0].Instances\[0].{ID:InstanceId,State:State.Name,PublicIP:PublicIpAddress}" `

&#x20; --output table

Verify Ansible connectivity

wsl ansible -i ./Task-17-Ansible-AWS/ansible/inventory.ini twenty\_crm -m ping



Expected:



twenty | SUCCESS

Run Ansible deployment



From the repository root:



wsl ansible-playbook `

&#x20; -i ./Task-17-Ansible-AWS/ansible/inventory.ini `

&#x20; ./Task-17-Ansible-AWS/ansible/playbook.yml

Verify Docker



SSH into the EC2:



ssh -i "C:\\Users\\Puneet Rathore\\Downloads\\puneet-90.pem" ubuntu@184.193.17.107



Then:



docker ps

Verify health

curl -i http://127.0.0.1:2020/healthz

Verify restart policy and health

docker inspect --format '{{.State.Status}} | {{.State.Health.Status}} | Restart={{.HostConfig.RestartPolicy.Name}}' twenty-crm



Expected:



running | healthy | Restart=unless-stopped

Verify memory and swap

free -h

View application logs

docker logs --tail 50 twenty-crm



### **36. Troubleshooting**

#### **SSH Connection Timeout**



If Ansible reports:



Connection timed out during banner exchange



first verify direct SSH:



ssh -i "C:\\Users\\Puneet Rathore\\Downloads\\puneet-90.pem" ubuntu@<PUBLIC\_IP>



Then test Ansible:



wsl ansible -i ./Task-17-Ansible-AWS/ansible/inventory.ini twenty\_crm -m ping



Also verify:



EC2 instance is running.

Public IP is correct.

Security Group allows TCP port 22.

SSH key is correct.

EC2 has completed booting.



### **37. Disk Space Issue**



The original playbook attempted a full:



apt dist-upgrade



The small EC2 root filesystem did not have enough free space for the large package upgrade.



The deployment was changed to perform only:



apt update



and install the packages required for the task.



This avoids unnecessarily consuming the limited root disk space.



### **38. Docker SDK Issue**



The community.docker Ansible modules previously encountered a Docker SDK connection issue:



Not supported URL scheme http+docker



The final playbook therefore uses Docker CLI commands such as:



docker pull

docker run

docker ps

docker inspect

docker logs



This provides a direct and reliable interaction with the Docker daemon on the EC2 instance.



### **39. Health Check Considerations**



Twenty CRM requires time to initialize its server, worker, PostgreSQL, Redis, and related services.



Therefore, the Docker health check includes a startup grace period:



180 seconds



The playbook also waits for the Docker health status to become:



healthy



before performing the final HTTP verification.



### **40. Git and Security**



The following files should not be committed to Git:



\*.tfstate

\*.tfstate.\*

.terraform/

\*.pem

.env



Terraform state may contain infrastructure information and local state should not be included in the Task 17 source commit.



Private SSH keys must never be committed to the repository.



### **41. Git Commands**



Check the repository:



git status



Stage only Task 17 files:



git add .\\Task-17-Ansible-AWS\\.gitignore

git add .\\Task-17-Ansible-AWS\\README.md

git add .\\Task-17-Ansible-AWS\\ansible\\inventory.ini

git add .\\Task-17-Ansible-AWS\\ansible\\playbook.yml

git add .\\Task-17-Ansible-AWS\\ansible\\group\_vars\\twenty\_crm.yml

git add .\\Task-17-Ansible-AWS\\ansible\\templates\\.env.j2

git add .\\Task-17-Ansible-AWS\\terraform\\provider.tf

git add .\\Task-17-Ansible-AWS\\terraform\\variables.tf

git add .\\Task-17-Ansible-AWS\\terraform\\main.tf

git add .\\Task-17-Ansible-AWS\\terraform\\outputs.tf

git add .\\Task-17-Ansible-AWS\\terraform\\terraform.tfvars



Verify staged files:



git status



Commit:



git commit -m "Task 17: Automate Twenty CRM deployment with Ansible"



Push:



git push -u origin Puneet-Task-17



### **42. Cleanup**



The EC2 instance is intended to be temporary for this practical task.



After:



Deployment verification

Screenshots

Documentation

Git commit

Push

Pull Request

Loom recording



the infrastructure should be destroyed.



Navigate to:



cd E:\\pearlthoughts\\devops-crm-project\\Task-17-Ansible-AWS\\terraform



Review the resources that Terraform plans to destroy:



terraform plan -destroy



Then destroy the infrastructure:



terraform destroy



Confirm with:



yes



Verify that the infrastructure has been removed:



terraform state list


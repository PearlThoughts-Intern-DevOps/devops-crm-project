\# Task 12 — Terraform + AWS Infrastructure



\## 1. Introduction



This task demonstrates Infrastructure as Code (IaC) using Terraform to provision and manage AWS infrastructure for deploying the Twenty CRM application.



The implementation uses Terraform to manage the required AWS resources and automate the deployment of the Twenty CRM Docker container on an EC2 instance.



The complete workflow is:



```text

Terraform

&#x20;   ↓

AWS EC2

&#x20;   ↓

IAM Instance Profile

&#x20;   ↓

Amazon ECR

&#x20;   ↓

Docker

&#x20;   ↓

Twenty CRM

&#x20;   ↓

Port 2020

&#x20;   ↓

Browser

2\. Objectives



The objectives of this task were:



Create a proper Terraform project structure.

Configure the AWS provider for the us-east-1 region.

Use the existing/default AWS VPC.

Use an existing/default subnet.

Provision an EC2 instance using Terraform.

Provision and manage an Amazon ECR repository using Terraform.

Configure Terraform variables.

Configure Terraform outputs.

Configure EC2 User Data for automated setup.

Install Docker and required dependencies automatically.

Authenticate EC2 with Amazon ECR using the existing IAM instance profile.

Implement an ECR image pull retry mechanism.

Build/tag and push the Twenty CRM Docker image to ECR.

Automatically pull and run the image on EC2.

Verify the Twenty CRM application through the browser.

Verify the application using an HTTP health check.

Verify Terraform state and infrastructure consistency.

Destroy the Terraform-managed infrastructure after completion.

3\. Technology Stack

Technology	Purpose

Terraform	Infrastructure as Code

AWS EC2	Application hosting

Amazon ECR	Docker image registry

AWS VPC	Networking

AWS Security Group	Network access control

AWS IAM	Authentication and authorization

Docker	Containerization

Twenty CRM	CRM application

Ubuntu	EC2 operating system

AWS CLI	AWS resource management

Git	Version control

GitHub	Source code management

4\. Terraform Project Structure



The Terraform project was created with the following structure:



Task-12-Terraform/

│

├── .gitignore

├── ec2.tf

├── ecr.tf

├── outputs.tf

├── provider.tf

├── README.md

├── terraform.tfvars.example

├── variables.tf

├── vpc.tf

└── .terraform.lock.hcl

4.1 Terraform Files

provider.tf



Contains the Terraform version requirements and AWS provider configuration.



variables.tf



Contains configurable infrastructure variables.



vpc.tf



Discovers the existing/default AWS VPC and subnet.



ec2.tf



Creates the EC2 instance and Security Group and contains the EC2 User Data configuration.



ecr.tf



Creates and manages the Amazon ECR repository.



outputs.tf



Defines useful outputs such as EC2 instance ID, public IP, ECR repository URL, VPC ID, and subnet ID.



terraform.tfvars.example



Provides example variable values without exposing local or sensitive configuration.



.gitignore



Prevents Terraform state files, local variable files, private keys, environment files, and generated Terraform directories from being committed.



.terraform.lock.hcl



Locks the Terraform provider dependency version.



5\. AWS Provider Configuration



The AWS provider was configured for the us-east-1 region.



The Terraform configuration also applies common default tags to AWS resources.



terraform {

&#x20; required\_version = ">= 1.5.0"



&#x20; required\_providers {

&#x20;   aws = {

&#x20;     source  = "hashicorp/aws"

&#x20;     version = "\~> 6.0"

&#x20;   }

&#x20; }

}



provider "aws" {

&#x20; region = var.aws\_region



&#x20; default\_tags {

&#x20;   tags = {

&#x20;     Project     = "Twenty-CRM"

&#x20;     Environment = "Dev"

&#x20;     ManagedBy   = "Terraform"

&#x20;     Owner       = "Puneet-Rathore"

&#x20;   }

&#x20; }

}

6\. AWS Region



The deployment was performed in:



us-east-1



The region is configurable through the Terraform variable:



aws\_region

7\. Existing VPC and Subnet



The task required using the existing/default VPC and subnet.



Terraform discovers the default VPC using:



data "aws\_vpc" "default" {

&#x20; default = true

}



The subnet is then selected from the default VPC.



7.1 VPC Verification

VPC ID:

vpc-0c241509159132524

7.2 Subnet Verification

Subnet ID:

subnet-078d52bfe579c74f2



Using Terraform data sources avoids unnecessary creation of additional networking infrastructure.



8\. Terraform Variables



The Terraform configuration uses variables to make the infrastructure configurable and reusable.



The main variables are:



aws\_region

instance\_name

instance\_type

key\_name

allowed\_ssh\_cidr

ecr\_repository\_name

docker\_image\_tag

iam\_instance\_profile

ami\_id

8.1 Default AWS Region

us-east-1

8.2 EC2 Instance Type

t3.small



The t3.small instance type was used because it was the authorized instance type for this task.



8.3 IAM Instance Profile

EC2ECRPullRole



An existing IAM instance profile was used instead of creating a new IAM role.



8.4 ECR Repository

twenty-crm

8.5 Docker Image Tag

latest

8.6 AMI

ami-0b6d9d3d33ba97d99

9\. Amazon ECR



Terraform was used to manage the Amazon ECR repository for the Twenty CRM Docker image.



The repository was configured with:



Mutable image tags

Image scanning on push

AES256 encryption

Terraform-managed tags

9.1 Repository Name

twenty-crm

9.2 Repository URI

579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm

9.3 Image URI

579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest

10\. EC2 Configuration



Terraform was used to provision the Ubuntu EC2 instance.



The final EC2 configuration was:



Configuration	Value

AMI	ami-0b6d9d3d33ba97d99

Instance Type	t3.small

Region	us-east-1

Root Volume	20 GiB

Volume Type	gp3

VPC	vpc-0c241509159132524

Subnet	subnet-078d52bfe579c74f2

IAM Instance Profile	EC2ECRPullRole

Public IP	Enabled

Application Port	2020

11\. EC2 Root Volume



The EC2 instance was configured with a 20 GiB GP3 root volume.



Terraform configuration:



root\_block\_device {

&#x20; volume\_size = 20

&#x20; volume\_type = "gp3"

}



The volume was independently verified through AWS CLI.



Verified configuration:



Size:

20 GiB



Type:

gp3



State:

in-use



This satisfies the required 20 GiB root volume configuration.



12\. EC2 Security Group



Terraform creates a Security Group for the Twenty CRM EC2 instance.



12.1 Inbound Rules

Port	Protocol	Source	Purpose

22	TCP	Configured SSH CIDR	SSH access

2020	TCP	0.0.0.0/0	Twenty CRM web access

12.2 Outbound Rules



All outbound traffic is allowed:



0.0.0.0/0



This allows the EC2 instance to communicate with external services such as package repositories and Amazon ECR.



13\. IAM Instance Profile



The existing IAM instance profile was attached to the EC2 instance:



EC2ECRPullRole



The instance profile allows the EC2 instance to authenticate with Amazon ECR and pull the required Docker image.



No new IAM role was created as part of this task.



14\. EC2 User Data



EC2 User Data was used to automate the application deployment process.



The User Data performs the following operations:



Creates a 2 GiB swap file.

Enables the swap file.

Configures swap behavior.

Updates Ubuntu packages.

Installs Docker.

Installs AWS CLI.

Installs Git.

Enables Docker.

Starts Docker.

Waits for the Docker daemon to become ready.

Authenticates with Amazon ECR.

Attempts to pull the Twenty CRM image.

Retries the pull every 30 seconds if the image is unavailable.

Starts the Twenty CRM container after a successful pull.

Configures the container to restart automatically.

15\. Swap Configuration



The authorized EC2 instance type was t3.small, which has limited memory.



To improve application stability, a 2 GiB swap file was configured through User Data.



The swap file is:



/swapfile



The configured size is:



2 GiB

15.1 Swap Verification



The configuration was verified using:



free -h



The instance showed:



Mem:   1.9Gi

Swap:  2.0Gi



The swap file was also verified using:



sudo swapon --show



The output confirmed:



/swapfile

2G

16\. Docker Installation



Docker was installed automatically through EC2 User Data.



The required packages included:



docker.io

awscli

git



Docker was enabled and started using:



systemctl enable docker

systemctl start docker



The User Data script also waits for the Docker daemon before attempting to deploy the application.



17\. Twenty CRM Docker Image



The Twenty CRM Docker image used for deployment was:



twentycrm/twenty-app-dev:v2.35



The image was tagged for the Terraform-created ECR repository.



17.1 Docker Tag

docker tag twentycrm/twenty-app-dev:v2.35 \\

579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest

18\. ECR Authentication



ECR authentication was performed using the AWS CLI.



Command:



aws ecr get-login-password --region us-east-1 |

docker login --username AWS --password-stdin \\

579138738751.dkr.ecr.us-east-1.amazonaws.com



The authentication was successfully completed.



Result:



Login Succeeded

19\. Docker Image Push



After authentication, the Docker image was pushed to ECR.



Command:



docker push \\

579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest



The image push completed successfully.



19.1 ECR Image Digest



The final image digest was:



sha256:9a58a3f05c1d7c5ca0f45966e4b366d19ac063032dcba2123540b30de4ba7cd4

19.2 Image Status



The image was verified as:



Tag: latest

Status: ACTIVE

20\. ECR Pull Retry Mechanism



The EC2 User Data includes a retry mechanism for the Docker image pull.



If the image is unavailable, the instance waits 30 seconds and tries again.



The deployment flow is:



Authenticate with ECR

&#x20;       |

&#x20;       v

Attempt Docker Pull

&#x20;       |

&#x20;  +----+----+

&#x20;  |         |

Success    Failure

&#x20;  |         |

&#x20;  v         v

Start      Wait 30 sec

Container     |

&#x20;             |

&#x20;             +------> Retry



This ensures that the EC2 instance can automatically deploy the application once the image becomes available in ECR.



21\. Docker Container Deployment



After successfully pulling the ECR image, the User Data script starts the Twenty CRM container.



The container is started using:



docker run -d \\

&#x20; --name twenty-crm \\

&#x20; --restart unless-stopped \\

&#x20; -p 2020:2020 \\

&#x20; "$IMAGE\_URI"

21.1 Container Name

twenty-crm

21.2 Container Image

579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest

21.3 Port Mapping

2020:2020

21.4 Restart Policy

unless-stopped

22\. EC2 Deployment Verification



The Terraform-created EC2 instance was:



Instance ID:

i-0bd086d14068a8a2b

22.1 Public IP

100.31.237.128

22.2 Public DNS

ec2-100-31-237-128.compute-1.amazonaws.com

23\. Docker Container Verification



The running container was verified using:



docker ps



The output confirmed:



Container:

twenty-crm



Image:

579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest



Status:

Up



Port:

0.0.0.0:2020->2020/tcp



This proves that the EC2 instance successfully pulled the Docker image from ECR and started the Twenty CRM container.



24\. Twenty CRM Application Verification



Twenty CRM was accessed through the EC2 public IP:



http://100.31.237.128:2020



The Twenty CRM web interface loaded successfully in the browser.



The Companies page was successfully displayed.



This confirms the complete application path:



Internet

&#x20;  |

&#x20;  v

EC2 Public IP

&#x20;  |

&#x20;  v

Security Group

&#x20;  |

&#x20;  v

Port 2020

&#x20;  |

&#x20;  v

Docker Container

&#x20;  |

&#x20;  v

Twenty CRM

25\. Application Health Check



The application was also verified directly from inside the EC2 instance.



Command:



curl -I http://localhost:2020



The application returned:



HTTP/1.1 200 OK



The response also included:



Content-Type: text/html; charset=utf-8



This confirms that Twenty CRM was actively responding on port 2020.



26\. ECR Verification



The ECR image was verified using:



aws ecr describe-images \\

&#x20; --repository-name twenty-crm \\

&#x20; --region us-east-1



The verification confirmed:



Repository:

twenty-crm



Tag:

latest



Status:

ACTIVE



The image digest was:



sha256:9a58a3f05c1d7c5ca0f45966e4b366d19ac063032dcba2123540b30de4ba7cd4



The ECR metadata also recorded a successful pull after the image was pushed, confirming that the EC2 instance retrieved the image from ECR.



27\. Terraform Initialization



Terraform was initialized using:



terraform init



This initialized the Terraform working directory and downloaded the required AWS provider.



The AWS provider was configured using:



\~> 6.0

28\. Terraform Validation



The configuration was validated using:



terraform validate



The Terraform configuration successfully passed validation.



29\. Terraform Plan



The infrastructure was reviewed using:



terraform plan



After configuration and AWS state were reconciled, Terraform reported:



No changes. Your infrastructure matches the configuration.



This confirms that the deployed infrastructure matches the Terraform configuration.



30\. Terraform Apply



The infrastructure was provisioned using:



terraform apply



Terraform successfully provisioned the required infrastructure and configured the EC2 instance.



31\. Terraform Outputs



The final Terraform outputs were:



ec2\_instance\_id = "i-0bd086d14068a8a2b"



ec2\_public\_dns = "ec2-100-31-237-128.compute-1.amazonaws.com"



ec2\_public\_ip = "100.31.237.128"



ecr\_image\_uri = "579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm:latest"



ecr\_repository\_url = "579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm"



iam\_instance\_profile = "EC2ECRPullRole"



subnet\_id = "subnet-078d52bfe579c74f2"



vpc\_id = "vpc-0c241509159132524"



These outputs provide convenient access to the important infrastructure details.



32\. Terraform Final Verification



The final Terraform plan returned:



No changes. Your infrastructure matches the configuration.



This confirms:



Terraform state is synchronized with AWS.

No unexpected infrastructure drift was detected.

No additional resources need to be created.

No resources need to be destroyed.

The infrastructure matches the Terraform configuration.

33\. Issues Encountered and Resolutions

33.1 Limited EC2 Memory

Issue



The t3.small instance has limited memory and the Twenty CRM application created significant memory pressure.



The instance type could not be upgraded because only t3.small was authorized.



Resolution



A 2 GiB swap file was added through EC2 User Data.



The swap configuration was successfully verified on the running EC2 instance.



33.2 EC2 Volume Modification Permission

Issue



Terraform initially attempted to modify an existing EC2 volume.



AWS returned an authorization error related to:



ec2:ModifyVolume

Resolution



The EC2 configuration was changed to create a replacement instance with the required 20 GiB root volume.



The following Terraform lifecycle configuration was used:



lifecycle {

&#x20; create\_before\_destroy = true

}



This allowed Terraform to create the required EC2 configuration without requiring an in-place volume modification.



33.3 ECR Image Initially Unavailable

Issue



The EC2 instance successfully authenticated with ECR, but the Docker image was initially unavailable in the repository.



The User Data script therefore continued retrying the Docker pull.



Resolution



The local Twenty CRM image was tagged and pushed to the Terraform-managed ECR repository.



Once the image became available, the EC2 User Data retry mechanism successfully pulled the image and started the container.



33.4 Docker ECR Authentication

Issue



An initial Docker ECR authentication attempt returned an authentication error.



Resolution



A fresh ECR authorization password was generated using:



aws ecr get-login-password --region us-east-1



The Docker login was then successfully completed.



Result:



Login Succeeded



The image was subsequently pushed successfully.



34\. Security Considerations



No AWS credentials, access keys, passwords, private keys, or other secrets are stored in the Terraform source code.



The following files must not be committed:



terraform.tfvars

\*.pem

.env

.env.\*

\*.tfstate

\*.tfstate.\*



The .gitignore file is configured to prevent sensitive and generated files from being committed.



The EC2 instance uses:



EC2ECRPullRole



for ECR authentication and image pulling.



35\. Terraform Destroy



After completing the deployment and verification, the Terraform-managed infrastructure can be removed using:



terraform destroy



Terraform asks for confirmation before deleting the infrastructure.



Enter:



yes



to proceed.



The cleanup demonstrates that the infrastructure can be provisioned and removed through Terraform.



36\. Final Architecture

&#x20;                        AWS Cloud

&#x20;                           |

&#x20;             +-------------+-------------+

&#x20;             |                           |

&#x20;             v                           v

&#x20;      Existing Default VPC          Amazon ECR

&#x20;             |                    twenty-crm:latest

&#x20;             |

&#x20;      Existing Subnet

&#x20;             |

&#x20;             v

&#x20;      Terraform EC2

&#x20;      Ubuntu t3.small

&#x20;      20 GiB GP3

&#x20;      2 GiB Swap

&#x20;             |

&#x20;             |

&#x20;             | IAM Instance Profile

&#x20;             | EC2ECRPullRole

&#x20;             |

&#x20;             v

&#x20;      ECR Authentication

&#x20;             |

&#x20;             v

&#x20;         Docker Pull

&#x20;             |

&#x20;             v

&#x20;      Twenty CRM Container

&#x20;             |

&#x20;             | Port 2020

&#x20;             v

&#x20;      Public Web Access

&#x20;             |

&#x20;             v

&#x20;      Twenty CRM Browser UI

37\. Complete Deployment Flow

Terraform Configuration

&#x20;         |

&#x20;         v

terraform init

&#x20;         |

&#x20;         v

terraform validate

&#x20;         |

&#x20;         v

terraform plan

&#x20;         |

&#x20;         v

terraform apply

&#x20;         |

&#x20;         v

AWS EC2 + ECR + Security Group

&#x20;         |

&#x20;         v

EC2 User Data

&#x20;         |

&#x20;         v

Install Docker + AWS CLI

&#x20;         |

&#x20;         v

Authenticate with ECR

&#x20;         |

&#x20;         v

Pull Twenty CRM Image

&#x20;         |

&#x20;         v

Run Docker Container

&#x20;         |

&#x20;         v

Expose Port 2020

&#x20;         |

&#x20;         v

Twenty CRM

&#x20;         |

&#x20;         v

Browser Verification

&#x20;         |

&#x20;         v

HTTP Health Check

&#x20;         |

&#x20;         v

Final terraform plan

&#x20;         |

&#x20;         v

No Changes

&#x20;         |

&#x20;         v

terraform destroy

38\. Final Verification Checklist

Terraform

&#x20;Terraform project structure created

&#x20;AWS provider configured

&#x20;AWS region configured as us-east-1

&#x20;Existing/default VPC discovered

&#x20;Existing/default subnet discovered

&#x20;Terraform variables configured

&#x20;Terraform outputs configured

&#x20;terraform init completed

&#x20;terraform validate completed

&#x20;terraform plan completed

&#x20;terraform apply completed

&#x20;Final Terraform plan returned no changes

AWS

&#x20;EC2 instance created

&#x20;t3.small instance type used

&#x20;20 GiB root volume configured

&#x20;GP3 volume verified

&#x20;Existing IAM instance profile used

&#x20;Security Group configured

&#x20;SSH port 22 configured

&#x20;Twenty CRM port 2020 configured

&#x20;Existing/default VPC used

&#x20;Existing/default subnet used

ECR

&#x20;ECR repository managed with Terraform

&#x20;Twenty CRM image tagged for ECR

&#x20;ECR authentication completed

&#x20;Docker image pushed successfully

&#x20;latest image tag verified

&#x20;Image status verified as ACTIVE

&#x20;Image digest verified

&#x20;EC2 successfully pulled the image

Docker

&#x20;Docker installed through User Data

&#x20;Docker daemon started

&#x20;Twenty CRM container created

&#x20;Twenty CRM container running

&#x20;Port 2020 mapped

&#x20;Container restart policy configured

Application

&#x20;Twenty CRM started successfully

&#x20;Twenty CRM browser UI verified

&#x20;Companies page loaded

&#x20;curl localhost:2020 returned HTTP 200

&#x20;Application accessible through EC2 public IP

Memory

&#x20;2 GiB swap configured

&#x20;Swap verified using free -h

&#x20;Swap verified using swapon --show

Cleanup

&#x20;terraform destroy completed

&#x20;AWS resources verified as cleaned up

39\. Evidence and Screenshots



The following evidence should be included in the final Task 12 submission/report:



Terraform project structure

terraform init

terraform validate

terraform plan

terraform apply

Terraform outputs

Running EC2 instance

EC2 SSH connection

EC2 Security Group

EC2 20 GiB root volume

ECR repository

ECR image

Docker image push

Running Docker container

Twenty CRM browser interface

curl localhost:2020 showing HTTP 200

free -h showing 2 GiB swap

swapon --show

Final Terraform plan showing:

No changes. Your infrastructure matches the configuration.

terraform destroy and AWS cleanup verification

40\. Key Infrastructure Values

Resource	Value

AWS Region	us-east-1

VPC	vpc-0c241509159132524

Subnet	subnet-078d52bfe579c74f2

EC2 Instance	i-0bd086d14068a8a2b

EC2 Type	t3.small

AMI	ami-0b6d9d3d33ba97d99

Root Volume	20 GiB GP3

IAM Profile	EC2ECRPullRole

ECR Repository	twenty-crm

ECR URI	579138738751.dkr.ecr.us-east-1.amazonaws.com/twenty-crm

Docker Image	twentycrm/twenty-app-dev:v2.35

ECR Image Tag	latest

Application Port	2020

EC2 Public IP	100.31.237.128

Swap	2 GiB

41\. Conclusion



Task 12 successfully demonstrates Infrastructure as Code using Terraform to provision and manage an AWS-based Twenty CRM deployment.



Terraform was used to manage:



EC2

ECR

Security Group

Existing VPC and subnet references

Variables

Outputs

EC2 User Data

Application bootstrap configuration



The complete deployment workflow was successfully demonstrated:



Terraform

&#x20;   ↓

AWS EC2

&#x20;   ↓

IAM Instance Profile

&#x20;   ↓

Amazon ECR

&#x20;   ↓

Docker

&#x20;   ↓

Twenty CRM

&#x20;   ↓

Port 2020

&#x20;   ↓

Browser



The Docker image was successfully pushed to Amazon ECR.



The Terraform-created EC2 instance successfully authenticated with ECR, pulled the image, and started the Twenty CRM container.



The application was successfully verified through the browser at:



http://100.31.237.128:2020



The internal application health check also returned:



HTTP/1.1 200 OK



The EC2 instance was verified with a 20 GiB GP3 root volume and a 2 GiB swap configuration.



Finally, Terraform reported:



No changes. Your infrastructure matches the configuration.



This confirms that the deployed AWS infrastructure was synchronized with the Terraform configuration and that the Task 12 infrastructure was successfully implemented and verified.


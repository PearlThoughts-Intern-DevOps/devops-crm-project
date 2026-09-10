\# Task 13 — Twenty CRM + AWS S3 using Terraform



\## 1. Objective



Deploy Twenty CRM on an AWS EC2 instance and configure Amazon S3 as the storage backend, with all infrastructure provisioned using Terraform.



The deployment uses:



\- AWS Region: `us-east-1`

\- Existing/default VPC

\- Existing subnet

\- EC2: `t3.small`

\- Approved Ubuntu AMI

\- Existing IAM instance profile: `EC2S3AccessRole`

\- Amazon S3

\- Docker

\- Twenty CRM



No IAM users, roles, or policies were created.



\---



\## 2. Architecture



```text

&#x20;                   AWS

&#x20;                    |

&#x20;             Existing Default VPC

&#x20;                    |

&#x20;             Existing Subnet

&#x20;                    |

&#x20;             +--------------+

&#x20;             | EC2 t3.small |

&#x20;             |              |

&#x20;             | Docker       |

&#x20;             | Twenty CRM   |

&#x20;             +------+-------+

&#x20;                    |

&#x20;             EC2S3AccessRole

&#x20;                    |

&#x20;                    v

&#x20;             +--------------+

&#x20;             |   Amazon S3  |

&#x20;             |              |

&#x20;             | Versioning    |

&#x20;             | Encryption    |

&#x20;             | Private       |

&#x20;             +--------------+

3\. Terraform Project Structure

Task-13-Terraform/

├── .gitignore

├── README.md

├── ec2.tf

├── outputs.tf

├── provider.tf

├── s3.tf

├── terraform.tfvars.example

└── variables.tf



Terraform state files and the actual terraform.tfvars file are excluded from Git.



4\. AWS Provider



Terraform is configured for:



Region: us-east-1



The AWS provider uses Terraform default tags for consistent resource tagging.



5\. Existing VPC and Subnet



The existing default VPC and subnet are referenced using Terraform data sources.



No new VPC or subnet is created.



VPC:



vpc-0c241509159132524



Subnet:



subnet-078d52bfe579c74f2

6\. EC2 Configuration



Terraform provisions one EC2 instance.



Configuration:



Instance Type: t3.small

AMI: ami-0b6d9d3d33ba97d99

Key Pair: puneet-90

Root Volume: 20 GiB GP3

IAM Instance Profile: EC2S3AccessRole



The EC2 instance receives a public IP for accessing Twenty CRM.



7\. Security Group



The Terraform-managed security group allows:



Port	Protocol	Purpose

22	TCP	SSH

2020	TCP	Twenty CRM



Outbound traffic is allowed for required application and AWS connectivity.



8\. IAM Configuration



The existing IAM instance profile:



EC2S3AccessRole



is attached to the EC2 instance.



No IAM users, roles, or policies were created by Terraform.



The EC2 instance was verified using:



aws sts get-caller-identity



The returned identity showed:



assumed-role/EC2S3AccessRole/



This confirmed that EC2 was operating using the provided IAM role.



9\. S3 Configuration



Terraform creates one S3 bucket:



twenty-crm-puneet-task13-579138738751



The bucket configuration includes:



Block Public Access



All four public access protections are enabled:



BlockPublicAcls       = true

IgnorePublicAcls      = true

BlockPublicPolicy     = true

RestrictPublicBuckets = true

Versioning

Enabled

Server-Side Encryption

AES256

Force Destroy

force\_destroy = true



This allows Terraform to remove the bucket and its objects during terraform destroy.



10\. Twenty CRM Docker Deployment



The EC2 User Data automatically:



Configures 2 GiB swap.

Updates Ubuntu packages.

Installs Docker.

Installs AWS CLI.

Starts Docker.

Verifies S3 access using the EC2 IAM role.

Pulls the Twenty CRM Docker image.

Configures Twenty CRM to use S3.

Starts the Twenty CRM container.



Docker image:



twentycrm/twenty-app-dev:v2.35



Twenty CRM container:



twenty-crm



Application port:



2020

11\. Twenty CRM S3 Configuration



Twenty CRM is configured with:



STORAGE\_TYPE=S3

STORAGE\_S3\_REGION=us-east-1

STORAGE\_S3\_NAME=twenty-crm-puneet-task13-579138738751

STORAGE\_S3\_ENDPOINT=https://s3.us-east-1.amazonaws.com



The EC2 instance uses its IAM role instead of hard-coded AWS credentials.



12\. Terraform Commands

Initialize

terraform init

Format

terraform fmt

Validate

terraform validate

Plan

terraform plan

Apply

terraform apply

View outputs

terraform output

View state

terraform state list

Destroy

terraform destroy

13\. Terraform Verification



Terraform successfully completed:



terraform init

terraform validate

terraform plan

terraform apply



The apply result was:



Apply complete! Resources: 6 added, 0 changed, 0 destroyed.



The final plan before deployment showed:



Plan: 6 to add, 0 to change, 0 to destroy.

14\. AWS CLI S3 Verification

Versioning



Command:



aws s3api get-bucket-versioning \\

&#x20; --bucket twenty-crm-puneet-task13-579138738751 \\

&#x20; --region us-east-1



Result:



{

&#x20;   "Status": "Enabled"

}

Public Access Block



Result confirmed all four protections were enabled:



BlockPublicAcls       = true

IgnorePublicAcls      = true

BlockPublicPolicy     = true

RestrictPublicBuckets = true

Encryption



Result:



SSEAlgorithm = AES256

15\. EC2 S3 Access Verification



From the EC2 instance:



aws sts get-caller-identity



Confirmed:



assumed-role/EC2S3AccessRole/



S3 access was tested using:



aws s3api head-bucket \\

&#x20; --bucket twenty-crm-puneet-task13-579138738751 \\

&#x20; --region us-east-1



The bucket was successfully accessible.



The following command also confirmed access:



aws s3 ls s3://twenty-crm-puneet-task13-579138738751/

16\. Docker Verification



Docker service was verified as active.



Twenty CRM container:



CONTAINER: twenty-crm

IMAGE: twentycrm/twenty-app-dev:v2.35

PORT: 0.0.0.0:2020->2020/tcp

STATUS: Up



Twenty CRM was successfully accessible through the EC2 public IP on port 2020.



17\. Outputs



Example Terraform outputs:



ec2\_instance\_id

ec2\_public\_dns

ec2\_public\_ip

iam\_instance\_profile

s3\_bucket\_arn

s3\_bucket\_name

subnet\_id

twenty\_crm\_image

vpc\_id

18\. Cleanup



After testing, Terraform destroy was executed.



Result:



Destroy complete! Resources: 6 destroyed.



The destroyed resources included:



EC2 instance

Security group

S3 bucket

S3 versioning configuration

S3 encryption configuration

S3 public access block

19\. Cleanup Verification

EC2



AWS CLI returned:



terminated

S3



The following command:



aws s3api head-bucket \\

&#x20; --bucket twenty-crm-puneet-task13-579138738751 \\

&#x20; --region us-east-1



returned:



404 Not Found



confirming that the S3 bucket had been deleted.



Terraform State

terraform state list



returned no managed resources.



Therefore, all Terraform-created infrastructure was successfully removed.



20\. Issues and Resolutions

S3 Bucket Cleanup



Because Twenty CRM can create objects in S3, a normal bucket deletion can fail when the bucket is not empty.



The Terraform S3 bucket was therefore configured with:



force\_destroy = true



This allowed Terraform to remove the bucket and its objects during cleanup.



EC2 Memory



Twenty CRM can consume significant memory on a small EC2 instance.



A 2 GiB swap file was configured through EC2 User Data to improve stability on the t3.small instance.



21\. Security Considerations

No AWS credentials were hard-coded.

EC2 uses the provided IAM instance profile.

S3 public access is completely blocked.

S3 server-side encryption is enabled.

S3 versioning is enabled.

terraform.tfvars is excluded from Git.

No IAM users, roles, or policies were created by Terraform.

22\. Task 13 Checklist

&#x20;Terraform project created

&#x20;AWS region us-east-1

&#x20;Existing/default VPC used

&#x20;Existing subnet used

&#x20;One t3.small EC2 created

&#x20;Approved AMI used

&#x20;20 GiB GP3 root volume

&#x20;Existing EC2S3AccessRole attached

&#x20;No IAM resources created

&#x20;S3 bucket created

&#x20;S3 Block Public Access enabled

&#x20;S3 versioning enabled

&#x20;S3 encryption enabled

&#x20;Twenty CRM deployed with Docker

&#x20;Twenty CRM configured for S3

&#x20;EC2 S3 access verified

&#x20;Twenty CRM application verified

&#x20;Terraform init completed

&#x20;Terraform validate completed

&#x20;Terraform plan completed

&#x20;Terraform apply completed

&#x20;Terraform destroy completed

&#x20;EC2 cleanup verified

&#x20;S3 cleanup verified

&#x20;Terraform state cleaned

23\. Conclusion



Task 13 successfully demonstrated Infrastructure as Code deployment of Twenty CRM on AWS EC2 with Amazon S3 configured as the storage backend.



Terraform provisioned the required infrastructure, EC2 accessed S3 using the provided IAM role, Twenty CRM ran successfully through Docker, and all Terraform-created resources were successfully destroyed after testing.


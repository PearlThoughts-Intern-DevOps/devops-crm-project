\# Task 15 – AWS Application Load Balancer with Terraform



\## Overview



This task implements an AWS Application Load Balancer (ALB) architecture for Twenty CRM using Terraform.



The infrastructure is designed to:



\- Use the existing AWS default VPC.

\- Deploy Twenty CRM on an EC2 instance.

\- Create an Application Load Balancer.

\- Create a dedicated target group for the EC2 instance.

\- Configure an HTTP listener on port 80.

\- Configure security groups for ALB and EC2.

\- Configure an HTTP health check for Twenty CRM.

\- Register the EC2 instance with the target group.

\- Access Twenty CRM through the ALB.

\- Provision infrastructure using Terraform.

\- Destroy the infrastructure after testing.



\---



\## Architecture



```text

&#x20;                   Internet

&#x20;                      |

&#x20;                      | HTTP :80

&#x20;                      v

&#x20;            +----------------------+

&#x20;            | Application Load     |

&#x20;            | Balancer             |

&#x20;            | twenty-crm-task15    |

&#x20;            +----------+-----------+

&#x20;                       |

&#x20;                       | HTTP :3000

&#x20;                       v

&#x20;            +----------------------+

&#x20;            | Target Group         |

&#x20;            | twenty-crm-task15-tg |

&#x20;            +----------+-----------+

&#x20;                       |

&#x20;                       v

&#x20;            +----------------------+

&#x20;            | EC2 Instance         |

&#x20;            | t3.small             |

&#x20;            | Twenty CRM            |

&#x20;            | Docker :3000         |

&#x20;            +----------------------+

AWS Region

Region: us-east-1

EC2 Configuration

Configuration	Value

Instance Type	t3.small

AMI	ami-081b0a6eac00b4f53

Application Port	3000

Root Volume	20 GB gp3

Encryption	Enabled

VPC	Existing default VPC

Terraform Structure

task15/

├── main.tf

├── variables.tf

├── outputs.tf

├── versions.tf

└── terraform.tfvars

versions.tf



Defines the required Terraform version and AWS provider.



variables.tf



Defines configurable values such as:



AWS region

Project name

AMI ID

EC2 instance type

Application port

Root volume size

main.tf



Creates:



Default VPC data source

Default subnet data source

ALB security group

EC2 security group

Application Load Balancer

Target group

HTTP listener

EC2 instance

Target group attachment

outputs.tf



Provides:



ALB URL

ALB DNS name

Target group ARN

EC2 instance ID

EC2 public IP

Security Groups

ALB Security Group



The ALB security group allows HTTP traffic from the internet.



Inbound:

TCP 80 from 0.0.0.0/0



Outbound:

All traffic

EC2 Security Group



The EC2 security group allows Twenty CRM traffic only from the ALB security group.



Inbound:

TCP 3000 from ALB security group



Outbound:

All traffic



This prevents direct application traffic from arbitrary sources while allowing the ALB to communicate with Twenty CRM.



Application Load Balancer



The ALB is configured as an internet-facing Application Load Balancer.



Name: twenty-crm-task15-alb

Type: Application Load Balancer

Protocol: HTTP

Port: 80



The ALB uses two subnets from the existing default VPC.



Target Group



The target group is configured for EC2 instances.



Name: twenty-crm-task15-tg

Target Type: instance

Protocol: HTTP

Port: 3000

Health Check



The target group health check uses:



Protocol: HTTP

Path: /

Port: traffic-port

Interval: 15 seconds

Timeout: 5 seconds

Healthy Threshold: 2

Unhealthy Threshold: 3

Expected Status: 200

ALB Listener



The ALB listener listens on HTTP port 80.



Listener:

HTTP :80



Action:

Forward traffic to twenty-crm-task15-tg

Twenty CRM Deployment



The EC2 user data installs:



docker.io

docker-compose-v2

curl



Docker is enabled and started automatically.



Twenty CRM is configured using Docker Compose with:



Twenty CRM

PostgreSQL 16

Redis 7 Alpine



The application is exposed internally on:



EC2:3000



The ALB is intended to provide external access on:



ALB:80

Terraform Commands

1\. Initialize Terraform

terraform init



Expected:



Terraform has been successfully initialized!

2\. Format Terraform

terraform fmt



Terraform formats the configuration files.



3\. Validate Configuration

terraform validate



Expected:



Success! The configuration is valid.

4\. Create Terraform Plan

terraform plan



The configuration successfully generated a Terraform plan.



The planned infrastructure included the EC2 instance and target group attachment after the ALB infrastructure had already been provisioned.



Terraform Apply Verification



Terraform successfully communicated with AWS and provisioned the ALB-related resources.



The ALB listener was successfully created:



aws\_lb\_listener.http: Creation complete



The listener configuration was:



Port: 80

Protocol: HTTP

Action: Forward

Target Group: twenty-crm-task15-tg



However, EC2 creation was blocked by an AWS IAM restriction in the KodeKloud playground account.



IAM Restriction Encountered



During Terraform apply, AWS returned:



StatusCode: 403

UnauthorizedOperation



The specific denied operation was:



ec2:RunInstances



AWS reported that the operation was explicitly denied by:



AWS\_CW\_CT\_Logs\_Shell\_QWithConditions



The affected identity was:



arn:aws:iam::547914434401:user/kk\_labs\_user\_259440



The AWS account was:



547914434401



This is an explicit identity-based IAM deny in the temporary KodeKloud playground environment.



Because EC2 creation was denied, the following verification steps could not be completed in this environment:



EC2 instance running Twenty CRM

Target registered and healthy

Twenty CRM accessed through the ALB



No IAM policies or roles were modified as part of this task.



IAM Evidence



The AWS identity was verified using:



aws sts get-caller-identity



Output:



Account: 547914434401

User: kk\_labs\_user\_259440



The restricted policy was also inspected:



aws iam get-policy \\

&#x20; --policy-arn arn:aws:iam::547914434401:policy/AWS\_CW\_CT\_Logs\_Shell\_QWithConditions



The policy was confirmed to exist and have one attachment.



Resource Cleanup



After the failed EC2 provisioning attempt, Terraform was used to clean up the resources created by the Task 15 configuration.



Command:



terraform destroy -auto-approve



Result:



Destroy complete! Resources: 5 destroyed.



The cleanup removed:



Application Load Balancer

ALB listener

Target group

ALB security group

EC2 security group



No EC2 instance was created because ec2:RunInstances was denied.



Final Verification



The following command was used to verify that no ALBs remained:



aws elbv2 describe-load-balancers \\

&#x20; --region us-east-1 \\

&#x20; --query 'LoadBalancers\[].{Name:LoadBalancerName,State:State.Code}' \\

&#x20; --output table



No load balancers were returned.



EC2 verification:



aws ec2 describe-instances \\

&#x20; --region us-east-1 \\

&#x20; --query 'Reservations\[].Instances\[].{ID:InstanceId,State:State.Name}' \\

&#x20; --output table



No EC2 instances were returned.



Conclusion



Task 15 infrastructure was implemented using Terraform with an Application Load Balancer, target group, listener, security groups, and EC2 deployment configuration.



Terraform initialization, formatting, validation, planning, and ALB provisioning were successful.



The final EC2 deployment and application-level ALB verification were blocked by an explicit ec2:RunInstances deny in the temporary KodeKloud playground IAM policy.



The environment was cleaned up using Terraform destroy after testing.



No IAM roles, users, or policies were created or modified.






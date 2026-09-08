\# Task 10 - AWS Observability with CloudWatch



\## 1. Objective



The objective of this task was to deploy Twenty CRM on an AWS EC2 instance and configure Amazon CloudWatch monitoring for CPU, memory, and disk utilization. CloudWatch alarms and a dashboard were also created to monitor the EC2 instance.



\---



\## 2. AWS EC2 Instance



The EC2 instance was launched using Amazon Linux 2023.



| Configuration | Details |

|---|---|

| Instance ID | `i-0b28dff40d8507c85` |

| Instance Type | `t3.small` |

| Operating System | Amazon Linux 2023 |

| Public IP | `54.227.110.20` |

| Private IP | `172.31.23.83` |

| IAM Role | `CloudWatchAgentEC2Role` |

| Region | `us-east-1` |



The existing `CloudWatchAgentEC2Role` IAM role was attached to the EC2 instance as required. No new IAM user or role was created.



\---



\## 3. EC2 Connection



The EC2 instance was accessed using SSH from Windows PowerShell.



```bash

ssh -i "karthikeyan-key.pem" ec2-user@ec2-54-227-110-20.compute-1.amazonaws.com

The connection was verified using:



whoami



Output:



ec2-user

4\. Docker Installation



Docker was installed and started on the EC2 instance.



sudo dnf install -y docker

sudo systemctl start docker

sudo systemctl enable docker

sudo usermod -aG docker ec2-user



Docker version was verified:



docker --version



Docker was successfully running on the EC2 instance.



5\. Twenty CRM Deployment



Twenty CRM was deployed using Docker Compose.



The application was configured with:



PostgreSQL database

Redis

Twenty CRM application

Host port 2020

Container port 3000



The containers were started using:



docker-compose up -d



Running containers were verified using:



docker ps



The Twenty CRM application container and its supporting PostgreSQL and Redis containers were running successfully.



6\. CloudWatch Agent Installation



The Amazon CloudWatch Agent was installed using:



sudo dnf install -y amazon-cloudwatch-agent



Installed version:



amazon-cloudwatch-agent-1.300069.1-1.amzn2023.x86\_64

7\. CloudWatch Agent Configuration



A custom CloudWatch Agent configuration was created at:



/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json



The configuration collects CPU, memory, and disk utilization metrics.



{

&#x20; "metrics": {

&#x20;   "namespace": "CWAgent",

&#x20;   "metrics\_collected": {

&#x20;     "cpu": {

&#x20;       "measurement": \[

&#x20;         "cpu\_usage\_idle",

&#x20;         "cpu\_usage\_user",

&#x20;         "cpu\_usage\_system"

&#x20;       ],

&#x20;       "metrics\_collection\_interval": 60,

&#x20;       "totalcpu": true

&#x20;     },

&#x20;     "mem": {

&#x20;       "measurement": \[

&#x20;         "mem\_used\_percent"

&#x20;       ],

&#x20;       "metrics\_collection\_interval": 60

&#x20;     },

&#x20;     "disk": {

&#x20;       "measurement": \[

&#x20;         "used\_percent"

&#x20;       ],

&#x20;       "metrics\_collection\_interval": 60,

&#x20;       "resources": \[

&#x20;         "/"

&#x20;       ]

&#x20;     }

&#x20;   }

&#x20; }

}



The configuration was loaded using:



sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \\

&#x20; -a fetch-config \\

&#x20; -m ec2 \\

&#x20; -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \\

&#x20; -s



Configuration validation completed successfully.



8\. CloudWatch Agent Verification



The CloudWatch Agent service was checked using:



sudo systemctl status amazon-cloudwatch-agent --no-pager



The service was confirmed as:



Active: active (running)



Agent logs were checked using:



sudo tail -30 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log



The logs confirmed that the agent started successfully and began collecting and publishing metrics.



9\. CloudWatch Metrics



The CloudWatch CWAgent namespace was verified in the AWS CloudWatch console.



The following metrics were configured:



CPU utilization

Memory utilization

Disk utilization



The mem\_used\_percent metric was successfully visible in CloudWatch.



The default EC2 metrics such as:



CPUUtilization

NetworkIn

NetworkOut



were also available.



10\. CloudWatch Alarms



Two CloudWatch alarms were created.



CPU Alarm



Alarm name:



Task10-EC2-High-CPU



Condition:



CPU utilization > 70%



Evaluation period:



1 datapoint within 1 minute

Memory Alarm



Alarm name:



Task10-EC2-High-Memory



Condition:



Memory utilization > 80%



Evaluation period:



1 datapoint within 1 minute



Both alarms were successfully created and were in the OK state after testing.



SNS notification configuration could not be completed because the provided IAM permissions did not allow listing SNS topics. The CloudWatch alarms themselves were created successfully.



11\. CloudWatch Dashboard



A CloudWatch dashboard was created with the name:



karthikeyan-Task10



The dashboard contains monitoring widgets for:



EC2 CPU utilization

EC2 memory utilization

Network In

Network Out

High CPU alarm

High Memory alarm



The dashboard was saved successfully and used to monitor the EC2 instance from a single view.



12\. Server Activity / Load Testing



Server activity was generated on the EC2 instance to observe CPU utilization changes.



The following command was used:



yes > /dev/null \&



The running process was checked using:



top



The yes process generated significant CPU activity and was visible in the top output.



After testing, the process was stopped using:



kill <PID>



The process was verified as stopped using:



ps -p <PID>



This demonstrated that server activity can be generated and monitored through CloudWatch.



13\. Troubleshooting

Issue 1 - Docker Compose Plugin



The Docker Compose plugin was not available through the default package repository.



Solution:



Standalone Docker Compose was installed:



sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86\_64" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose



Version verification:



docker-compose version

Issue 2 - Docker Socket Permission



The ec2-user initially did not have permission to access the Docker socket.



Solution:



sudo usermod -aG docker ec2-user



The SSH session was restarted and Docker commands were then available without sudo.



Issue 3 - CloudWatch CLI Permissions



The EC2 IAM role did not have permission for some CloudWatch management APIs such as:



cloudwatch:ListMetrics

cloudwatch:PutMetricAlarm



Therefore, metric and alarm creation that required these API permissions was performed through the CloudWatch console.



The existing CloudWatchAgentEC2Role was not modified and no new IAM role was created.



Issue 4 - SNS Permissions



While configuring alarm notifications, the AWS account returned an SNS permission error because the IAM user did not have permission to list SNS topics.



The alarms were still created successfully and their alarm states could be monitored in CloudWatch.



14\. Verification Summary



The following items were successfully verified:



EC2 instance launched and running

SSH connection successful

Docker installed and running

Twenty CRM containers deployed

CloudWatch Agent installed

CloudWatch Agent service running

CPU metrics configured

Memory metrics configured

Disk metrics configured

CWAgent namespace visible

Memory metric visible in CloudWatch

CPU alarm created

Memory alarm created

Both alarms in OK state

CloudWatch dashboard created

Server CPU activity generated and monitored

15\. Evidence / Screenshots



The following screenshots were captured as evidence for the task:



EC2 Instance Details showing instance ID, instance type, public IP and IAM role.

CloudWatch mem\_used\_percent metric.

CloudWatch Alarms page showing CPU and Memory alarms.

CloudWatch dashboard karthikeyan-Task10.

EC2 terminal showing CPU activity using top.



Screenshots are stored in the project repository under:



task-10/screenshots



16\. Conclusion



AWS CloudWatch observability was successfully implemented for the Twenty CRM EC2 environment.



The CloudWatch Agent was configured to collect CPU, memory, and disk utilization metrics. CloudWatch alarms were created for high CPU and memory usage, and a dedicated dashboard was created to provide centralized monitoring of the EC2 instance.



The testing demonstrated how application/server activity can be monitored using CloudWatch metrics and alarms.



After completing the required evidence and documentation, the EC2 instance should be terminated to avoid unnecessary AWS resource usage.



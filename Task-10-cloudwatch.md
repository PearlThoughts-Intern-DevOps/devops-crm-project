Task 10 — AWS Observability for Twenty CRM



1\. Objective



Deploy Twenty CRM on Amazon EC2 and implement observability using Amazon CloudWatch.



Completed:



EC2 setup and SSH access through Windows PowerShell



Docker and Docker Compose installation



Git, NVM, Node.js 24.5.0 and Yarn 4.13.0 setup



Twenty CRM deployment and health verification



CloudWatch Agent installation and configuration



CPU, memory and disk monitoring



High CPU and High Memory CloudWatch alarms



CloudWatch dashboard



Controlled CPU load testing



Alarm trigger and recovery verification



EC2 cleanup/termination



2\. AWS Environment



Region: us-east-1 (US East - N. Virginia)

OS: Amazon Linux 2023

Application: Twenty CRM

Application port: 2020

Repository: https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git



Fill in final EC2 details:



Instance Name: Twenty-server	

Instance ID: Amazon Linux

Instance Type:T3.small

Public IPv4:

Private IPv4:

Region:us-east-1



3\. Security Group



Required inbound access:



Type



Port



Source



Purpose



SSH



22



My IP



EC2 administration



Custom TCP



2020



My IP



Twenty CRM



Only required ports should be exposed. SSH should not remain open to 0.0.0.0/0.



4\. EC2 Setup



Connect from Windows PowerShell:



cd "C:\\Users\\Puneet Rathore\\Downloads"

ssh -i ".\\lugel (1).pem" ec2-user@YOUR\_PUBLIC\_IP



Update the system and install Git:



sudo dnf update -y

sudo dnf install -y git

git --version



5\. Docker



Install and start Docker:



sudo dnf install -y docker

sudo systemctl enable --now docker

sudo systemctl status docker --no-pager



Test Docker:



sudo docker run --rm hello-world



Allow ec2-user to use Docker:



sudo usermod -aG docker ec2-user



Exit SSH and reconnect, then verify:



groups

docker ps



6\. Docker Compose



Install the Docker Compose CLI plugin:



sudo mkdir -p /usr/local/lib/docker/cli-plugins



sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86\_64 -o /usr/local/lib/docker/cli-plugins/docker-compose



sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose



docker compose version



7\. Node.js and Yarn



Install NVM:



curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

source \~/.bashrc

nvm --version



Install the project Node version:



nvm install 24.5.0

nvm use 24.5.0

nvm alias default 24.5.0

node --version



Install Yarn 4.13.0:



corepack enable

corepack prepare yarn@4.13.0 --activate

yarn --version



8\. Clone and Deploy Twenty CRM



cd \~

git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git

cd devops-crm-project

yarn install



Start Twenty CRM:



yarn twenty docker:start



Verify the container:



docker ps



Verify the health endpoint:



curl -I http://localhost:2020/healthz



Expected:



HTTP/1.1 200 OK



Twenty CRM was successfully started with:



Server running on http://localhost:2020



9\. CloudWatch IAM Role



An IAM role named:



CloudWatchAgentServerRole



was attached to the EC2 instance.



The role uses:



CloudWatchAgentServerPolicy



This provides the permissions required for the CloudWatch Agent to publish metrics.



10\. CloudWatch Agent



Install:



sudo dnf install -y amazon-cloudwatch-agent



Configuration used:



{

&#x20; "agent": {

&#x20;   "metrics\_collection\_interval": 60,

&#x20;   "region": "us-east-1"

&#x20; },

&#x20; "metrics": {

&#x20;   "namespace": "CWAgent",

&#x20;   "append\_dimensions": {

&#x20;     "InstanceId": "${aws:InstanceId}"

&#x20;   },

&#x20;   "metrics\_collected": {

&#x20;     "cpu": {

&#x20;       "resources": \["\*"],

&#x20;       "measurement": \[

&#x20;         "usage\_active",

&#x20;         "usage\_system",

&#x20;         "usage\_user"

&#x20;       ],

&#x20;       "totalcpu": true

&#x20;     },

&#x20;     "mem": {

&#x20;       "measurement": \["used\_percent"]

&#x20;     },

&#x20;     "disk": {

&#x20;       "resources": \["/"],

&#x20;       "measurement": \["used\_percent"]

&#x20;     }

&#x20;   }

&#x20; }

}



The agent was started with:



sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s



Verify:



sudo systemctl status amazon-cloudwatch-agent --no-pager



Expected:



Active: active (running)



Check logs:



sudo tail -30 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log



11\. CloudWatch Metrics



Namespace:



CWAgent



Collected metrics:



Metric



Purpose



cpu\_usage\_active



CPU utilization



mem\_used\_percent



Memory utilization



disk\_used\_percent



Root filesystem disk utilization



All three metrics were verified in CloudWatch and displayed datapoints for the EC2 instance.



12\. CPU Alarm



Alarm:



Puneet-TwentyCRM-HighCPU



Configuration:



Metric: cpu\_usage\_active

Statistic: Average

Period: 1 minute

Threshold: > 70%

Evaluation periods: 2

Datapoints to alarm: 2



Condition:



cpu\_usage\_active > 70%

for 2 out of 2 datapoints within 2 minutes



13\. Memory Alarm



Alarm:



Puneet-TwentyCRM-HighMemory



Configuration:



Metric: mem\_used\_percent

Statistic: Average

Period: 1 minute

Threshold: > 80%

Evaluation periods: 2

Datapoints to alarm: 2



Condition:



mem\_used\_percent > 80%

for 2 out of 2 datapoints within 2 minutes



14\. CloudWatch Dashboard



Dashboard:



Puneet-TwentyCRM-Observability



Metrics widget:



cpu\_usage\_active

mem\_used\_percent

disk\_used\_percent



Alarm widget:



Puneet-TwentyCRM-HighCPU

Puneet-TwentyCRM-HighMemory



The dashboard provides centralized visibility into EC2 resource utilization and alarm states.



15\. Testing



A controlled CPU workload was generated using stress-ng.



Install:



sudo dnf install -y stress-ng

stress-ng --version



Run:



stress-ng --cpu 2 --timeout 120s --metrics-brief



The test successfully completed for:



120.00 seconds



and generated CPU load using two CPU workers.



16\. Alarm Trigger Result



During the CPU load test, CloudWatch detected increased CPU utilization.



Observed result:



Puneet-TwentyCRM-HighCPU → ALARM

CPU ≈ 70.45%



This demonstrated that the CloudWatch metric and alarm configuration worked correctly.



17\. Alarm Recovery



After the stress test stopped, CPU utilization returned toward normal levels.



The CPU alarm subsequently returned to:



OK



The memory alarm remained:



OK



Test lifecycle:



Normal

&#x20; ↓

CPU load generated

&#x20; ↓

CPU utilization increased

&#x20; ↓

High CPU alarm → ALARM

&#x20; ↓

CPU load stopped

&#x20; ↓

CPU utilization decreased

&#x20; ↓

High CPU alarm → OK



18\. Troubleshooting



Twenty CRM health failure



Initial startup showed:



Registering cron jobs... Failed

Twenty server did not become healthy in time.



Logs were investigated with:



yarn twenty docker:logs

docker logs --tail 200 twenty-app-dev



The database and Twenty services were eventually initialized successfully. A later startup completed with:



Registering cron jobs... Done

Server running on http://localhost:2020



Health was confirmed with:



curl -I http://localhost:2020/healthz



which returned:



HTTP/1.1 200 OK



Docker permissions



The normal EC2 user initially required sudo for Docker. This was fixed with:



sudo usermod -aG docker ec2-user



The SSH session was reconnected afterward.



Docker Compose package



The Compose plugin was not available through the expected dnf package, so it was installed manually as a Docker CLI plugin.



EC2 replacement



The original Task 10 EC2 instance was terminated. A replacement instance was created and the environment was rebuilt. The final implementation and testing were completed successfully on the replacement instance.



19\. Troubleshooting Commands



Twenty CRM:



docker ps

curl -I http://localhost:2020/healthz

yarn twenty docker:logs



Docker:



docker ps

docker compose version

sudo systemctl status docker --no-pager



CloudWatch Agent:



sudo systemctl status amazon-cloudwatch-agent --no-pager

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status

sudo tail -50 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log



20\. Architecture



&#x20;                Amazon EC2

&#x20;                    |

&#x20;               Twenty CRM

&#x20;                    |

&#x20;             Docker Container

&#x20;                    |

&#x20;                    v

&#x20;            CloudWatch Agent

&#x20;                    |

&#x20;       +------------+------------+

&#x20;       |            |            |

&#x20;      CPU         Memory        Disk

&#x20;       |            |            |

&#x20;       +------------+------------+

&#x20;                    |

&#x20;                    v

&#x20;            CloudWatch Metrics

&#x20;                    |

&#x20;             +------+------+

&#x20;             |             |

&#x20;             v             v

&#x20;         CPU Alarm     Memory Alarm

&#x20;             |             |

&#x20;             +------+------+

&#x20;                    |

&#x20;                    v

&#x20;            CloudWatch Dashboard



21\. Security



SSH should be restricted to My IP.



Twenty CRM port 2020 should be restricted to My IP where appropriate.



Private SSH keys must never be committed to GitHub.



AWS credentials must never be committed to GitHub.



Only required network ports should be exposed.



The EC2 instance must be terminated after the practical.



22\. Screenshots



Place the evidence in:



Task-10-CloudWatch/screenshots/



Recommended files:



01-ec2-instance.png

02-docker-twenty-running.png

03-twenty-health-200.png

04-cloudwatch-agent.png

05-cloudwatch-metrics.png

06-cloudwatch-dashboard.png

07-stress-test.png

08-cpu-alarm-triggered.png

09-alarm-recovery.png

10-ec2-terminated.png



Evidence mapping:



Screenshot



Evidence



01



EC2 configuration



02



Twenty CRM Docker container



03



Twenty CRM HTTP 200 health check



04



CloudWatch Agent running



05



CPU, memory and disk metrics



06



Dashboard and alarms



07



Controlled CPU stress test



08



CPU alarm entered ALARM



09



Alarm recovery



10



EC2 terminated



23\. EC2 Termination



After all testing and screenshots were completed, the Task 10 EC2 instance was terminated to comply with the assigned 2-hour usage window.



Final state:



EC2 Instance: Terminated



24\. GitHub Submission



Required branch:



Puneet-Task-10



Create it:



git checkout main

git pull origin main

git checkout -b Puneet-Task-10



Add documentation:



git add Task-10-CloudWatch



Commit:



git commit -m "Add Task 10 CloudWatch observability documentation"



Push:



git push -u origin Puneet-Task-10



25\. Pull Request



Create a PR in:



devops-crm-project



Base:



main



Compare:



Puneet-Task-10



Suggested title:



Task 10: AWS CloudWatch Observability for Twenty CRM



Suggested description:



\## Task 10: AWS CloudWatch Observability for Twenty CRM



Implemented AWS observability for the Twenty CRM application running on EC2.



\### Completed

\- Configured Amazon Linux EC2

\- Installed Docker and Docker Compose

\- Deployed Twenty CRM

\- Verified Twenty CRM health

\- Attached CloudWatch Agent IAM role

\- Installed and configured CloudWatch Agent

\- Collected CPU, memory, and disk metrics

\- Created High CPU alarm

\- Created High Memory alarm

\- Created CloudWatch dashboard

\- Performed controlled CPU load testing

\- Verified CPU alarm transitioned to ALARM

\- Verified alarm recovery to OK

\- Documented troubleshooting and implementation

\- Terminated the EC2 instance after testing



Documentation and screenshots are included in Task-10-CloudWatch.



26\. Loom Video



The submission must include a Loom video explaining the complete implementation.



The face must remain visible throughout the Loom video while explaining the work.



Recommended sequence:



Introduce yourself and Task 10.



Show EC2 configuration.



Show the Twenty CRM deployment.



Show the Docker container.



Show the Twenty CRM health check.



Explain the CloudWatch Agent.



Show CPU, memory and disk metrics.



Show the CloudWatch dashboard.



Explain the CPU and memory alarms.



Show the stress-ng test.



Show the CPU alarm entering ALARM.



Show the alarm returning to OK.



Explain the troubleshooting performed.



Show the GitHub documentation.



Show the Pull Request.



Confirm the EC2 instance was terminated.



Conclude the demonstration.



27\. Final Result



Twenty CRM was successfully deployed on Amazon EC2 and monitored using Amazon CloudWatch.



The CloudWatch Agent collected CPU, memory and disk metrics. CloudWatch alarms monitored high CPU and high memory conditions. A centralized dashboard displayed the monitored metrics and alarm states.



A controlled CPU workload successfully caused the CPU alarm to enter ALARM at approximately 70.45%, and the alarm recovered to OK after the workload stopped.



The EC2 instance was terminated after completion to comply with the assigned EC2 usage window.



28\. Conclusion



This task demonstrated practical AWS observability for a containerized Twenty CRM application, including EC2 deployment, infrastructure monitoring, metric collection, alerting, dashboard creation, controlled load testing, troubleshooting, alarm recovery, documentation and resource cleanup.


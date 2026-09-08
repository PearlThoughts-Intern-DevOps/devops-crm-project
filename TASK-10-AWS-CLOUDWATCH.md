# Task 10: AWS CloudWatch Observability

## 1. Objective

The objective of this task was to deploy the Twenty CRM application on an AWS EC2 instance and implement monitoring and observability using Amazon CloudWatch.

The implementation includes:

- EC2 deployment
- Twenty CRM deployment using Docker Compose
- CloudWatch default EC2 metrics
- CloudWatch Agent configuration
- CPU, memory and disk monitoring
- CloudWatch dashboard
- CPU utilization alarm
- Application activity testing
- Troubleshooting and verification
- EC2 termination after completion

---

## 2. AWS EC2 Setup

An Ubuntu EC2 instance was launched in the `us-east-1` region.

### Instance Details

- Instance Name: `vasundara-task10`
- Instance Type: `t3.small`
- Operating System: Ubuntu Server 26.04 LTS
- Region: `us-east-1`
- IAM Instance Profile: `CloudWatchAgentEC2Role`
- Storage: 16 GiB gp3
- Instance ID: `i-0a3612288985eaddb`

The instance was accessed through SSH.

---

## 3. Docker Installation

Docker and Docker Compose were installed on the EC2 instance.

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2   Docker was verified using:
docker --version
docker compose version
4. Twenty CRM Deployment

The Twenty CRM source code was cloned from GitHub:

git clone https://github.com/twentyhq/twenty.git

The Docker deployment directory was opened:

cd ~/twenty/packages/twenty-docker

The environment configuration was created:

cp .env.example .env

The server URL was configured for the EC2 public IP.

The encryption key was generated using:

openssl rand -base64 32

The application was started using:

docker compose up -d
Container Verification

The following containers were running:

Twenty Server
PostgreSQL
Redis

Verification:

docker compose ps

The Twenty server was verified locally using:

curl -I http://localhost:3000

The application returned:

HTTP/1.1 200 OK

The Twenty server container was also shown as healthy.

5. Docker Troubleshooting

Initially, Docker returned a permission error:

permission denied while trying to connect to the Docker daemon socket

This was fixed by adding the current user to the Docker group:

sudo usermod -aG docker $USER
newgrp docker

After that, Docker commands worked without requiring sudo.

The Twenty server initially showed an unhealthy status. After the application finished starting, the local HTTP request returned HTTP/1.1 200 OK and the container became healthy.

6. CloudWatch Default EC2 Metrics

Amazon CloudWatch provides default EC2 monitoring metrics such as:

CPU Utilization
Network In
Network Out
Disk activity
Status checks

The EC2 CPU utilization metric was verified in:

AWS Console → CloudWatch → Metrics → EC2

The metric used for the alarm and dashboard was:

CPUUtilization
7. CloudWatch Agent Installation

The CloudWatch Agent was installed using the official AWS Ubuntu package.

The package was downloaded using:

wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

It was installed using:

sudo dpkg -i amazon-cloudwatch-agent.deb

The installed CloudWatch Agent version was:

1.300072.0b1766
8. CloudWatch Agent Configuration

A custom CloudWatch Agent configuration was created at:

/opt/aws/amazon-cloudwatch-agent/etc/config.json

The configuration was designed to collect:

CPU usage
Memory usage
Root disk usage

The main configuration included:

{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "namespace": "CWAgent",
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"],
        "totalcpu": true
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": ["/"]
      }
    }
  }
}
9. Starting the CloudWatch Agent

The agent was started with:

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json \
-s

Configuration validation completed successfully.

The service was verified using:

sudo systemctl status amazon-cloudwatch-agent --no-pager

The service status showed:

Active: active (running)

The CloudWatch Agent control status was also verified:

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status

The status showed:

"status": "running"
"configstatus": "configured"
10. CloudWatch Agent Metrics

The configured custom CloudWatch namespace was:

CWAgent

The configured metrics include:

CPU
cpu_usage_idle
cpu_usage_user
cpu_usage_system
Memory
mem_used_percent
Disk
disk_used_percent

The agent logs were checked to verify that the CloudWatch Agent started correctly and was ready to process and publish metrics.

11. CloudWatch Dashboard

A CloudWatch dashboard was created:

vasundara-task10-dashboard

The dashboard contains an EC2 CPU utilization widget:

EC2 CPU Utilization - vasundara-task10

The metric used is:

CPUUtilization

The dashboard provides a centralized view of the EC2 instance monitoring data.

12. CloudWatch Alarm

A CPU utilization alarm was created:

vasundara-task10-cpu-high
Alarm Configuration
Metric: CPUUtilization
Namespace: AWS/EC2
Instance ID: i-0a3612288985eaddb
Statistic: Average
Period: 5 minutes
Threshold: Greater than 70%
Evaluation: 1 datapoint
Actions: No action configured

The alarm is designed to detect unusually high CPU utilization on the EC2 instance.

13. Application Activity Testing

Twenty CRM was deployed successfully on the EC2 instance.

The application was accessed through the EC2 public address:

http://54.167.6.91:3000

Application activity can be used to generate workload on the EC2 instance and observe the monitoring data in CloudWatch.

Docker container resource usage was also checked using:

docker stats --no-stream

This confirmed that the Twenty application, PostgreSQL and Redis containers were consuming system resources.

14. Monitoring Verification

The following commands were used during verification:

Docker
docker ps
Docker Compose
docker compose ps
Application
curl -I http://localhost:3000
CloudWatch Agent
sudo systemctl status amazon-cloudwatch-agent --no-pager
Agent Status
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
Container Resource Usage
docker stats --no-stream

The Twenty application containers were healthy and the CloudWatch Agent was running with the configured monitoring settings.

15. Troubleshooting
Issue 1: Docker Permission Denied

Problem:

permission denied while trying to connect to the Docker daemon socket

Solution:

sudo usermod -aG docker $USER
newgrp docker
Issue 2: CloudWatch Agent Package

The CloudWatch Agent was not installed through the standard Ubuntu APT repository.

Solution:

The official AWS .deb package was downloaded and installed:

wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
Issue 3: Twenty Server Initially Unhealthy

The Twenty server initially reported an unhealthy state while the application was still starting.

Solution:

The application logs and local HTTP endpoint were checked.

curl -I http://localhost:3000

The application eventually returned:

HTTP/1.1 200 OK

The Twenty server container then became healthy.

16. Evidence / Screenshots

The following screenshots should be included in the submission:

EC2 instance details showing vasundara-task10
SSH connection to the EC2 instance
Twenty CRM running
docker compose ps showing healthy containers
curl response showing HTTP/1.1 200 OK
CloudWatch Agent installation
CloudWatch Agent configuration
CloudWatch Agent status showing active (running)
CloudWatch EC2 CPU metric
vasundara-task10-dashboard
vasundara-task10-cpu-high alarm
Docker resource usage using docker stats
17. Result

The Twenty CRM application was successfully deployed on an AWS EC2 instance using Docker Compose.

Amazon CloudWatch was configured for infrastructure monitoring, including EC2 CPU monitoring and CloudWatch Agent configuration for CPU, memory and disk metrics.

A CloudWatch dashboard was created to visualize EC2 CPU utilization, and a CPU utilization alarm was configured to detect high CPU usage.

The implementation demonstrates basic AWS observability, monitoring, alerting and troubleshooting for a containerized application running on EC2.

18. Cleanup

After completing the required screenshots, testing and documentation, the EC2 instance should be terminated to avoid unnecessary AWS resource usage.

Instance:

i-0a3612288985eaddb

Name:

vasundara-task10

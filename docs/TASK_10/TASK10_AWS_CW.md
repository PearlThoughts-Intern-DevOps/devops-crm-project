Task 10: AWS CloudWatch Observability & Twenty CRM Deployment

Name: Harish Date: 7 September 2026
Task: Deploy Twenty CRM on AWS EC2, configure CloudWatch metrics collection, build an observability dashboard, and trigger a **CPU** alert using stress testing. 
Loom link: [https://www.loom.com/share/49faccca5cce443c977ba655b5178ea7]
PR link: [https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project/pull/228]

## Objective

The objective of this task was to deploy Twenty **CRM** on an **AWS** **EC2** instance and establish end-to-end system-level observability using **AWS** CloudWatch. This involved configuring the Amazon CloudWatch Agent to capture custom host OS metrics, creating a centralized dashboard, and validating dynamic threshold alerting via **CPU** stress testing.

## Work Completed & Technical Summary

- **EC2** & Docker Setup: Provisioned an Ubuntu **EC2** instance and deployed Twenty **CRM** using Docker Compose on port **3000**.
- CloudWatch Agent Configuration: Installed amazon-cloudwatch-agent and created a custom **JSON** configuration file to monitor system **CPU**, memory, and disk utilization.
- Dashboarding: Built a custom CloudWatch dashboard (DevOps-**CRM**-Dashboard) with time-series visual widgets.
- Alarm Validation: Configured a CloudWatch Alarm (High-**CPU**-Alarm) triggering at >= 70% active **CPU** usage, verified using the stress tool.


# Verify agent service status

sudo systemctl status amazon-cloudwatch-agent

## Issues Faced & Detailed Troubleshooting

Issue 1: **EC2** Inbound Port Blocked (Port **3000** Timeout)
- Symptom: Twenty **CRM** containers were healthy on local localhost checks, but remote web connections timed out on port **3000**.
- Root Cause: The **AWS** **EC2** Security Group restricted external traffic by default.
- Resolution: Added an Inbound Rule to the Security Group allowing Custom **TCP** traffic on port **3000** from source 0.0.0.0/0.

Issue 2: Transient **CPU** Alarm State (Alarm Dropped to OK prematurely)
- Symptom: During testing, the alarm briefly entered In alarm but reverted back to OK before full verification.
- Root Cause: The initial stress run timed out after **300** seconds, causing **CPU** usage to normalize before the CloudWatch 1-minute evaluation period completed.
- Resolution: Extended the stress duration using *nohup stress --cpu 4 --timeout **900** &* to sustain load across multiple evaluation cycles.

Issue 3: Custom OS Metrics Missing in Default **EC2** Console
- Symptom: System memory and active **CPU** breakdown were not appearing under default **EC2** metrics.
- Root Cause: Hypervisor-level metrics do not monitor guest OS **RAM** or active **CPU** breakdowns.
- Resolution: Navigated directly to the custom CWAgent namespace in CloudWatch, where custom agent metrics were being successfully published.

## Deployment & Configuration Process

# Step 5.1: 

5.1.1 Connect via SSH

chmod 400 <PEMFILE>
ssh -i harish-cw-key.pem ubuntu@ec2-54-226-97-42.compute-1.amazonaws.com

5.1.2 Install everything in one shot
```
sudo apt update && sudo apt install -y docker.io docker-compose-v2 git
sudo usermod -aG docker $USER
newgrp docker
```
5.1.3 Clone and deploy immediately
```
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
git checkout harish-task5
cp .env.example .env
openssl rand -base64 32
```
open env file and paste APP_SECRET_CODE and change SERVER_URL=http://<PUBLIC_DNS>:<PORT>

# Step 5.2: Deploy Twenty CRM

docker compose up --build -d

# Step 5.3: Install CloudWatch Agent 

wget [https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb]
sudo dpkg -i amazon-cloudwatch-agent.deb

## CloudWatch Agent Configuration Code

Configuration File (/opt/aws/amazon-cloudwatch-agent/bin/config.json):
```
{
"agent": {
"metrics_collection_interval": 60,
"run_as_user": "root"
},
"metrics": {
"namespace": "CWAgent",
"append_dimensions": {
"InstanceId": "${aws:InstanceId}"
},
"metrics_collected": {
"cpu": {
"measurement": [
"cpu_usage_active",
"cpu_usage_idle",
"cpu_usage_user",
"cpu_usage_system"
],
"metrics_collection_interval": 60,
"totalcpu": true
},
"mem": {
"measurement": [
"mem_used_percent",
"mem_available_percent"
],
"metrics_collection_interval": 60
},
"disk": {
"measurement": [
"disk_used_percent"
],
"metrics_collection_interval": 60,
"resources": [
"/"
]
}
}
}
}
```
Commands to Apply and Start CloudWatch Agent:

# Step 5.4: Configure CloudWatch Agent Code Create configuration file at 
## Fetch configuration and start the agent service
sudo /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
    -s

# Step 5.5: Build CloudWatch Dashboard 
Created custom dashboard named DevOps-CRM-Dashboard and added widgets for cpu_usage_active, mem_used_percent, and disk_used_percent under CWAgent namespace.

# Step 5.6: Configure CloudWatch CPU Alarm 
Created High-CPU-Alarm for CWAgent > cpu_usage_active with static threshold >= 70% over 1-minute period.

# Step 5.7: Stress Test & Trigger Alarm Executed background load generator:

Stress Testing & Verification Commands

Launch background CPU stress test across 4 cores for 15 minutes (900 seconds) 

```
nohup stress --cpu 4 --timeout **900** > /dev/null 2>&1 &
```

Verify active stress process IDs

```
pgrep stress
```

 Terminate stress process after alarm verification

```
pkill stress
```

# 6. Conclusion & Verification Summary

- Twenty **CRM** web application accessible on port **3000**.
- CloudWatch Agent successfully streaming system metrics every 60 seconds.
- Custom dashboard visually mapping active **CPU**, **RAM**, and Disk metrics.
- High-**CPU**-Alarm correctly transitioning to In Alarm state during stress testing.
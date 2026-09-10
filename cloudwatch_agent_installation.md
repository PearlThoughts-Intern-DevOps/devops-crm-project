# Twenty CRM Deployment and CloudWatch Monitoring

## 1. Launching and Connecting to EC2

I started by launching an EC2 instance using **Amazon Linux 2023**. After the instance was created, I connected to it through SSH using the key pair provided for the instance.

The SSH command I used was:

```bash
ssh -i my-key.pem ec2-user@<EC2_PUBLIC_IP>
```

Since Amazon Linux uses `ec2-user` as the default user, I used that username while connecting.

## 2. Preparing the EC2 Instance

Before deploying the application, I prepared the EC2 instance with the tools required for the application. Git was already installed, so I did not need to install it again.

I updated the system packages using:

```bash
sudo dnf update -y
```

Then I installed Node.js and npm:

```bash
sudo dnf install nodejs npm -y
```

I verified the installation using:

```bash
node -v
npm -v
```

I also enabled **Corepack** so that Yarn could be managed properly:

```bash
sudo corepack enable
```

After that, I checked the Yarn version to make sure it was available.

## 3. Installing Docker

Since Docker was also required for the deployment environment, I installed it using:

```bash
sudo dnf install docker -y
```

I started Docker and enabled it to start automatically after a system reboot:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

I also added `ec2-user` to the Docker group so that Docker commands could be executed without using `sudo` every time.

```bash
sudo usermod -aG docker ec2-user
```

After reconnecting to the EC2 instance, I verified Docker using:

```bash
docker --version
docker ps
```

## 4. Creating Swap Memory

To provide some additional memory support for the application, I created a **2 GB swap file** on the EC2 instance.

I created and configured the swap using:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

I then checked the available memory and swap using:

```bash
free -h
```

Finally, I added the swap entry to `/etc/fstab` so that it would remain available after a reboot.

## 5. Deploying Twenty CRM

After preparing the server, I deployed the **Twenty CRM** application on the EC2 instance. I obtained the application source code, installed the required dependencies, and started the application.

I verified that the application was running successfully from the EC2 instance and then accessed Twenty CRM using the EC2 instance's public address.

At this point, the main application deployment was working correctly.

## 6. Checking Default CloudWatch Metrics

After deploying Twenty CRM, I moved to AWS CloudWatch to monitor the EC2 instance. I opened CloudWatch → Classic metrics and selected the metrics related to my EC2 instance.

I checked the default EC2 metrics provided by AWS. The main metric I verified was CPUUtilization, which shows how much CPU the EC2 instance is using. I could also see other default metrics related to network traffic, disk operations, and instance status.

At this stage, I noticed that memory utilization and actual disk-space utilization were not available in the default EC2 metrics. The default disk metrics mainly show disk I/O activity, such as read and write operations, rather than how much disk space is currently occupied.

Because I needed CPU, memory, and disk utilization for the assignment, I decided to install the CloudWatch Agent.

## 7. Installing and Configuring CloudWatch Agent

I installed the CloudWatch Agent directly on my Amazon Linux 2023 EC2 instance using:

sudo dnf install amazon-cloudwatch-agent -y

The EC2 instance already had the required IAM permissions attached for CloudWatch, so I did not need to manually configure AWS access keys on the server.

I then configured the CloudWatch Agent to collect additional system-level metrics. The configuration used the CWAgent namespace and collected CPU, memory, and disk metrics every 60 seconds.

For CPU, I configured:

cpu_usage_idle
cpu_usage_user
cpu_usage_system

For memory, I configured:

mem_used_percent

For disk utilization, I configured:

used_percent

for the root filesystem /.

The configuration was stored under the CloudWatch Agent configuration directory. The agent was then started using the configuration file.

## 8. Verifying the Agent

After starting the agent, I checked its status from the EC2 terminal. The status showed that the CloudWatch Agent was running.

I also checked the CloudWatch Agent log:

sudo tail -50 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log

The log showed that the agent had started successfully and was ready to process and publish metrics. It also showed a one-minute publishing interval.

The next step was to check CloudWatch → Classic metrics → CWAgent and verify that the newly collected metrics, such as mem_used_percent and disk_used_percent, were being published.

This was important because CPU utilization was already available through the default AWS/EC2 namespace, while the additional memory and disk-space metrics were being provided by the CloudWatch Agent under the CWAgent namespace.

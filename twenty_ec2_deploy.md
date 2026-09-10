Running Twenty CRM on AWS EC2
Overview

I wanted to run the Twenty CRM project on an AWS EC2 instance instead of my local machine. I used a t3.small instance with approximately 2 GB RAM and cloned the project from GitHub.

1. Connecting to EC2

I connected to the EC2 instance from my Windows machine using SSH:

ssh -i "D:\pearl-thoughts.pem" ec2-user@<EC2_PUBLIC_IP>

Initially, SSH rejected my .pem file with an "UNPROTECTED PRIVATE KEY FILE" error. The problem was that the Windows file permissions were too open. I restricted the permissions using icacls and then SSH worked successfully.

2. Preparing EC2

I updated the system and installed basic tools such as Git, then installed the required development dependencies.

The project required:

Node.js 24.5+
Yarn 4.13.0
Docker
Docker Compose

I installed Node.js 24 and configured Yarn using Corepack.

3. Handling Limited Memory

The t3.small has only around 2 GB RAM. I was concerned about Out Of Memory (OOM) errors, especially during Docker image builds.

I initially attempted to create an 8 GB swap file, but the EC2 root disk was only 8 GB, so the command failed with:

No space left on device

I checked disk usage and found approximately 6.4 GB available. I then created a 4 GB swap, but decided to reduce it to 2 GB to preserve disk space.

My final configuration was approximately:

RAM:   2 GB
Swap:  2 GB
Disk:  8 GB

I also configured vm.swappiness=10.

4. Cloning the Project

I installed Git and cloned only the required branch:

git clone -b anurag_task_6 --single-branch https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git

I initially used the GitHub browser URL containing /tree/anurag_task_6/, which failed. I fixed this by using the repository URL and specifying the branch with -b.

5. Installing Dependencies

The project uses Yarn rather than npm. I ran:

yarn install

The installation completed successfully with peer-dependency warnings.

6. Running Twenty

I tested the Twenty server and confirmed it was healthy:

Status: running (healthy)
URL: http://localhost:2020

The server initially reported Gmail refresh-token errors, but these were unrelated to the server's health.

I also discovered that localhost:2020 refers to the EC2 machine itself. Since the application was listening on 0.0.0.0:2020, I needed to allow TCP port 2020 in the EC2 Security Group and access it from my browser using:

http://<EC2_PUBLIC_IP>:2020
7. Docker

Docker was installed and the Twenty container was successfully running:

twenty-app-dev
0.0.0.0:2020->2020/tcp

Since the project provides yarn twenty docker:start, I used the project's command because it also performs initialization such as database setup, cache flushing, and workspace seeding.

Result

I successfully prepared the EC2 environment to run Twenty CRM with Docker, while accounting for the limited memory and disk resources of the t3.small instance.
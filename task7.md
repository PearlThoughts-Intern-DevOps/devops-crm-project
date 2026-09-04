Task 7 AWS EC2 Deployment

Objective

1. Deploy Twenty CRM on an AWS EC2 instance
2. Configure the EC2 instance for application deployment
3. Install and configure Docker
4. Install and configure Docker Compose
5. Deploy the application using Docker Compose
6. Access the application through the EC2 public IP
7. Understand EC2 concepts and resource management
8. Document the deployment process
9. Create a separate Git branch
10. Push the Task 7 changes to GitHub
11. Create a pull request for review

AWS EC2 Configuration

1. Cloud Provider: Amazon Web Services
2. AWS Service: Amazon EC2
3. Operating System: Amazon Linux 2023
4. Instance Type: t3.small
5. SSH User: ec2-user
6. Key Pair: bkkrish007-key.pem
7. Application Port: 2020
8. EC2 Public IP: 100.24.37.47

EC2 Instance Setup

1. Launch an EC2 instance using Amazon Linux 2023
2. Select the t3.small instance type
3. Select the required key pair
4. Configure the security group
5. Allow SSH access through port 22
6. Allow application access through port 2020
7. Connect to the EC2 instance using SSH
8. Update the system packages
9. Verify the EC2 instance configuration

SSH Connection

1. Connect to the EC2 instance using the SSH command

ssh -i bkkrish007-key.pem ec2-user@100.24.37.47

2. Verify the connected user

whoami

3. Verify the current working directory

pwd

4. Navigate to the project directory

cd ~/devops-crm-project

System Update

1. Update the Amazon Linux packages

sudo dnf update -y

2. Verify the operating system

cat /etc/os-release

Docker Installation

1. Install Docker

sudo dnf install docker -y

2. Start the Docker service

sudo systemctl start docker

3. Enable Docker to start automatically

sudo systemctl enable docker

4. Check the Docker service status

sudo systemctl status docker

5. Add the ec2-user to the Docker group

sudo usermod -aG docker ec2-user

6. Verify the Docker version

docker --version

Docker Compose Installation

1. Download Docker Compose

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

2. Give execute permission to Docker Compose

sudo chmod +x /usr/local/bin/docker-compose

3. Verify the Docker Compose version

docker-compose --version

Swap Memory Configuration

1. Configure swap memory to improve application performance
2. Create a 2 GB swap file

sudo dd if=/dev/zero of=/swapfile bs=1M count=2048

3. Set the correct permission

sudo chmod 600 /swapfile

4. Configure the swap file

sudo mkswap /swapfile

5. Enable the swap file

sudo swapon /swapfile

6. Verify the available memory and swap memory

free -h

Project Setup

1. Navigate to the project directory

cd ~/devops-crm-project

2. Check the project files

ls

3. The project contains the Twenty CRM application source code
4. The project contains a Dockerfile
5. The project contains a docker-compose.yml file
6. The project uses Docker Compose for application deployment

Dockerfile Changes

1. The Dockerfile contains the application container build configuration
2. The dependencies stage was updated for the EC2 deployment
3. The unnecessary .yarn directory copy instruction was removed

COPY .yarn/ ./.yarn/

4. The application dependencies are installed using Yarn

RUN yarn install --immutable

5. The Dockerfile was updated to support the Task 7 deployment

Docker Compose Changes

1. Docker Compose is used to manage the application services
2. The application is exposed through port 2020
3. The host port is mapped to the container port

ports:
  - "2020:2020"

4. The application port was configured as 2020

PORT=2020

5. The server URL was updated to use the EC2 public IP

SERVER_URL=http://100.24.37.47:2020

6. The application environment was configured for development

NODE_ENV=development

7. Local storage was configured for the application

STORAGE_TYPE=local

8. Application logs were configured to use the console

APPLICATION_LOG_DRIVER=CONSOLE

Health Check Configuration

1. The health check verifies whether the application is running
2. The health check uses the local container address
3. The health check was configured using the following command

healthcheck:
  test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://127.0.0.1:2020/healthz || exit 1"]

4. The health check was updated to use the application port 2020
5. The health check helps verify the service availability

Docker Compose Deployment

1. Navigate to the project directory

cd ~/devops-crm-project

2. Start the application services in detached mode

docker-compose up -d

3. Verify the running containers

docker ps

4. Verify the Docker Compose services

docker-compose ps

5. Check the application logs

docker-compose logs -f twenty-server

6. Check the application port mapping

docker-compose port twenty-server 2020

Application Verification

1. Verify the application locally from the EC2 instance

curl -I http://localhost:2020

2. The application returned HTTP 200 OK
3. This confirmed that the application was running successfully
4. Open the application in a browser using the EC2 public IP

http://100.24.37.47:2020

5. Twenty CRM was successfully opened in the browser
6. The application was accessible through the configured application port

EC2 Concepts Learned

1. EC2 provides virtual servers in the AWS cloud
2. An AMI defines the operating system and initial configuration
3. An instance type defines CPU, memory, and network capacity
4. A key pair provides secure SSH access
5. A security group works as a virtual firewall
6. A public IP allows the application to be accessed from the internet
7. EBS provides storage for the EC2 instance
8. Docker runs the application inside containers
9. Docker Compose manages application services
10. Port mapping connects the host port with the container port
11. Instance state determines whether the EC2 server is running or stopped
12. EC2 resources should be stopped when they are not required

Security Group Configuration

1. SSH port 22 was allowed for server access
2. HTTP port 80 was configured
3. HTTPS port 443 was configured
4. Application port 2020 was allowed
5. Port 2020 is required to access Twenty CRM from the browser
6. SSH access should be restricted to trusted IP addresses when possible
7. Security group rules control inbound traffic to the EC2 instance

Application Port Configuration

1. The application runs inside the container on port 2020
2. The EC2 host exposes the application through port 2020
3. The security group allows inbound traffic through port 2020
4. The application can be accessed using the EC2 public IP address
5. The final application URL is

http://100.24.37.47:2020

Resource Management

1. Stop the EC2 instance when it is not required
2. Stopping the instance helps avoid unnecessary running costs
3. Stop the Docker services when required

docker-compose down

4. Terminate the EC2 instance only after completing the submission
5. Termination permanently removes the EC2 instance
6. Take all required screenshots before stopping or terminating the instance
7. Record the Loom video before stopping or terminating the instance
8. Keep the instance running if the mentor needs to verify the application

Git Branch

1. The Task 7 branch name is bkkrish007-task7
2. The branch was created from the Task 6 project
3. The Task 7 changes include Dockerfile updates
4. The Task 7 changes include docker-compose.yml updates
5. The Task 7 changes include Task 7 documentation

Git Commands

1. Check the current Git status

git status

2. Create the Task 7 branch

git checkout -b bkkrish007-task7

3. Add the Task 7 files

git add Dockerfile docker-compose.yml task7.md

4. Commit the Task 7 changes

git commit -m "Add Task 7 AWS EC2 deployment"

5. Push the branch to GitHub

git push -u origin bkkrish007-task7

GitHub Submission

1. Open the project repository on GitHub
2. Select the bkkrish007-task7 branch
3. Verify that the Dockerfile is present
4. Verify that the docker-compose.yml file is present
5. Verify that the task7.md file is present
6. Create a pull request
7. Select main as the base branch
8. Select bkkrish007-task7 as the compare branch
9. Add the Task 7 deployment summary
10. Add the Loom video link
11. Add screenshots of the EC2 instance
12. Add screenshots of the running Twenty CRM application
13. Submit the pull request for review

Deployment Issues and Solutions

Issue 1 Docker Compose Command

Problem

Docker Compose was not available initially on the EC2 instance

Solution

Docker Compose was installed manually and execute permission was provided

Issue 2 Application Port

Problem

The application needed to be accessed from outside the EC2 instance

Solution

The application port was configured as 2020 and port 2020 was allowed in the security group

Issue 3 Server URL

Problem

The application was initially configured with localhost

Solution

The server URL was updated to use the EC2 public IP address

Issue 4 Health Check

Problem

The health check needed to verify the application inside the container

Solution

The health check was configured using the local container address and port 2020

Issue 5 Memory Usage

Problem

The EC2 instance had limited memory for running the application

Solution

A 2 GB swap file was configured to improve memory availability

Deployment Result

1. Twenty CRM was successfully deployed on AWS EC2
2. Docker was installed and configured successfully
3. Docker Compose was installed and configured successfully
4. The application was started using Docker Compose
5. The application returned HTTP 200 OK
6. The application was accessible through the EC2 public IP
7. The application was accessed using port 2020
8. The deployment process was documented
9. The Task 7 branch was created
10. The changes were prepared for GitHub submission

Screenshots

1. EC2 instance configuration screenshot
2. EC2 running instance screenshot
3. Security group configuration screenshot
4. SSH connection screenshot
5. Docker version screenshot
6. Docker Compose version screenshot
7. Running containers screenshot
8. Application browser screenshot
9. Git branch screenshot
10. GitHub pull request screenshot


Conclusion

1. The Twenty CRM application was deployed successfully on an AWS EC2 instance
2. The EC2 instance was configured with the required networking and security settings
3. Docker and Docker Compose were used for application deployment
4. The application was verified through the EC2 public IP
5. The application was accessed using port 2020
6. The deployment process improved understanding of cloud infrastructure
7. The deployment process improved understanding of containerized applications
8. The Task 7 changes were prepared for GitHub submission

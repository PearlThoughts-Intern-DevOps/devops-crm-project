Task 7 - AWS EC2 Deployment of Twenty CRM

1. Objective



The objective of this task was to launch and configure an AWS EC2 instance, connect to the instance, prepare the Docker environment, deploy and run Twenty CRM, verify application access, troubleshoot deployment issues, document the process, and clean up AWS resources after completion.



The GitHub repository devops-crm-project was used only for submitting the Task 7 documentation.



The Twenty CRM source repository was not cloned to the EC2 instance, and no GitHub Personal Access Token (PAT) was used on the EC2 instance.



2. AWS EC2 Environment



The application was deployed on an AWS EC2 instance.



Environment

Cloud Provider: AWS

Service: EC2

Operating System: Amazon Linux 2023

Container Runtime: Docker

Docker Version: 25.0.14

Container Orchestration: Docker Compose

Docker Compose Version: 5.5.0

Application: Twenty CRM

Twenty CRM Docker Image: twentycrm/twenty:latest

Database: PostgreSQL 16

Cache: Redis

Application Port: 3000



The EC2 instance was configured with the required AMI, instance type, key pair, networking, and security group.



3. EC2 Connection



The EC2 instance was accessed successfully using SSH from a Windows workstation.



After connecting, the EC2 terminal displayed:



[ec2-user@ip-172-31-24-122 ~]$





The SSH private key was kept secure and was not committed to GitHub.



4. Security Group



The EC2 security group was configured to allow SSH access and Twenty CRM application access.



Inbound Rules

Type	Protocol	Port	Source	Purpose

SSH	TCP	22	Configured source	SSH access

Custom TCP	TCP	3000	Configured source	Twenty CRM access



Port 3000 was used because the Twenty CRM Docker Compose configuration exposed the application on port 3000.



For production environments, application ports should preferably be restricted to trusted IP addresses or exposed through a reverse proxy/load balancer.



5. Operating System Verification



The EC2 operating system was verified using:



cat /etc/os-release





The output confirmed:



NAME="Amazon Linux"

VERSION="2023"

ID="amzn"

VERSION\_ID="2023"

PRETTY\_NAME="Amazon Linux 2023.12.20260831"





Therefore, the deployment environment was Amazon Linux 2023.



6. Docker Verification



Docker was already installed on the EC2 instance.



Docker was verified using:



docker --version





Output:



Docker version 25.0.14, build 0bab007



7. Docker Permission Issue



Initially, running:



docker info





returned a permission error:



permission denied while trying to connect to the Docker daemon socket



Cause



The ec2-user account did not initially have permission to access the Docker daemon socket.



Solution



The user was added to the Docker group:



sudo usermod -aG docker ec2-user





The SSH session was then exited and a new SSH session was opened.



Docker group membership was verified using:



groups





The output included:



ec2-user adm wheel systemd-journal docker





After reconnecting, Docker commands worked without requiring sudo.



8. Docker Compose Installation



Initially, Docker Compose was not available.



Running:



docker compose version





returned:



docker: 'compose' is not a docker command.





An attempt was made to install the Docker Compose plugin through the package manager:



sudo yum install docker-compose-plugin -y





This failed with:



No match for argument: docker-compose-plugin

Error: Unable to find a match: docker-compose-plugin



Solution



Docker Compose was installed manually as a Docker CLI plugin.



The plugin directory was created:



mkdir -p ~/.docker/cli-plugins





Docker Compose was downloaded:



curl -SL https://github.com/docker/compose/releases/download/v5.5.0/docker-compose-linux-x86\_64 \\

\-o ~/.docker/cli-plugins/docker-compose





Execute permission was added:



chmod +x ~/.docker/cli-plugins/docker-compose





Docker Compose was then verified:



docker compose version





Output:



Docker Compose version v5.5.0



9. Twenty CRM Deployment Approach



According to the task instructions, the EC2 instance was not connected to the devops-crm-project GitHub repository.



The Twenty CRM source code was also not cloned to EC2.



Instead, the official Docker Compose configuration was downloaded:



curl -fsSL https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/docker-compose.yml \\

\-o docker-compose.yml





The file was verified using:



ls -l docker-compose.yml





The deployment used the Docker image:



twentycrm/twenty:latest





This approach allowed Twenty CRM to be deployed without pushing application source code from EC2 to the assignment repository.



10. Docker Compose Services



The Docker Compose deployment created the following services:



Twenty CRM server

PostgreSQL 16

Redis

Twenty CRM worker



Docker also created the required network and persistent volumes.



The deployment used PostgreSQL as the database and Redis for caching/background processing.



11. Environment Configuration



The Twenty CRM Docker Compose deployment used environment configuration for the application and supporting services.



The application server was configured to listen on port 3000.



The environment file contained configuration such as:



TAG=latest

SERVER\_URL=http://localhost:3000

STORAGE\_TYPE=local





Sensitive credentials and secrets were not committed to the GitHub repository.



12. PostgreSQL Authentication Issue



During the first deployment attempt, the Twenty CRM server repeatedly restarted.



The server logs showed:



FATAL: password authentication failed for user "postgres"





An earlier configuration problem also resulted in an invalid PostgreSQL connection string.



Cause



The PostgreSQL container had already initialized its database using an earlier password configuration.



PostgreSQL stores the initialized database credentials in its data volume. Simply changing the environment configuration does not automatically change credentials inside an already-initialized database.



Solution



Because this was a fresh deployment and there was no important database data to preserve, the Docker Compose stack and its volumes were removed:



docker compose down -v





The application was then started again with the corrected configuration:



docker compose up -d





The database was recreated and the Twenty CRM server was able to connect successfully.



13. Twenty CRM Startup



The application was started using:



docker compose up -d





Initially, the server container reported an unhealthy state while initialization and database migrations were still in progress.



The server logs were monitored using:



docker compose logs --tail=100 server





The logs eventually showed successful initialization and background job registration.



For example:



Cron job registration completed: 27 successful, 0 failed, 2 skipped





The successful registration of background jobs confirmed that application initialization had progressed successfully.



14. Final Container Status



The final status was checked using:



docker compose ps





The final output showed:



NAME              IMAGE                     STATUS

twenty-db-1       postgres:16               Up (healthy)

twenty-redis-1    redis                     Up (healthy)

twenty-server-1   twentycrm/twenty:latest   Up (healthy)





The Twenty CRM server showed:



0.0.0.0:3000->3000/tcp





This confirmed that port 3000 on the EC2 host was mapped to port 3000 inside the Twenty CRM container.



15. Application Verification



The application was verified from inside the EC2 instance using:



curl -I http://localhost:3000





Additional response information confirmed that the Twenty CRM web server was responding successfully.



The Docker containers were also healthy.



This confirmed that:



Docker was running.

Docker Compose was working.

PostgreSQL was healthy.

Redis was healthy.

Twenty CRM was healthy.

Twenty CRM was responding on port 3000.



The application was then verified externally through a browser using:



http://<EC2-PUBLIC-IP>:3000





The Twenty CRM application loaded successfully.



16. Issues Faced and Solutions

Issue 1 - Docker permission denied



Problem:



permission denied while trying to connect to the Docker daemon socket





Solution:



sudo usermod -aG docker ec2-user





The SSH session was restarted and Docker group membership was verified.



Issue 2 - Docker Compose command unavailable



Problem:



docker: 'compose' is not a docker command





Solution:



Docker Compose v5.5.0 was installed manually as a CLI plugin.



Issue 3 - Docker Compose package unavailable



Problem:



No match for argument: docker-compose-plugin





Solution:



The Docker Compose binary was downloaded manually to:



~/.docker/cli-plugins/docker-compose



Issue 4 - PostgreSQL password authentication failure



Problem:



FATAL: password authentication failed for user "postgres"





Solution:



The old PostgreSQL volume was removed because this was a fresh deployment:



docker compose down -v





The services were recreated:



docker compose up -d



Issue 5 - Twenty CRM server initially unhealthy



Problem:



The server container initially reported:



dependency failed to start: container twenty-server-1 is unhealthy





Solution:



The server logs were inspected using:



docker compose logs --tail=100 server





The issue was traced to the PostgreSQL configuration. After recreating the database volume and restarting the stack, the server completed its migrations and initialization.



17. Basic EC2 Concepts



The following EC2 concepts were used during the task.



AMI



An Amazon Machine Image provides the operating system and initial configuration used to launch an EC2 instance.



Instance Type



The instance type determines the CPU, memory, networking, and other compute resources available to the instance.



Key Pair



An EC2 key pair provides secure SSH authentication.



Security Group



A security group acts as a virtual firewall and controls network traffic to and from the EC2 instance.



Public IPv4



The public IPv4 address allows the EC2-hosted application to be accessed externally when the appropriate security group rule is configured.



EBS



Elastic Block Store provides persistent block storage for an EC2 instance.



VPC



A Virtual Private Cloud provides the networking environment for AWS resources such as EC2 instances.



Instance Lifecycle



EC2 instances can be started, stopped, and terminated. Terminating unused resources helps avoid unnecessary AWS costs.



18. GitHub Submission



The assignment repository used for documentation was:



devops-crm-project





The required Task 7 branch was created:



ambur-7





The documentation is stored at:



docs/TASK-7-AWS-EC2-TWENTY-CRM.md





Only Task 7 documentation will be committed to this branch.



The Twenty CRM application/source code was not pushed from EC2 to the repository.



No GitHub Personal Access Token (PAT) was configured on EC2.



The EC2 instance was kept separate from the GitHub submission workflow.



19. Loom Video



A Loom video will be included in the pull request.



The video will explain:



AWS EC2 instance configuration

SSH connection

Docker installation and configuration

Docker Compose installation

Twenty CRM deployment

PostgreSQL and Redis services

Troubleshooting performed

Final Docker container status

Application verification

Browser access to Twenty CRM



The Loom video will comply with the task requirement that the presenter's face remains visible throughout the explanation.



Loom URL:





20. Cleanup



After completing the deployment verification, screenshots, documentation, and Loom recording, the AWS resources will be cleaned up to avoid unnecessary costs.



The EC2 instance should be stopped or terminated according to the task requirement.



Before termination, the following items will be confirmed:



Twenty CRM deployment completed.

Application verified in the browser.

Docker containers verified as healthy.

Documentation completed.

Loom recording completed.

GitHub branch prepared.

Pull request prepared.

21. Conclusion



Twenty CRM was successfully deployed on an AWS EC2 instance using Docker Compose.



The deployment included Twenty CRM, PostgreSQL 16, Redis, and the required supporting Docker resources.



Several issues were encountered during the deployment, including Docker socket permissions, unavailable Docker Compose packages, PostgreSQL authentication problems, and initial Twenty CRM health-check failures.



These issues were investigated using Docker and Docker Compose commands and were successfully resolved.



The final deployment was verified with healthy Docker containers and an HTTP 200 OK response from:



curl -I http://localhost:3000





The application was also successfully accessed through the EC2 public IP on port 3000.



The GitHub repository was used only for Task 7 documentation. No Twenty CRM source code or credentials were pushed from the EC2 instance.



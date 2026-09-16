WS Application Load Balancer setup completed in Task 15.

Task 15: AWS Application Load Balancer using Terraform
Task 16: Twenty CRM Failure & Recovery
Task 15 PR: #359

The Task 15 ALB routes traffic to the Twenty CRM application on port 3000. Task 16 validates application health, container restart behavior, EC2 recovery, and application recovery using the existing infrastructure.

1. Objective

The objective of this task is to deploy Twenty CRM on an AWS EC2 instance using Docker and verify application recovery during container and EC2 failure scenarios.

The implementation includes:

Docker-based Twenty CRM deployment
Docker restart policy
Docker health check
Container failure testing
EC2 stop/start recovery testing
Application and container log verification
Port and application availability verification
Failure and recovery documentation
2. Environment
Configuration	Details
Cloud Platform	AWS EC2
Operating System	Ubuntu
Container Runtime	Docker
Docker Compose	Docker Compose v2
Application	Twenty CRM
Twenty CRM Image	twentycrm/twenty:v2.35.0
Application Port	3000
Git Branch	Ekta-Task-16
3. Docker Services

The deployment contains three services:

Twenty CRM application
PostgreSQL database
Redis cache

All services use Docker Compose and are connected through a dedicated Docker bridge network.

Persistent PostgreSQL data is stored using a Docker volume.

4. Restart Policy

The Twenty CRM application uses:

restart: unless-stopped

The PostgreSQL and Redis services also use the same restart policy.

Docker was configured to start automatically when the EC2 instance boots:

sudo systemctl enable docker

This allows Docker to start automatically after an EC2 reboot and allows containers configured with restart policies to start during Docker recovery.

The configured restart policy was verified using Docker inspection.

5. Health Check

A Docker health check was configured for the Twenty CRM application.

Setting	Value
Endpoint	http://localhost:3000
Interval	30 seconds
Timeout	10 seconds
Retries	5
Start period	60 seconds

The application initially returned connection-refused results while it was starting. Once the application completed initialization, the health check returned exit code 0 and the container became healthy.

Final health status:

Health=healthy
6. Container Failure Test

The Twenty CRM container was manually stopped/killed during testing.

The initial docker kill test resulted in the container entering an exited state rather than immediately restarting. This is consistent with the behavior of a manually stopped container under the unless-stopped policy.

The container was then started again using:

docker start twenty_crm_app

After restarting, the container returned to a healthy state.

The final container inspection showed:

Status: running
Health: healthy
Restart Policy: unless-stopped
Restart Count: 2

The restart count was observed during the overall recovery testing.

7. EC2 Failure and Recovery Test

The EC2 instance was stopped from the AWS EC2 console and then started again.

After reconnecting to the EC2 instance, the Docker containers automatically started.

The following services were observed:

twenty_crm_app
twenty_crm_db
twenty_crm_cache

The database and Redis containers became healthy first. The Twenty CRM application initially showed health: starting while the application initialized.

After initialization, the health check successfully completed and the application became healthy.

Final verification:

Status=running
Health=healthy
RestartPolicy=unless-stopped
RestartCount=2

This confirmed successful container and application recovery after the EC2 stop/start operation.

8. Application Recovery Logs

Application logs were checked after the EC2 restart.

The logs confirmed successful application initialization, including:

Database configuration loading
GraphQL route mapping
Application initialization
NestJS application startup

The final startup message was:

[NestApplication] Nest application successfully started

This confirms that the Twenty CRM application successfully recovered after the EC2 stop/start operation.

9. Port and Application Verification

Twenty CRM was configured to use port 3000.

Docker port mapping was verified using:

docker ps

The Twenty CRM container showed:

0.0.0.0:3000->3000/tcp
[::]:3000->3000/tcp

The EC2 host was also verified to be listening on port 3000:

sudo ss -tulpn | grep :3000

The output confirmed that port 3000 was listening.

The application was tested locally from the EC2 instance:

curl -I http://localhost:3000

The application returned:

HTTP/1.1 200 OK

This confirmed that Twenty CRM was responding successfully on port 3000.

The application was also verified through the existing AWS Application Load Balancer configuration from Task 15.

10. Recovery Verification

The failure and recovery tests verified the following:

Test	Result
Twenty CRM Docker deployment	Passed
PostgreSQL container	Healthy
Redis container	Healthy
Twenty CRM health check	Healthy
Docker restart policy	Configured
Container failure testing	Completed
Container recovery testing	Completed
EC2 stop/start test	Passed
Containers automatically started after EC2 restart	Passed
Port 3000 listening	Verified
Application HTTP response	HTTP 200 OK
Application startup logs	Verified
Final application status	Running and healthy
11. Final Docker Status

Final Docker verification confirmed that all required services were running and healthy.

docker ps
Container	Status	Port
Twenty CRM	Running / Healthy	3000
PostgreSQL	Running / Healthy	5432
Redis	Running / Healthy	6379

Final Twenty CRM configuration:

Status=running
Health=healthy
RestartPolicy=unless-stopped
RestartCount=2
12. Security and Configuration

The .env file was used for application secrets and was excluded from Git tracking.

The .gitignore file includes:

.env

This prevents application secrets such as APP_SECRET and ENCRYPTION_KEY from being committed to the repository.

The existing Task 15 ALB and security-group architecture was retained.

13. Conclusion

Twenty CRM was successfully deployed on AWS EC2 using Docker Compose.

Docker restart policies and health checks were configured to improve application availability and provide health monitoring.

Container failure testing, EC2 stop/start recovery testing, Docker health checks, port verification, and application logs were used to validate the recovery process.

The final verification confirmed that Twenty CRM, PostgreSQL, and Redis were running and healthy.

Twenty CRM successfully responded with an HTTP 200 OK response on port 3000, and the application logs confirmed successful startup after recovery.

Task 16 successfully completed the required Twenty CRM failure and recovery validation based on the infrastructure established in Task 15.

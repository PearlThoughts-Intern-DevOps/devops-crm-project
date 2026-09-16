Task 16: Twenty CRM Failure & Recovery
1. Objective

The objective of this task is to deploy Twenty CRM on an AWS EC2 instance using Docker and verify application recovery during container and EC2 failure scenarios.

The implementation includes:

Docker-based Twenty CRM deployment
Docker restart policy
Docker health check
Container failure testing
EC2 stop/start recovery testing
Application and container log verification
Failure and recovery documentation
2. Environment
Cloud Platform: AWS EC2
Operating System: Ubuntu
Container Runtime: Docker
Docker Compose: Docker Compose v2
Application: Twenty CRM
Twenty CRM Image: twentycrm/twenty:v2.35.0
Application Port: 3000
Git Branch: Ekta-Task-16
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

This allows containers configured with the restart policy to start automatically after an EC2 reboot.

5. Health Check

A Docker health check was configured for the Twenty CRM application:

Endpoint: http://localhost:3000
Interval: 30 seconds
Timeout: 10 seconds
Retries: 5
Start period: 60 seconds

The application initially returned connection-refused results while it was starting. Once the application completed initialization, the health check returned exit code 0 and the container became healthy.

Final health status:

Health=healthy

6. Container Failure Test

The Twenty CRM container was manually stopped/killed during testing.

The initial docker kill test resulted in the container entering an exited state rather than immediately restarting. This is consistent with the behavior of a manually stopped container under the unless-stopped policy.

The container was then started again and returned to a healthy state.

An additional unexpected process-failure scenario was monitored through Docker restart behavior. The final container inspection showed:

Status: running
Health: healthy
Restart Policy: unless-stopped
Restart Count: 2

This confirms that Docker restart behavior was active during the recovery testing.

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

Status=running Health=healthy RestartPolicy=unless-stopped RestartCount=2

8. Application Recovery Logs

Application logs were checked after the EC2 restart.

The logs confirmed successful application initialization, including:

Database configuration loading
GraphQL route mapping
Application initialization
NestJS application startup

The final startup message was:

Nest application successfully started

This confirms that the Twenty CRM application successfully recovered after the EC2 stop/start operation.

9. Recovery Verification

The failure and recovery tests verified the following:

Test	Result
Twenty CRM Docker deployment	Passed
PostgreSQL container	Healthy
Redis container	Healthy
Twenty CRM health check	Healthy
Docker restart policy	Configured
Container recovery testing	Completed
EC2 stop/start test	Passed
Containers automatically started after EC2 restart	Passed
Application startup logs	Verified
Final application status	Running and healthy
10. Conclusion

Twenty CRM was successfully deployed on AWS EC2 using Docker Compose.

Docker restart policies and health checks were configured to improve application availability and provide health monitoring. Failure scenarios were tested, the EC2 instance was stopped and restarted, and the application successfully recovered.

The final Docker inspection confirmed that Twenty CRM was running, healthy, configured with the unless-stopped restart policy, and had recorded restart activity during the testing process.

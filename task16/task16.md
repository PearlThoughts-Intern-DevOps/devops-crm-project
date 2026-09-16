# Task 16 – Docker Restart & EC2 Recovery

## Objective

Run Twenty CRM on an EC2 instance using Docker, configure automatic container restart and health checking, test failure recovery, restart the EC2 instance, and verify application recovery.

## Environment

- EC2 OS: Ubuntu
- Instance Type: t3.small
- Region: us-east-1
- Application: Twenty CRM
- Docker Compose: Docker Compose V2
- Twenty CRM Port: 2020
- Repository: devops-crm-project
- Branch: bkkrish007-task16

## 1. Docker Restart Policy

The Docker Compose configuration was updated for both containers:

```yaml
restart: always
Configured services:
- devops-crm-twenty-server
- devops-crm-app
This allows Docker to automatically start containers when the Docker service/host starts and provides restart behavior for unexpected container failures.

2. Twenty CRM Health Check
Twenty CRM includes the following Docker health check:
healthcheck:
  test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://127.0.0.1:2020/healthz || exit 1"]
  interval: 10s
  timeout: 5s
  retries: 30
  start_period: 180s
The health check verifies the Twenty CRM /healthz endpoint.

3. Manual Container Failure Test
The Twenty CRM container was manually stopped using:
docker kill devops-crm-twenty-server
The container entered an exited state.
Docker daemon logs showed that this manual stop was recognized as:
hasBeenManuallyStopped=true
restart canceled
Therefore, Docker did not automatically restart the container after the manual docker kill.
The container was manually started again to restore the test environment:
docker start devops-crm-twenty-server

4. Unexpected Process Failure Test
Because the Twenty CRM image uses s6 as PID 1, an unexpected PID 1 failure was simulated from inside the container:
docker exec devops-crm-twenty-server sh -c 'kill -KILL 1'
After the failure, the container recovered and returned to a running state.
The container later reached:
Up ... (healthy)
This confirmed recovery of the Twenty CRM container after the unexpected process failure test.

5. EC2 Restart Test
The EC2 instance was restarted using:
sudo reboot
After reconnecting to the EC2 instance, the Docker Compose services were checked:
docker compose ps
Both containers automatically started again.
Initial recovery state:
devops-crm-app              Up ... (healthy)
devops-crm-twenty-server    Up ... (health: starting)
After the health-check initialization period, Twenty CRM became healthy.

6. Recovery Logs
Twenty CRM logs were checked using:
docker logs --tail 50 devops-crm-twenty-server
The logs showed successful recovery and service initialization, including:
Database ready
twenty-server successfully started
twenty-worker successfully started
Registering cron jobs
These logs confirm that the Twenty CRM application initialized successfully after the EC2 restart.

7. Final Verification
Final container status was verified using:
docker compose ps
The services were running and the Twenty CRM health check reported healthy after initialization.

8. Failure and Recovery Summary
Test	Action	Result
Manual container kill	docker kill devops-crm-twenty-server	Container stopped; Docker treated it as manually stopped
Unexpected process failure	kill -KILL 1 inside container	Container recovered
EC2 restart	sudo reboot	Docker containers automatically started
Health verification	Docker health check	Twenty CRM became healthy
Log verification	docker logs	Database and application services initialized successfully


Conclusion
Task 16 implemented Docker restart policies and a Twenty CRM health check, tested failure and recovery scenarios, verified automatic container startup after an EC2 reboot, and confirmed application recovery through Docker status and application logs.
EOF
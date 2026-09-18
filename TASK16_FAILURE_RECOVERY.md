\# Task 16: Twenty CRM Failure \& Recovery



\## Objective



The objective of this task was to deploy Twenty CRM on an AWS EC2 instance using Docker and verify failure recovery.



The following were configured and tested:



\* Docker restart policy for Twenty CRM

\* Docker health check

\* Manual container failure

\* EC2 stop and start recovery

\* Application health verification

\* Container and application logs



\## Environment



\* AWS EC2: Ubuntu Linux

\* Instance type: t3.small

\* Region: us-east-1

\* Application: Twenty CRM

\* Container runtime: Docker

\* Docker Compose: v5.5.0

\* Application port: 3000



\## 1. Twenty CRM Deployment



Twenty CRM was deployed using Docker Compose.



The Docker Compose setup contains:



\* Twenty CRM server

\* PostgreSQL database

\* Redis



The Twenty CRM server is exposed on port 3000.



The application health check uses:



```bash

curl --fail http://localhost:3000/healthz

```



The server container uses the Docker restart policy:



```yaml

restart: always

```



This allows Docker to bring the container back when the Docker service starts again.



\## 2. Health Check Verification



The Twenty CRM container health status was checked using:



```bash

docker inspect -f '{{.State.Health.Status}}' twenty-server-1

```



The result was:



```text

healthy

```



The application was also tested locally:



```bash

curl -I http://localhost:3000

```



The application returned:



```text

HTTP/1.1 200 OK

```



This confirmed that the Twenty CRM application was responding successfully.



\## 3. Restart Policy Verification



The configured restart policy was verified using:



```bash

docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' twenty-server-1

```



The result was:



```text

always

```



This confirms that the Twenty CRM server container has the required Docker restart policy.



\## 4. Manual Container Failure Test



The Twenty CRM server container was manually terminated using:



```bash

docker kill twenty-server-1

```



The container stopped with exit code 137.



Docker logs showed that the container was treated as manually stopped during this test, so it did not automatically restart from the `docker kill` command in this environment.



The container was restored manually and the application became healthy again.



This test helped verify the container failure behavior and restart-policy configuration.



\## 5. EC2 Stop and Start Recovery Test



The EC2 instance was stopped from the AWS Console and then started again.



After the EC2 instance became available, SSH access was restored.



Docker service status was checked using:



```bash

sudo systemctl is-active docker

```



Result:



```text

active

```



This confirmed that Docker started automatically after the EC2 restart.



\## 6. Twenty CRM Recovery Verification



After reconnecting to the EC2 instance, the Docker Compose services were checked:



```bash

cd \~/twenty

docker compose ps

```



The result showed:



```text

twenty-db-1       Up ... (healthy)

twenty-redis-1    Up ... (healthy)

twenty-server-1   Up ... (healthy)

```



The Twenty CRM server was running and healthy after the EC2 stop/start.



This confirmed that the Docker containers configured with the restart policy were restored when Docker started after the EC2 restart.



\## 7. Application Verification After Recovery



The application was tested again using:



```bash

curl -I http://localhost:3000

```



The response was:



```text

HTTP/1.1 200 OK

```



This confirmed that Twenty CRM was successfully available after the EC2 recovery.



The Twenty CRM health endpoint was also verified:



```bash

curl -i http://localhost:3000/healthz

```



The response returned HTTP 200 with:



```json

{"status":"ok","info":{},"error":{},"details":{}}

```



\## 8. Logs Verification



Container logs were checked using:



```bash

docker logs --tail 80 twenty-server-1

```



The logs showed that the Nest application successfully started.



Docker service logs were also checked using:



```bash

sudo journalctl -u docker --since "10 minutes ago" --no-pager

```



These logs were used to verify Docker restart behavior during the failure test.



\## 9. Recovery Result



The final recovery test was successful.



After stopping and starting the EC2 instance:



1\. Docker service started automatically.

2\. PostgreSQL started and became healthy.

3\. Redis started and became healthy.

4\. Twenty CRM server started and became healthy.

5\. Twenty CRM returned HTTP 200.

6\. The application was available on port 3000.



\## Conclusion



Twenty CRM was successfully deployed on AWS EC2 using Docker.



The Docker health check and restart policy were configured and verified. The EC2 stop/start test confirmed that Docker starts automatically and the Twenty CRM services recover after an EC2 restart.



The application was finally verified with a healthy Docker status and an HTTP 200 response.




\# Task 16: Twenty CRM Failure \& Recovery



\## Objective



The objective of this task is to deploy Twenty CRM using Docker, configure

container restart and health-check mechanisms, simulate a container failure,

verify recovery, and inspect application logs.



The task also requires validation of application recovery after an EC2

stop/start operation.



\---



\## Environment



The practical testing was performed in a Killercoda Ubuntu playground.



\- Platform: Killercoda Ubuntu Playground

\- OS: Ubuntu 24.04

\- Docker: 29.1.3

\- Docker Compose: 2.40.3

\- Application: Twenty CRM

\- Docker Image: `twentycrm/twenty:latest`

\- Application Port: `3000`



> \*\*Environment limitation:\*\* The available testing environment was

> Killercoda Ubuntu and was not an AWS EC2 instance. Therefore, the EC2

> stop/start portion of the task could not be performed.



\---



\## Application Architecture



The deployment consists of three Docker services:



1\. Twenty CRM

2\. PostgreSQL 16

3\. Redis 7 Alpine



Twenty CRM is exposed on port `3000`.



The PostgreSQL and Redis services provide the database and caching

dependencies required by Twenty CRM.



\---



\## Docker Compose Configuration



Twenty CRM was configured with the Docker restart policy:



```yaml

restart: unless-stopped



A Docker health check was also configured:



healthcheck:

&#x20; test:

&#x20;   \[

&#x20;     "CMD-SHELL",

&#x20;     "node -e \\"fetch('http://127.0.0.1:3000/').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))\\""

&#x20;   ]

&#x20; interval: 30s

&#x20; timeout: 10s

&#x20; retries: 5

&#x20; start\_period: 60s



The health check verifies that the Twenty CRM application responds on

127.0.0.1:3000.



Initial Deployment



The application was started using:



docker compose up -d



The containers were verified using:



docker compose ps



The expected deployment state was:



twenty            twentycrm/twenty:latest   Up ... (healthy)

twenty-postgres   postgres:16               Up ... (healthy)

twenty-redis      redis:7-alpine            Up ...



PostgreSQL reached a healthy state and Twenty CRM completed its database

initialization and migrations.



Restart Policy Verification



The restart policy was verified using:



docker inspect -f 'Status={{.State.Status}} | Health={{.State.Health.Status}} | RestartPolicy={{.HostConfig.RestartPolicy.Name}}' twenty



The final verified configuration was:



Status=running | Health=healthy | RestartPolicy=unless-stopped



This confirms that the Twenty CRM container has the required

unless-stopped restart policy configured.



Application Health Verification



The application was tested using:



curl -s -o /dev/null -w 'HTTP=%{http\_code}\\n' http://localhost:3000



Result:



HTTP=200



This confirms that Twenty CRM was responding successfully on port 3000.



Failure Simulation



A manual container failure was simulated using:



docker kill twenty



The container then showed:



Exited (137)



The container state was verified using:



docker ps -a --filter name=twenty



The Twenty CRM container remained in the exited state after the failure

simulation.



Automatic Restart Observation



The configured restart policy was:



unless-stopped



However, in the Killercoda playground, the Twenty CRM container did not

automatically restart after:



docker kill twenty



The container remained:



Exited (137)



after waiting for the recovery period.



Therefore, automatic restart of the Twenty CRM container could not be

demonstrated successfully in this specific Killercoda environment.



This result is documented as an environment limitation rather than being

reported as a successful automatic-recovery test.



Manual Recovery



The stopped Twenty CRM container was manually restarted:



docker start twenty



After allowing the application time to initialize:



sleep 60



the container was checked again:



docker inspect -f 'Status={{.State.Status}} | Health={{.State.Health.Status}} | RestartPolicy={{.HostConfig.RestartPolicy.Name}}' twenty



Final result:



Status=running | Health=healthy | RestartPolicy=unless-stopped



The application was then tested again:



curl -s -o /dev/null -w 'HTTP=%{http\_code}\\n' http://localhost:3000



Result:



HTTP=200



This confirms that Twenty CRM successfully recovered after a manual

container restart.



Application Logs



Application logs were inspected using:



docker logs twenty --tail 30



The logs showed successful application initialization.



An important startup message was:



\[NestApplication] Nest application successfully started



The logs also showed database configuration and upgrade metadata processing

during application startup.



This confirms that the application successfully completed its startup

sequence after recovery.



EC2 Stop/Start Recovery



The assignment requires:



Stop the EC2 instance.

Start the EC2 instance again.

Verify that Twenty CRM starts automatically.

Verify application health.



This test was not performed because the available practical environment

was a Killercoda Ubuntu playground rather than an AWS EC2 instance.



No EC2 stop/start recovery result is claimed.



Verification Summary

Test	Result

Twenty CRM Docker deployment	Completed

PostgreSQL health check	Healthy

Redis service	Running

Twenty CRM health check	Healthy

Restart policy configured	unless-stopped

Application HTTP test	HTTP 200

Container failure simulation	Completed

Failure exit code	137

Automatic Twenty container restart	Not observed in Killercoda

Manual container recovery	Successful

Post-recovery health	Healthy

Post-recovery HTTP test	HTTP 200

Application logs	Verified

EC2 stop/start recovery	Not tested — Killercoda environment

Conclusion



Twenty CRM was successfully deployed using Docker Compose with a Docker

health check and the unless-stopped restart policy.



The application was successfully verified as healthy and responding with

HTTP 200.



A container failure was simulated using docker kill, producing an

Exited (137) state. The container did not automatically restart in the

Killercoda playground, so the automatic restart behavior could not be

demonstrated in this environment.



The container was manually restarted and Twenty CRM successfully returned to

a healthy state with HTTP 200.



Application logs confirmed successful NestJS application startup.



The EC2 stop/start recovery requirement could not be tested because the

available environment was Killercoda rather than AWS EC2. This limitation

has been documented explicitly.




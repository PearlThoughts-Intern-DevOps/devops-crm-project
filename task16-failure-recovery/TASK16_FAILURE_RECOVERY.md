# Task 16 — Twenty CRM Failure & Recovery

## Objective

Deploy Twenty CRM on an AWS EC2 instance using Docker and verify failure recovery using Docker restart policies and EC2 reboot recovery.

## Environment

* Cloud: AWS EC2
* Region: us-east-1
* Instance Type: t3.small
* OS: Amazon Linux 2023
* Docker: 25.0.14
* Application: Twenty CRM
* Application Port: 2020
* Container Port: 3000

## Docker Containers

The deployment uses three Docker containers:

* `twenty-crm-task16` — Twenty CRM application
* `twenty-task16-postgres` — PostgreSQL database
* `twenty-task16-redis` — Redis

All containers are connected through the Docker network:

`twenty-task16-network`

## Restart Policy

Twenty CRM was configured with:

`--restart always`

PostgreSQL and Redis were also configured with the `always` restart policy so that the required application dependencies start automatically after an EC2 reboot.

## Health Check

Twenty CRM was configured with a Docker health check:

`curl -f http://localhost:3000/ || exit 1`

The container was verified with the status:

`healthy`

## Failure and Recovery Test

The Twenty CRM container was manually stopped/killed during testing.

The container stopped with exit code 137. The container was then started again and the application recovered successfully.

After recovery, the Twenty CRM health status was verified as:

`healthy`

## EC2 Reboot Recovery Test

The EC2 instance was rebooted using:

`sudo reboot`

After reconnecting to the EC2 instance, PostgreSQL and Redis were initially stopped while Twenty CRM was restarting.

The restart policy was then applied to PostgreSQL and Redis, and both containers were started again.

Twenty CRM subsequently started successfully.

Final verification showed:

* Twenty CRM: `Up` and `healthy`
* PostgreSQL: `Up`
* Redis: `Up`
* Twenty CRM restart policy: `always`

## Application Verification

Twenty CRM was verified from inside the container using:

`curl -I http://localhost:3000/`

The application returned:

`HTTP/1.1 200 OK`

## Logs

Docker logs were checked using:

`sudo docker logs --tail 30 twenty-crm-task16`

The logs showed:

`Nest application successfully started`

The logs also contained a `core.keyValuePair` database configuration warning. This did not prevent the application from starting, and the Docker health check reported the application as healthy.

## Recovery Summary

The failure and recovery workflow was successfully tested:

1. Twenty CRM was deployed using Docker.
2. Docker restart policy was configured.
3. Docker health check was configured.
4. Container failure was tested.
5. Twenty CRM was recovered.
6. EC2 was rebooted.
7. PostgreSQL and Redis were restarted.
8. Twenty CRM started successfully.
9. Final health status was verified as `healthy`.

## Conclusion

Twenty CRM was successfully deployed on EC2 with Docker health monitoring and restart policies. Failure recovery and EC2 reboot recovery were tested and documented.

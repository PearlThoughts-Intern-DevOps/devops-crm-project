# Task 7: Deploy Twenty CRM on AWS EC2

**Name:** Mujtaba Shaikh
**Date:** 2 September 2026
**Project:** devops-crm-project

---

## 1. Task Objective

The objective of this task was to deploy the Twenty CRM application on an AWS EC2 instance using Docker Compose.

The deployment included the following services:

* Twenty CRM
* PostgreSQL
* Redis

The application was configured to run on an EC2 instance and made accessible externally through the EC2 public IP.

---

## 2. Deployment Environment

The deployment was performed on an AWS EC2 instance.

### Environment

* Cloud Provider: AWS
* Service: EC2
* Operating System: Linux
* Container Runtime: Docker
* Container Orchestration: Docker Compose
* Application: Twenty CRM
* Database: PostgreSQL 16
* Cache: Redis 7
* Application Port: 2020
* Internal Twenty CRM Port: 3000

The Docker Compose configuration mapped:

```text
EC2 Port 2020 → Twenty CRM Port 3000
```

---

## 3. Project Repository

The existing `devops-crm-project` repository was used for the deployment.

The project was accessed on the EC2 instance and the Docker Compose configuration was used to start the required services.

The working directory was:

```bash
~/devops-crm-project
```

---

## 4. Docker Compose Services

The Docker Compose deployment contained the following services.

### 4.1 Twenty CRM

Twenty CRM was deployed using the Docker image:

```text
twentycrm/twenty:latest
```

The application container exposes port `3000` internally.

It was mapped to port `2020` on the EC2 host:

```text
0.0.0.0:2020 → 3000
```

### 4.2 PostgreSQL

PostgreSQL was deployed using:

```text
postgres:16-alpine
```

PostgreSQL was configured as the database service for Twenty CRM.

A health check was configured to verify that the database was ready.

### 4.3 Redis

Redis was deployed using:

```text
redis:7-alpine
```

Redis was configured as the caching service for Twenty CRM.

A health check was used to verify that Redis was running correctly.

---

## 5. Starting the Deployment

The Docker Compose services were started on the EC2 instance using Docker Compose.

The deployment was checked using:

```bash
docker compose ps
```

This command was used to verify the status of the containers.

---

## 6. Initial Deployment Verification

After starting the services, the Docker Compose status was checked.

The main containers were successfully started:

```text
twenty-crm
twenty-postgres
twenty-redis
```

PostgreSQL and Redis reported a healthy status.

The Twenty CRM application container was running and exposed through port `2020`.

---

## 7. Issue Encountered: SERVER_URL Configuration

During the deployment, the application was initially configured with a local URL using:

```text
localhost
```

Since the application was deployed on an AWS EC2 instance and needed to be accessed externally, using `localhost` was not suitable for external access.

The application URL configuration was updated to use the EC2 public IP.

The configured URL became:

```text
http://100.55.46.176:2020
```

This allowed Twenty CRM to use the EC2 public address for external access.

---

## 8. AWS Security Group Configuration

The EC2 Security Group was configured to allow inbound traffic on port:

```text
2020
```

This port was required because the Twenty CRM application was exposed on port `2020` on the EC2 host.

After allowing port `2020`, the application could be accessed from an external browser.

---

## 9. Docker Compose Status Verification

The deployment status was verified using:

```bash
docker compose ps
```

The output confirmed that the required services were running.

The Twenty CRM service showed the following port mapping:

```text
0.0.0.0:2020->3000/tcp
```

PostgreSQL and Redis showed:

```text
Up (healthy)
```

This confirmed that the application, database, and cache services were running correctly.

---

## 10. Browser Verification

The final deployment was verified from an external browser.

The following URL was opened:

```text
http://100.55.46.176:2020/objects/companies
```

The Twenty CRM Companies page loaded successfully.

Company data was also visible on the page.

This confirmed that the application was accessible externally through the EC2 public IP and port `2020`.

---

## 11. Final Deployment Verification

The following checks were successfully completed:

| Check                        | Status                   |
| ---------------------------- | ------------------------ |
| AWS EC2 instance             | Passed                   |
| Docker installed and running | Passed                   |
| Docker Compose deployment    | Passed                   |
| Twenty CRM container         | Running                  |
| PostgreSQL container         | Healthy                  |
| Redis container              | Healthy                  |
| Application port 2020        | Accessible               |
| Security Group port 2020     | Configured               |
| SERVER_URL                   | Updated to EC2 public IP |
| External browser access      | Passed                   |
| Companies page               | Successfully loaded      |
| Company data displayed       | Passed                   |

---

## 12. Final Result

Twenty CRM was successfully deployed on AWS EC2 using Docker Compose.

The deployment includes:

```text
Twenty CRM
PostgreSQL
Redis
```

The PostgreSQL and Redis containers were verified as healthy.

The Twenty CRM container was running and exposed through EC2 port `2020`.

The EC2 Security Group was configured to allow access to port `2020`.

The application URL was updated from the local `localhost` address to the EC2 public IP.

The final browser verification confirmed that the Twenty CRM Companies page was accessible and displaying company data.

---

## 13. Conclusion

Task 7 successfully demonstrated the deployment of Twenty CRM on an AWS EC2 instance using Docker Compose.

The application was configured with PostgreSQL and Redis, exposed through the EC2 instance, and made accessible externally by configuring the required Security Group port.

The deployment was verified using Docker Compose status checks and external browser access.

The final application was accessible at:

```text
http://100.55.46.176:2020
```

The Twenty CRM Companies page was successfully loaded and verified with company data.

**Task 7 deployment verification: Completed.**


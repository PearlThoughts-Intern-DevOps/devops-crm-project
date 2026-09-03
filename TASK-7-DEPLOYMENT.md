\# Task 7 – Deploy Twenty CRM on AWS EC2



\## Objective



Deploy Twenty CRM on an AWS EC2 instance using Docker and Docker Compose, configure the required services, verify the deployment, and document the complete process.



\## 1. EC2 Configuration



\- OS: Amazon Linux 2023

\- Architecture: x86\_64

\- RAM: \~2 GB

\- Storage: 20 GB

\- SSH Client: MobaXterm

\- Application Port: 3000



\### Security Group



| Protocol | Port | Source |

|---|---:|---|

| TCP | 22 | My IP |

| TCP | 3000 | 0.0.0.0/0 |



\## 2. Clone Repository



```bash

git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git

cd devops-crm-project

```



Create the required branch:



```bash

git checkout -b Puneet-Task-7

```



Verify:



```bash

git branch --show-current

```



\## 3. Docker Setup



Verify Docker:



```bash

docker --version

docker version

```



Verify Docker Compose:



```bash

docker compose version

```



Docker Buildx was updated because the initial version was not compatible with the Docker Compose build requirement.



Verify:



```bash

docker buildx version

```



\## 4. Docker Compose Architecture



The deployment consists of the following services:



\- PostgreSQL 16 – Database

\- Redis 7 – Cache and queue

\- Twenty CRM – CRM server

\- Twenty Worker – Background jobs

\- Custom App – Internship application



Architecture:



```text

\&#x20;                   AWS EC2

\&#x20;                      |

\&#x20;               Docker Network

\&#x20;                      |

\&#x20;      +---------------+---------------+

\&#x20;      |               |               |

\&#x20;  PostgreSQL         Redis        Twenty CRM

\&#x20;    :5432            :6379           :3000

\&#x20;                                      |

\&#x20;                                    Worker

\&#x20;                                      |

\&#x20;                                 Custom App

```



\## 5. Environment Configuration



Created a `.env` file with the required configuration:



```env

SERVER\\\_URL=http://<EC2-PUBLIC-IP>:3000



PG\\\_DATABASE\\\_USER=postgres

PG\\\_DATABASE\\\_HOST=db

PG\\\_DATABASE\\\_PORT=5432

PG\\\_DATABASE\\\_NAME=default



REDIS\\\_URL=redis://redis:6379

STORAGE\\\_TYPE=local



ENCRYPTION\\\_KEY=<secret>

APP\\\_SECRET=<secret>



TWENTY\\\_API\\\_URL=http://twenty:3000

TWENTY\\\_API\\\_KEY=<secret>

```



Protected the environment file:



```bash

chmod 600 .env

```



Sensitive values were not committed to Git.



\## 6. Pull Docker Images



```bash

docker compose pull db redis twenty worker

```



Required images:



```text

postgres:16

redis:7

twentycrm/twenty:latest

```



\## 7. Start PostgreSQL, Redis and Twenty



```bash

docker compose up -d db redis twenty

```



Verify:



```bash

docker compose ps

```



PostgreSQL, Redis and Twenty were verified as healthy.



\## 8. Twenty CRM Health Check



Check the health endpoint:



```bash

curl -i http://127.0.0.1:3000/healthz

```



Expected response:



```text

HTTP/1.1 200 OK

```



Response:



```json

{"status":"ok","info":{},"error":{},"details":{}}

```



The health endpoint was also successfully verified using the EC2 public IP.



\## 9. Start Twenty Worker



```bash

docker compose up -d worker

```



Check worker logs:



```bash

docker compose logs worker --tail=100

```



The worker was running with database migration and cron registration disabled as configured in Docker Compose.



\## 10. Build Custom Application



Build the application image:



```bash

docker compose build --progress=plain app

```



The build completed successfully:



```text

Image devops-crm-project-app Built

```



\### Dockerfile Change



The repository did not contain the required `.yarn` directory, so the following Dockerfile instruction was removed:



```dockerfile

COPY .yarn/ .yarn/

```



The application was successfully built using the existing Yarn/Corepack setup.



\## 11. Memory Optimization



The EC2 instance had approximately 2 GB RAM and initially had no swap.



High memory usage occurred while running Twenty and the worker during the application build.



A 2 GB swap file was created:



```bash

sudo fallocate -l 2G /swapfile

sudo chmod 600 /swapfile

sudo mkswap /swapfile

sudo swapon /swapfile

```



Verify:



```bash

free -h

```



The worker was temporarily stopped during the application build to reduce memory usage.



\## 12. Twenty API Integration



A Twenty API key was generated from the self-hosted Twenty CRM instance and configured in `.env`.



The API connection was tested using Node.js:



```bash

docker compose run --rm app node -e 'fetch("http://twenty:3000/rest/companies",{headers:{Authorization:`Bearer ${process.env.TWENTY\\\_API\\\_KEY}`}}).then(async r=>{console.log("HTTP:",r.status); console.log("Response:",(await r.text()).slice(0,300))}).catch(e=>{console.error(e);process.exit(1)})'

```



Result:



```text

HTTP: 200

```



This confirmed that the custom application could successfully authenticate and communicate with Twenty through the Docker network.



\## 13. Start Custom Application



```bash

docker compose up -d app

```



Check application logs:



```bash

docker compose logs app --tail=100

```



The application successfully authenticated with Twenty and began application processing.



\## 14. Browser Verification



Twenty CRM was accessed using:



```text

http://<EC2-PUBLIC-IP>:3000

```



The Twenty CRM interface loaded successfully and company records were displayed.



\## 15. Issues Faced and Solutions



\### Buildx Version Error



\*\*Issue:\*\*



```text

compose build requires buildx 0.17.0 or later

```



\*\*Solution:\*\* Updated Docker Buildx to a compatible version.



\### Missing `.yarn` Directory



\*\*Issue:\*\* The Dockerfile attempted to copy a `.yarn` directory that was not present in the repository.



\*\*Solution:\*\* Removed:



```dockerfile

COPY .yarn/ .yarn/

```



The Docker image then built successfully.



\### High Memory Usage



\*\*Issue:\*\* The EC2 instance had limited RAM and no swap.



\*\*Solution:\*\*



\- Temporarily stopped the worker during the application build.

\- Added a 2 GB swap file.



\### Twenty Health Check



\*\*Issue:\*\* Twenty initially showed an unhealthy status.



\*\*Solution:\*\* Checked the `/healthz` endpoint and confirmed:



```text

HTTP/1.1 200 OK

```



Twenty subsequently reported a healthy status.



\### API Authentication Failure



\*\*Issue:\*\*



```text

Authentication failed on remote "docker"

```



\*\*Solution:\*\* Replaced the invalid API key with a valid API key generated from the self-hosted Twenty instance.



API verification then returned:



```text

HTTP: 200

```



\### External Access



\*\*Issue:\*\* Twenty was initially inaccessible from the browser.



\*\*Solution:\*\*



\- Verified Docker was listening on `0.0.0.0:3000`.

\- Verified the EC2 public IP.

\- Added TCP port `3000` to the EC2 Security Group.

\- Verified external access successfully.



\## 16. Final Verification



Check all containers:



```bash

docker compose ps

```



Expected services:



```text

devops-crm-postgres

devops-crm-redis

devops-crm-twenty

devops-crm-worker

devops-crm-app

```



Additional checks:



```bash

docker stats --no-stream

docker system df

docker compose logs twenty --tail=100

docker compose logs worker --tail=100

docker compose logs app --tail=100

```



\## 17. Security



The following sensitive information was kept out of Git:



\- `.env`

\- PostgreSQL password

\- Twenty API key

\- Encryption key

\- Application secret

\- SSH private key



\## 18. Cleanup



After completing the task:



```bash

docker compose down

```



The EC2 instance should also be stopped or terminated when no longer required to avoid unnecessary AWS charges.



\## Conclusion



Twenty CRM was successfully deployed on Amazon Linux 2023 EC2 using Docker Compose.



The deployment includes:



\- PostgreSQL 16

\- Redis 7

\- Twenty CRM

\- Twenty Worker

\- Custom application

\- Docker networking

\- Persistent storage

\- Twenty API integration

\- EC2 Security Group configuration



The deployment was verified through container health checks, the Twenty `/healthz` endpoint, API authentication, and browser access.



\*\*Branch:\*\* `Puneet-Task-7`




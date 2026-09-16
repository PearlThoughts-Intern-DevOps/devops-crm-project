# Task 16 — Twenty CRM Failure & Recovery

## Objective

The objective of Task 16 was to run Twenty CRM on an AWS EC2 instance using Docker, configure automatic container recovery, add a Docker health check, test failure recovery, and document the recovery process.

## Infrastructure

* AWS Region: `us-east-1`
* EC2 Instance Type: `t3.small`
* Approved AMI: `ami-081b0a6eac00b4f53`
* Application Port: `2020`
* Docker Image: `twentycrm/twenty-app-dev:v2.35`
* Docker Container: `twenty`
* Docker Restart Policy: `unless-stopped`
* Persistent Docker Volume: `twenty-data`

## Terraform Configuration

Terraform was used to provision the EC2 instance and security group.

The EC2 User Data automatically:

1. Updated the operating system.
2. Installed Docker.
3. Enabled and started the Docker service.
4. Pulled the Twenty CRM Docker image.
5. Created the `twenty` container.
6. Configured the container with `--restart unless-stopped`.
7. Configured a Docker health check.
8. Exposed Twenty CRM on port `2020`.
9. Mounted the persistent `twenty-data` Docker volume.

Terraform validation completed successfully and the infrastructure was applied successfully.

## Automatic Container Recovery

The container was configured with:

```text
--restart unless-stopped
```

This configuration allows Docker to automatically start the Twenty CRM container again when the Docker daemon or EC2 host starts.

During testing, the EC2 instance rebooted as part of the initial provisioning process. After Docker started again, the `twenty` container was present and running automatically.

This confirmed that the Docker restart policy and Docker service startup configuration were working.

## Docker Health Check

A Docker health check was added to the Twenty CRM container.

The container remained in the `running` state, but the health status remained `unhealthy` during testing.

Application logs showed that the Twenty CRM services and database initialization completed successfully, including:

```text
Database ready
twenty-server successfully started
twenty-worker successfully started
```

Additional testing showed that the application process was listening on TCP port `2020`, while HTTP health-check requests were being reset/refused from the tested endpoints.

Due to the limited availability of the temporary AWS account session, further health-check troubleshooting was stopped to avoid risking the remaining infrastructure verification time.

Therefore, the health-check issue is documented as a known limitation rather than being presented as successfully resolved.

## Failure & Recovery Verification

The following recovery behavior was verified during provisioning:

* Docker service was enabled to start automatically.
* The Twenty CRM container was configured with `restart: unless-stopped`.
* The container was present and running after the Docker service restarted.
* Persistent Docker volume `twenty-data` was present.
* Twenty CRM application processes started successfully.

The manual container-kill and complete EC2 stop/start recovery tests were not completed because the temporary AWS session became unavailable during final verification.

## Logs

The container logs showed successful application initialization:

```text
Database ready
twenty-server successfully started
twenty-worker successfully started
```

Docker service logs also confirmed that the Docker daemon initialized successfully and loaded the container state.

## Result

Task 16 infrastructure and Docker recovery configuration were implemented using Terraform.

The main recovery mechanism was successfully configured and observed:

```text
EC2/Docker startup
       ↓
Docker service starts
       ↓
Twenty CRM container starts
       ↓
--restart unless-stopped
```

The Docker health check remained unhealthy during the available test window and is documented as a limitation requiring further investigation.

## Files

The Task 16 implementation is located under:

```text
terraform/
docs/task-16-failure-recovery.md
```

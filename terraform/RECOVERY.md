# Task 16 – Twenty CRM Failure & Recovery

## Objective

The objective of Task 16 is to configure and verify failure recovery for the Twenty CRM application running on an AWS EC2 instance using Docker.

## Environment

* AWS EC2
* Amazon Linux
* Docker 25.0.14
* Twenty CRM
* PostgreSQL 16
* Redis
* Terraform
* AWS Region: `us-east-1`
* Application Port: `8080`
* Container Port: `3000`

## 1. Run Twenty CRM with Docker

Twenty CRM was deployed on the EC2 instance using Docker.

The following containers were running:

* `twenty-crm`
* `twenty-db`
* `twenty-redis`

Twenty CRM exposes port `3000` inside the container and port `8080` on the EC2 instance.

The application was verified successfully from inside the container:

```bash
sudo docker exec twenty-crm sh -c 'wget -qO- http://localhost:3000/ >/dev/null && echo "APP OK" || echo "APP FAILED"'
```

Result:

```text
APP OK
```

## 2. Docker Restart Policy

The Twenty CRM container was configured with the Docker restart policy:

```text
RestartPolicy=always
```

The configuration was verified using:

```bash
sudo docker inspect twenty-crm --format 'Status={{.State.Status}} RestartPolicy={{.HostConfig.RestartPolicy.Name}} RestartCount={{.RestartCount}} Health={{.State.Health.Status}}'
```

Final verification:

```text
Status=running
RestartPolicy=always
RestartCount=1
Health=healthy
```

The `always` restart policy allows Docker to automatically restart the container after an unexpected container failure and also allows the container to start when the Docker daemon starts after an EC2 reboot.

## 3. Docker Health Check

A Docker health check was configured for Twenty CRM.

The health check verifies that the application is responding on port `3000` inside the container.

Example health check command:

```bash
curl -f http://localhost:3000/ || exit 1
```

The health check initially reported failures while the application was starting:

```text
curl: (7) Failed to connect to localhost:3000
```

After Twenty CRM finished starting, the health check succeeded and the container became:

```text
Health=healthy
```

The application was also independently verified using:

```bash
sudo docker exec twenty-crm sh -c 'wget -qO- http://localhost:3000/ >/dev/null && echo "APP OK" || echo "APP FAILED"'
```

Result:

```text
APP OK
```

## 4. Simulate Container Failure

A failure was manually simulated by terminating the main process inside the Twenty CRM container:

```bash
sudo docker exec twenty-crm sh -c 'kill 1'
```

This caused the Twenty CRM container to stop.

The container was then automatically restarted by Docker because the restart policy was set to `always`.

## 5. Verify Automatic Container Recovery

The recovery was verified using:

```bash
sudo docker inspect twenty-crm --format 'Status={{.State.Status}} RestartCount={{.RestartCount}} Health={{.State.Health.Status}}'
```

Result:

```text
Status=running
RestartCount=1
Health=healthy
```

The container was also visible in the running container list:

```bash
sudo docker ps
```

Result included:

```text
twenty-crm    Up ... (healthy)
twenty-redis  Up ...
twenty-db     Up ...
```

This confirmed successful automatic recovery after the container process was terminated.

## 6. Stop and Restart EC2 Instance

The EC2 instance was restarted to test recovery at the infrastructure level.

After reconnecting to the EC2 instance, Docker was verified:

```bash
sudo systemctl status docker --no-pager
```

Docker was running successfully after the EC2 restart.

The Docker containers were then checked:

```bash
sudo docker ps
```

The Twenty CRM container was running and healthy after the EC2 restart.

## 7. Verify Twenty CRM Recovery After EC2 Restart

The final Twenty CRM status was verified using:

```bash
sudo docker inspect twenty-crm --format 'Status={{.State.Status}} RestartPolicy={{.HostConfig.RestartPolicy.Name}} RestartCount={{.RestartCount}} Health={{.State.Health.Status}}'
```

Final result:

```text
Status=running
RestartPolicy=always
RestartCount=1
Health=healthy
```

This confirms that Twenty CRM automatically started again after the EC2 instance restart.

PostgreSQL and Redis were also running successfully:

```text
twenty-redis    Up
twenty-db       Up
twenty-crm      Up (healthy)
```

## 8. Logs and Recovery Verification

Twenty CRM application logs were checked using:

```bash
sudo docker logs --tail 30 twenty-crm
```

The logs showed successful application startup, including:

```text
[NestApplication] Nest application successfully started
```

Docker service logs were checked using:

```bash
sudo journalctl -u docker --since "20 minutes ago" --no-pager
```

These logs confirmed that the Docker service successfully started after the EC2 restart.

Container health-check logs were also inspected using:

```bash
sudo docker inspect twenty-crm --format '{{range .State.Health.Log}}{{println "ExitCode:" .ExitCode "Output:" .Output}}{{end}}'
```

The health check initially failed while the application was starting and later succeeded when Twenty CRM became available.

## 9. Failure and Recovery Summary

### Failure Scenario 1 – Container Failure

**Failure:**

The Twenty CRM main process was terminated manually.

```bash
sudo docker exec twenty-crm sh -c 'kill 1'
```

**Recovery mechanism:**

Docker restart policy:

```text
always
```

**Recovery result:**

```text
Status=running
RestartCount=1
Health=healthy
```

### Failure Scenario 2 – EC2 Restart

**Failure/maintenance event:**

The EC2 instance was restarted.

**Recovery mechanism:**

* EC2 restarted successfully.
* Docker service started automatically.
* Twenty CRM container started automatically because of the Docker restart policy.
* PostgreSQL and Redis also started.
* Twenty CRM health check became healthy.

**Final result:**

```text
twenty-crm    running / healthy
twenty-db     running
twenty-redis  running
Docker        active (running)
```

## 10. Conclusion

Task 16 successfully demonstrated failure recovery for Twenty CRM.

The implementation provides two levels of recovery:

1. **Container-level recovery** using Docker's `restart: always` policy.
2. **EC2-level recovery** because Docker starts automatically with the EC2 instance and restores containers configured with the restart policy.

The Twenty CRM application was successfully recovered after a simulated container failure and after an EC2 restart.

Final verified state:

```text
Container       Status       Health       Restart Policy
---------------------------------------------------------
twenty-crm      running      healthy      always
twenty-db       running      N/A          -
twenty-redis    running      N/A          -
```

Therefore, the failure recovery requirements for Task 16 were successfully completed.

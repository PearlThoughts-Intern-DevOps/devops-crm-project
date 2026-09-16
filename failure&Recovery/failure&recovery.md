# Commands, Process and Testing

## 1. Verify Twenty CRM

Check the running container:

```bash
docker ps -a
```

Check the restart policy:

```bash
docker inspect twenty-app-dev --format='Restart Policy: {{.HostConfig.RestartPolicy.Name}}'
```

Check the health:

```bash
docker inspect twenty-app-dev --format='Health: {{.State.Health.Status}}'
```

Test the application:

```bash
curl http://localhost:2020/healthz
```

Expected:

```text
{"status":"ok","info":{},"error":{},"details":{}}
```

## 2. Test Docker Stop

To test an intentional container stop:

```bash
docker stop twenty-app-dev
```

Verify:

```bash
docker ps -a
```

The container should show:

```text
Exited
```

Try to access the application:

```bash
curl http://localhost:2020/healthz
```

The request should fail because the container is stopped.

Start the container again:

```bash
docker start twenty-app-dev
```

Check:

```bash
docker ps
```

Wait for the application to start and verify:

```bash
docker inspect twenty-app-dev --format='Health: {{.State.Health.Status}}'
curl http://localhost:2020/healthz
```

After recovery:

```text
Health: healthy
```

and the health endpoint should return HTTP 200.

**Note:** `docker stop` is an intentional/manual stop. It is not used to demonstrate unexpected failure recovery.

## 3. Test Unexpected Container Failure

First obtain the container's host PID:

```bash
PID=$(docker inspect --format '{{.State.Pid}}' twenty-app-dev)
echo "Container PID: $PID"
```

Terminate the container's main process:

```bash
sudo kill -9 $PID
```

This simulates an unexpected container failure.

Verify the container:

```bash
docker ps -a
```

Check the restart count:

```bash
docker inspect twenty-app-dev --format='Restart Count: {{.RestartCount}}'
```

With the restart policy configured as:

```text
unless-stopped
```

Docker automatically starts the container again.

Verify:

```bash
docker ps
```

Wait for startup:

```bash
docker inspect twenty-app-dev --format='Health: {{.State.Health.Status}}'
```

Then:

```bash
curl http://localhost:2020/healthz
```

The restart count increases and the application becomes healthy again.

## 4. Check Application Logs

After recovery:

```bash
docker logs --tail 100 twenty-app-dev
```

Logs are checked for successful Twenty CRM startup, worker initialization, and other application services.

## 5. EC2 Stop Test

Before stopping the instance:

```bash
docker ps
docker inspect twenty-app-dev --format='Health: {{.State.Health.Status}}'
sudo systemctl is-active docker
```

Confirm that Twenty CRM is running and healthy.

Stop the EC2 instance from the AWS EC2 Console.

Expected behavior:

```text
EC2 stopped
↓
Docker service stops
↓
Twenty CRM container stops
```

## 6. EC2 Start Test

Start the same EC2 instance from the AWS EC2 Console.

After reconnecting through SSH:

```bash
sudo systemctl is-active docker
```

Expected:

```text
active
```

Check the container:

```bash
docker ps -a
```

Check the restart policy:

```bash
docker inspect twenty-app-dev --format='Restart Policy: {{.HostConfig.RestartPolicy.Name}}'
```

Check health:

```bash
docker inspect twenty-app-dev --format='Health: {{.State.Health.Status}}'
```

Wait until:

```text
healthy
```

Test the application:

```bash
curl http://localhost:2020/healthz
```

The application should return:

```text
{"status":"ok","info":{},"error":{},"details":{}}
```

## 7. EC2 Stop/Start Recovery Result

The test demonstrated:

```text
EC2 Stop
   ↓
Instance powered off
   ↓
EC2 Start
   ↓
Docker service available
   ↓
Twenty CRM container running
   ↓
Health check passes
   ↓
Twenty CRM accessible
```

## 8. Final Testing Summary

| Test                 | Command/Action                       | Result                                   |
| -------------------- | ------------------------------------ | ---------------------------------------- |
| Container status     | `docker ps`                          | Container running                        |
| Health check         | `curl http://localhost:2020/healthz` | HTTP 200                                 |
| Docker stop          | `docker stop twenty-app-dev`         | Container stopped                        |
| Manual recovery      | `docker start twenty-app-dev`        | Container started                        |
| Unexpected failure   | `sudo kill -9 $PID`                  | Docker automatically restarted container |
| Restart verification | `docker inspect ... RestartCount`    | Restart count increased                  |
| Application recovery | `/healthz`                           | Healthy                                  |
| EC2 stop             | AWS Console → Stop                   | Instance stopped                         |
| EC2 start            | AWS Console → Start                  | Instance started                         |
| Post-EC2 recovery    | `docker ps` / `/healthz`             | Twenty CRM available                     |

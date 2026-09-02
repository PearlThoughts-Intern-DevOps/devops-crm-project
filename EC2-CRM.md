# Twenty CRM Deployment on AWS EC2

## 1. Objective

Deploy Twenty CRM on AWS EC2 using Docker, configure the required environment, synchronize the custom application, troubleshoot issues, and verify the deployment.

## 2. EC2 Configuration

* **Cloud:** AWS EC2
* **Region:** `us-east-1`
* **OS:** Amazon Linux
* **Application Port:** `2020`

### Security Group

The following inbound rules were configured:

| Protocol | Port | Purpose      |
| -------- | ---: | ------------ |
| SSH      |   22 | EC2 access   |
| HTTP     |   80 | HTTP access  |
| HTTPS    |  443 | HTTPS access |
| TCP      | 2020 | Twenty CRM   |





## 4. SSH Connection

From Windows:

```powershell
ssh -i "C:\Users\Rohith\Downloads\Rokey.pem" ec2-user@<EC2-PUBLIC-IP>
```

Connected successfully to the EC2 instance.

## 5. Clone / Access Project

```bash
cd ~/devops-crm-project
```

Checked the project files:

```bash
ls
```

The project uses Node.js and Yarn.

## 6. Install Dependencies

```bash
yarn install --immutable
```

The project requires Node.js 24.x as specified in `.nvmrc`.

## 7. Memory / Swap Issue

The initial EC2 instance had limited RAM, causing processes to be killed with an OOM error.

Checked memory:

```bash
free -h
```

Added 2 GB swap:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

Verified:

```bash
free -h
```

## 8. Docker Setup

Started and enabled Docker:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

Added the EC2 user to Docker group:

```bash
sudo usermod -aG docker ec2-user
```

Reconnected through SSH and verified:

```bash
docker ps
```

## 9. Start Twenty CRM

Started Twenty using:

```bash
yarn twenty docker:start
```

This started the Twenty development environment using:

```text
twentycrm/twenty-app-dev:latest
```

Checked the container:

```bash
docker ps
```

## 10. Verify Twenty

```bash
yarn twenty docker:status
```

Expected result:

```text
Status: running (healthy)
URL: http://localhost:2020
```

Also verified the HTTP server:

```bash
curl -I http://localhost:2020
```

Result:

```text
HTTP/1.1 200 OK
```

## 11. Twenty CLI Authentication Issue

Running:

```bash
yarn twenty dev
```

initially caused OAuth authentication to time out because the CLI was running on EC2 while the browser was on the local system.

### Solution

Configured API-key authentication:

```bash
yarn twenty remote:add
```

After authentication, the remote was successfully added.

## 12. Application Synchronization

Ran:

```bash
yarn twenty dev
```

Successful output included:

```text
Successfully built manifest
App registration created: My app
Application installed
Successfully uploaded 4 files
✓ Synced
```

Final verification:

```text
Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done
Entities ✓ 7 synced
```

## 13. Access Twenty CRM

From the local browser:

```text
http://<EC2-PUBLIC-IP>:2020
```

The **My app** application was also verified under:

```text
Settings → Applications → My app
```

## 14. Other Issues

### Twenty Startup Issue

Twenty initially failed to become healthy after startup.

Checked logs:

```bash
docker logs twenty-app-dev --tail 200
```

After restarting and resolving the environment/memory issues, the container became healthy.

### Gmail Integration Error

Logs showed:

```text
REFRESH_TOKEN_NOT_FOUND
```

This was related to the Gmail integration and did not affect the main Twenty CRM deployment.

## 15. Final Verification

* EC2 SSH access — ✓
* Docker — ✓
* Twenty container — ✓
* Twenty server healthy — ✓
* Port 2020 accessible — ✓
* HTTP/HTTPS Security Group rules — ✓
* Twenty CLI authentication — ✓
* Custom application synchronized — ✓
* `My app` installed — ✓
* 7 entities synchronized — ✓

## 16. Cleanup

After completing the task and recording the Loom video, stop the EC2 instance from:

```text
AWS Console → EC2 → Instances → Instance state → Stop
```

This prevents unnecessary compute charges.

## 17. Conclusion

Twenty CRM was successfully deployed on AWS EC2 using Docker. The custom application was built, uploaded, synchronized, and verified successfully after resolving IAM, memory, Docker, networking, and authentication issues.

\# Task 16 - Twenty CRM Failure \& Recovery



\## Setup

\- EC2 instance: i-0156f39b5d83f1497 (t3.small, Ubuntu, AMI ami-0b6d9d3d33ba97d99)

\- Twenty CRM deployed via official docker-compose (server, worker, db, redis)

\- Location: \~/twenty-crm on EC2



\## 1. Restart Policy

`restart: always` set on all 4 services (server, worker, db, redis) in docker-compose.yml (pre-included in official Twenty compose file).



\## 2. Health Check

```yaml

healthcheck:

&#x20; test: curl --fail http://localhost:3000/healthz

&#x20; interval: 5s

&#x20; timeout: 5s

&#x20; retries: 20

```

Configured on the `server` service.



\## 3. Manual Kill Test

Command: `docker kill twenty-server-1`

Result: Container exited, then automatically restarted by Docker's restart policy. Verified via `docker ps` (container back to Up/healthy) and app returning HTTP 200 on curl after restart completed (\~2 min startup time under low-memory conditions).



\## 4. Memory Note

Instance initially hit near-OOM (t3.small = 2GB RAM running 4 containers). Added 2GB swap file to stabilize:

```bash

sudo fallocate -l 2G /swapfile

sudo chmod 600 /swapfile

sudo mkswap /swapfile

sudo swapon /swapfile

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

```



\## 5. EC2 Stop/Start Test

```powershell

aws ec2 stop-instances --instance-ids i-0156f39b5d83f1497

aws ec2 start-instances --instance-ids i-0156f39b5d83f1497

```

Public IP changed after restart (3.239.41.205). Verified:

\- `sudo systemctl is-enabled docker` → enabled (Docker auto-starts on boot)

\- `docker ps` after boot showed all 4 containers (db, redis, server, worker) automatically running without any manual `docker compose up`

\- Server took \~4 minutes to become healthy (slow boot on t3.small)



\## 6. Verification

\- `curl -I http://localhost:3000` → HTTP/1.1 200 OK

\- Application accessible in browser at http://<EC2\_PUBLIC\_IP>:3000



\## 7. Logs (final successful startup)

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] hidden columns on ObjectMetadataEntity: standardOverrides,isCustom

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] hidden columns on FieldMetadataEntity: standardOverrides,isCustom

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] hidden columns on TimelineActivityTypeEntity: renderer

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] applied cursor=339 renamed=0 unavailable=0 hiddenColumns=6

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] hidden columns on RolePermissionFlagEntity: flag

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] hidden columns on ObjectMetadataEntity: standardOverrides,isCustom

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] hidden columns on FieldMetadataEntity: standardOverrides,isCustom

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] hidden columns on TimelineActivityTypeEntity: renderer

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[UpgradeAwareEntityMetadataAdapter] \[upgrade-metadata] applied cursor=335 renamed=0 unavailable=0 hiddenColumns=6

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[DatabaseConfigDriver] \[INIT] Loading initial config variables from database

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[DatabaseConfigDriver] \[INIT] Config variables loaded: 0 values found in DB, 127 falling to env vars/defaults

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[GraphQLModule] Mapped {/metadata, POST} route

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[GraphQLModule] Mapped {/admin-panel, POST} route

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[GraphQLModule] Mapped {/graphql, POST} route

\[Nest] 1  - 09/16/2026, 8:52:14 AM     LOG \[NestApplication] Nest application successfully started



\## Conclusion

Twenty CRM successfully recovers from both container-level failure (manual kill) and infrastructure-level failure (EC2 stop/start) without manual intervention, using Docker's restart policy and systemd's Docker auto-start on boot.


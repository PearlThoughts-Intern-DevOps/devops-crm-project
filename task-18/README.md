\# Task 18 - Deploy Twenty CRM on Local Kubernetes



Deploy Twenty CRM (with Postgres and Redis) on a local Kubernetes cluster using YAML manifests.



\---



\## 1. Objective



\- Set up Kubernetes locally (Docker Desktop Kubernetes)

\- Create YAML manifests for Twenty CRM, Postgres, and Redis

\- Deploy with `kubectl apply`

\- Verify the pod is running

\- Access the app through a Kubernetes Service

\- Scale the Deployment to 2 replicas and back to 1

\- Clean up all resources



\---



\## 2. Kubernetes Setup



\*\*Local cluster:\*\* Docker Desktop Kubernetes (kind-based)

\*\*Kubernetes version:\*\* v1.36.1

\*\*Nodes:\*\* 1 (desktop-control-plane)



```bash

$ kubectl get nodes

NAME                    STATUS   ROLES           AGE   VERSION

desktop-control-plane   Ready    control-plane   Xm    v1.36.1

```



\---



\## 3. Project Structure



```

task-18/

├── namespace.yaml               # Namespace: twenty-crm

├── postgres-pvc.yaml            # 5 Gi persistent volume for Postgres

├── postgres-deployment.yaml     # Postgres 16 Deployment

├── postgres-service.yaml        # ClusterIP Service for Postgres

├── redis-deployment.yaml        # Redis 7 Deployment

├── redis-service.yaml           # ClusterIP Service for Redis

├── twenty-deployment.yaml       # Twenty CRM Deployment (with probes)

├── twenty-service.yaml          # NodePort Service for Twenty CRM

└── README.md

```



\---



\## 4. Manifests Explained



\### Namespace

Isolates all Task 18 resources in their own namespace `twenty-crm`.



\### Postgres

\- \*\*Deployment\*\*: `postgres:16` with `POSTGRES\_USER/PASSWORD/DB` env vars

\- \*\*PVC\*\*: 5 Gi persistent volume mounted at `/var/lib/postgresql/data`

\- \*\*Service\*\*: ClusterIP on port 5432 (internal only)



\### Redis

\- \*\*Deployment\*\*: `redis:7`

\- \*\*Service\*\*: ClusterIP on port 6379 (internal only)



\### Twenty CRM

\- \*\*Deployment\*\*: `twentycrm/twenty:latest` on port 3000

\- \*\*Env vars\*\*: `NODE\_PORT`, `SERVER\_URL`, `PG\_DATABASE\_URL`, `REDIS\_URL`, `APP\_SECRET`, `IS\_BILLING\_ENABLED`, `SIGN\_IN\_PREFILLED`

\- \*\*Readiness probe\*\*: HTTP GET `/` on port 3000 after 180s

\- \*\*Liveness probe\*\*: HTTP GET `/` on port 3000 after 600s (10 min grace for migrations)

\- \*\*Service\*\*: NodePort exposing port 2020 → container port 3000



\*\*Note on probe timings\*\*: Twenty CRM runs database migrations on first boot — this can take 3–5 minutes. The liveness probe is set to `initialDelaySeconds: 600` so Kubernetes doesn't kill the container mid-migration.



\---



\## 5. Deployment



```bash

kubectl apply -f .

```



Output:

```

namespace/twenty-crm created

deployment.apps/postgres created

persistentvolumeclaim/postgres-pvc created

service/postgres created

deployment.apps/redis created

service/redis created

deployment.apps/twenty-crm created

service/twenty-crm created

```



\---



\## 6. Verification



\### Pods running



```bash

$ kubectl get pods -n twenty-crm

NAME                          READY   STATUS    RESTARTS   AGE

postgres-555c9f6fd4-bzhgz     1/1     Running   0          22m

redis-56c9d5db58-zbxnm        1/1     Running   0          22m

twenty-crm-79b4db4c89-kvdgg   1/1     Running   0          13m

```



\### Services



```bash

$ kubectl get svc -n twenty-crm

NAME         TYPE        CLUSTER-IP       PORT(S)          AGE

postgres     ClusterIP   10.96.x.x        5432/TCP         Xm

redis        ClusterIP   10.96.x.x        6379/TCP         Xm

twenty-crm   NodePort    10.96.x.x        2020:30xxx/TCP   Xm

```



\### Access through Service



```bash

kubectl port-forward -n twenty-crm service/twenty-crm 2020:2020

```



Then open `http://localhost:2020` — the Twenty CRM dashboard loads.



\---



\## 7. Scaling



\### Scale to 2 replicas



```bash

$ kubectl scale deployment twenty-crm -n twenty-crm --replicas=2

deployment.apps/twenty-crm scaled



$ kubectl get pods -n twenty-crm

NAME                          READY   STATUS    RESTARTS   AGE

postgres-555c9f6fd4-bzhgz     1/1     Running   0          33m

redis-56c9d5db58-zbxnm        1/1     Running   0          33m

twenty-crm-79b4db4c89-kvdgg   1/1     Running   0          24m

twenty-crm-79b4db4c89-z9glx   1/1     Running   0          4m2s

```



\*\*Both Twenty CRM pods running.\*\*



\### Scale back to 1



```bash

$ kubectl scale deployment twenty-crm -n twenty-crm --replicas=1

deployment.apps/twenty-crm scaled



$ kubectl get pods -n twenty-crm

NAME                          READY   STATUS    RESTARTS   AGE

postgres-555c9f6fd4-bzhgz     1/1     Running   0          35m

redis-56c9d5db58-zbxnm        1/1     Running   0          35m

twenty-crm-79b4db4c89-kvdgg   1/1     Running   0          26m

```



\---



\## 8. Cleanup



```bash

kubectl delete namespace twenty-crm

```



Verify:

```bash

$ kubectl get all -n twenty-crm

No resources found

```



\---



\## 9. Issues Encountered and Resolutions



| # | Issue | Root Cause | Fix |

|---|---|---|---|

| 1 | Twenty CRM pod `CrashLoopBackOff` with exit code 2 | Liveness probe killed container at 120s while DB migrations were still running | Set `livenessProbe.initialDelaySeconds: 600` (10 min) |

| 2 | Migration failed with `connection to server at "postgres" ... refused` | Pod started before Postgres was ready | Re-applied; second attempt succeeded. Would fix with init container in production |

| 3 | Missing `SERVER\_URL` env var | Not included in original Deployment YAML | Added `SERVER\_URL: "http://localhost:2020"` |

| 4 | Second replica stuck unready briefly | First boot migrations | Waited \~4 min; became `1/1 Running` |



\---



\## 10. Notes



\- \*\*Storage:\*\* Postgres data persists in a 5 Gi PVC backed by Docker Desktop's local storage.

\- \*\*No LoadBalancer:\*\* Local Docker Desktop K8s doesn't support `LoadBalancer` type out of the box. Used `NodePort` + `port-forward` for access.

\- \*\*Multi-replica caveat:\*\* Twenty CRM is designed to run as a single server instance per database. Scaling to 2 replicas works at the K8s level (both pods schedule and run), but production would require a shared session/cache backend or a single-writer pattern.

\- \*\*Probe timings matter:\*\* For slow-starting apps (like Twenty CRM with migrations), the liveness probe must allow enough boot time. Setting it too aggressive causes restart loops.



\---




# Task 18: Deploy Twenty CRM on Kubernetes

## Overview

This task demonstrates deploying the **Twenty CRM** application on a local Kubernetes cluster using Minikube. It covers the full lifecycle — deployment, service exposure, scaling, and cleanup.

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Minikube | Local Kubernetes cluster |
| kubectl | Kubernetes CLI |
| Docker | Container runtime |
| Twenty CRM | Application (`twentycrm/twenty:latest`) |
| PostgreSQL 15 | Database |
| Redis 7 | Cache / Queue |

---

## Project Structure

```
k8s/
├── deployment.yml    # Deployments for Twenty CRM, PostgreSQL, Redis
└── service.yml       # Services to expose pods internally and externally
```

---

## Prerequisites

- Docker installed and running
- Minikube installed
- kubectl installed

### Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

### Install Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

---

## Setup & Deployment

### 1. Start Minikube

```bash
minikube start --driver=docker
kubectl get nodes
```

Expected output:
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.37.0
```

### 2. Deploy All Resources

```bash
kubectl apply -f k8s/
```

Expected output:
```
deployment.apps/postgres created
deployment.apps/redis created
deployment.apps/twenty-crm created
service/postgres-service created
service/redis-service created
service/twenty-crm-service created
```

### 3. Verify Pods are Running

```bash
kubectl get pods
```

Expected output:
```
NAME                          READY   STATUS    RESTARTS   AGE
postgres-6d58b7465c-nrjfp     1/1     Running   0          21s
redis-97d794f54-pmhzs         1/1     Running   0          21s
twenty-crm-7b4b4f4766-lc7rf   1/1     Running   0          21s
```

### 4. Verify Services

```bash
kubectl get svc
```

Expected output:
```
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes           ClusterIP   10.96.0.1        <none>        443/TCP        45m
postgres-service     ClusterIP   10.101.45.154    <none>        5432/TCP       4m
redis-service        ClusterIP   10.102.199.241   <none>        6379/TCP       4m
twenty-crm-service   NodePort    10.98.38.199     <none>        80:30080/TCP   4m
```

---

## Accessing the Application

```bash
minikube service twenty-crm-service
```

This opens a tunnel and provides a URL like `http://127.0.0.1:<port>`.

**Keep the terminal open** while accessing the app.

### Verify via curl

```bash
curl http://192.168.49.2:30080/healthz
```

Expected output:
```json
{"status":"ok","info":{},"error":{},"details":{}}
```

---

## Scaling

### Scale Up to 2 Replicas

```bash
kubectl scale deployment twenty-crm --replicas=2
kubectl get pods
```

Expected output:
```
NAME                          READY   STATUS    RESTARTS   AGE
postgres-6d58b7465c-nrjfp     1/1     Running   0          5m
redis-97d794f54-pmhzs         1/1     Running   0          5m
twenty-crm-7b4b4f4766-56ptx   1/1     Running   0          20s
twenty-crm-7b4b4f4766-lc7rf   1/1     Running   0          5m
```

### Scale Back to 1 Replica

```bash
kubectl scale deployment twenty-crm --replicas=1
kubectl get pods
```

Expected output:
```
NAME                          READY   STATUS    RESTARTS   AGE
postgres-6d58b7465c-nrjfp     1/1     Running   0          7m
redis-97d794f54-pmhzs         1/1     Running   0          7m
twenty-crm-7b4b4f4766-lc7rf   1/1     Running   0          7m
```

---

## Cleanup

```bash
kubectl delete -f k8s/
kubectl get all
```

Expected output after cleanup:
```
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   49m
```

Only the default Kubernetes service remains — all Twenty CRM resources are deleted.

---

## Kubernetes Files Explained

### `deployment.yml`

Three deployments in a single file:

| Deployment | Image | Purpose |
|---|---|---|
| `postgres` | `postgres:15` | Database for Twenty CRM |
| `redis` | `redis:7` | Cache and queue |
| `twenty-crm` | `twentycrm/twenty:latest` | Main CRM application |

**Key configurations on Twenty CRM deployment:**

- `PG_DATABASE_URL` — connects to PostgreSQL service
- `REDIS_URL` — connects to Redis service
- `NODE_OPTIONS: --max-old-space-size=1024` — increases Node.js heap to prevent OOM during migrations
- Resource limits: `cpu: 1`, `memory: 2Gi`
- Health probes: liveness and readiness on `/healthz`

### `service.yml`

| Service | Type | Port | Purpose |
|---|---|---|---|
| `postgres-service` | ClusterIP | 5432 | Internal DB access |
| `redis-service` | ClusterIP | 6379 | Internal Redis access |
| `twenty-crm-service` | NodePort | 80:30080 | External app access |

---

## Architecture

```
Browser
   |
   | :30080 (NodePort)
   |
twenty-crm-service (NodePort)
   |
twenty-crm pods (port 3000)
   |           |
postgres-    redis-
service      service
   |           |
postgres     redis
pod          pod
```

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `ImagePullBackOff` | Wrong image name | Use `twentycrm/twenty:latest` not `twentyhq/twenty:latest` |
| `CrashLoopBackOff` + no DB | Missing PostgreSQL | Add postgres deployment and service |
| `REDIS_URL not defined` | Missing Redis | Add redis deployment and set `REDIS_URL` env var |
| OOM / heap out of memory | Default Node.js heap too small | Set `NODE_OPTIONS=--max-old-space-size=1024` and increase memory limits |
| Browser can't open URL | Minikube Docker driver limitation | Use `minikube service` tunnel and keep terminal open |

---

## Branch & PR

- Branch: `shubham-singh-18`
- PR raised in: `devops-crm-project`

---

## Author

**Shubham Singh**  
Cloud Support Engineer | DevOps Enthusiast  
MCA 2026 — Garden City University, Bangalore

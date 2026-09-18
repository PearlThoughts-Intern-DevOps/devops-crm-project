# Task 18: Deploy Twenty CRM on Kubernetes

## Objective
Deploy Twenty CRM on a local Kubernetes cluster (Minikube), verify it runs, scale it, and clean up.

## Environment
- OS: Windows 11, PowerShell
- Kubernetes: Minikube (docker driver), 3500MB RAM / 2 CPUs
- Docker Desktop as container runtime for Minikube

## Setup

### 1. Install & start Minikube
```powershell
winget install Kubernetes.minikube
minikube start --driver=docker --memory=3500 --cpus=2
kubectl get nodes
```

### 2. Kubernetes manifests (`task18/k8s/`)
- `namespace.yaml` — dedicated `twenty` namespace
- `secret.yaml` — Postgres credentials, DB URL, app secret
- `postgres.yaml` — Postgres 16 Deployment + Service
- `redis.yaml` — Redis 7 Deployment + Service
- `twenty-deployment.yaml` — Twenty CRM (`twentycrm/twenty:latest`) Deployment
- `twenty-service.yaml` — NodePort Service exposing port 3000

### 3. Deploy
```powershell
kubectl apply -f namespace.yaml
kubectl apply -f secret.yaml
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml
kubectl apply -f twenty-deployment.yaml
kubectl apply -f twenty-service.yaml
```

### 4. Verify pods
```powershell
kubectl get pods -n twenty -w
```
All three pods (`twenty-crm`, `twenty-postgres`, `twenty-redis`) reached `1/1 Running`.

**Issue encountered:** `twenty-crm` crashed once on first boot with `connection to server at "twenty-postgres" ... Connection refused` — Postgres wasn't ready yet when Twenty ran its migration step. Kubernetes auto-restarted the pod (`RESTARTS: 1`), and on retry Postgres was up, migrations succeeded, and the pod stabilized. No manual fix needed — this is expected first-boot race behavior; a `postgres` readiness probe / init-container could avoid the restart in a production setup.

### 5. Access the app
```powershell
minikube service twenty-crm-service -n twenty
```
Exposed via NodePort `31949` and tunneled to `http://127.0.0.1:64664` (Windows docker driver requires a tunnel). App loaded correctly, showing the Twenty CRM workspace signup screen.

*(Screenshot: browser at `localhost:64664/welcome` — "Welcome to your workspace")*

### 6. Scale to 2 replicas
```powershell
kubectl scale deployment twenty-crm -n twenty --replicas=2
kubectl get pods -n twenty
```
Both `twenty-crm` pods reached `1/1 Running`.

### 7. Scale back to 1 replica
```powershell
kubectl scale deployment twenty-crm -n twenty --replicas=1
kubectl get pods -n twenty
```
Confirmed one pod terminated, one remained `Running`.

*(Screenshot: terminal showing scale up → 2 pods running → scale down → 1 pod running)*

### 8. Cleanup
```powershell
kubectl delete namespace twenty
kubectl get pods -n twenty
```
Output: `No resources found in twenty namespace` — all resources (Deployments, Services, Secret, pods) removed.

## Result
- Twenty CRM successfully deployed, accessed, scaled (1→2→1), and cleaned up on local Kubernetes.
- Self-healed one transient DB-connection crash on first boot.

## Files
```
task18/k8s/
├── namespace.yaml
├── secret.yaml
├── postgres.yaml
├── redis.yaml
├── twenty-deployment.yaml
└── twenty-service.yaml
```
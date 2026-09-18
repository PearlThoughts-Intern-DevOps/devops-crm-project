# Task 18: Deploy Twenty CRM on Kubernetes

## Objective
Deploy Twenty CRM on a local Kubernetes cluster using Docker Desktop Kubernetes and the existing Twenty CRM Docker image.

## Kubernetes Environment
- Kubernetes: Docker Desktop Kubernetes
- Kubernetes Version: v1.36.1
- Cluster Node: `desktop-control-plane`
- Twenty CRM Image: `twentycrm/twenty:latest`

## Kubernetes Manifest Structure
```text
k8s/task18/
├── deployments.yaml
├── services.yaml
└── secret.yaml
```

### Deployments
`deployments.yaml` contains:
- PostgreSQL Deployment using `postgres:16`
- Redis Deployment using `redis:7`
- Twenty CRM Deployment using `twentycrm/twenty:latest`

Twenty CRM connects to PostgreSQL and Redis through their Kubernetes Services.

### Services
`services.yaml` contains:
- `twenty-db` - ClusterIP Service on port `5432`
- `twenty-redis` - ClusterIP Service on port `6379`
- `twenty-crm` - NodePort Service on port `3000`

### Secret
`secret.yaml` contains the PostgreSQL password and Twenty CRM application secret used by the Deployments.

## Kubernetes Cluster Setup
Docker Desktop Kubernetes was enabled and verified.

```bash
kubectl get nodes
```

Verified node status:
```text
NAME                    STATUS   ROLES           VERSION
desktop-control-plane   Ready    control-plane   v1.36.1
```

## Manifest Validation
```bash
kubectl apply --dry-run=client   -f k8s/task18/secret.yaml   -f k8s/task18/deployments.yaml   -f k8s/task18/services.yaml
```

All seven resources were successfully recognized during the dry run:
- `twenty-secret`
- `twenty-db` Deployment
- `twenty-db` Service
- `twenty-redis` Deployment
- `twenty-redis` Service
- `twenty-crm` Deployment
- `twenty-crm` Service

## Deployment
The resources were deployed with:
```bash
kubectl apply -f k8s/task18/secret.yaml
kubectl apply -f k8s/task18/deployments.yaml
kubectl apply -f k8s/task18/services.yaml
```

The Twenty CRM Deployment uses:
```yaml
image: twentycrm/twenty:latest
```

PostgreSQL and Redis were deployed as supporting services required by Twenty CRM.

## Pod Verification
```bash
kubectl get pods -o wide
```

Verified successful state:
```text
twenty-crm     1/1   Running
twenty-db      1/1   Running
twenty-redis   1/1   Running
```

## Service Verification
```bash
kubectl get services
```

The Twenty CRM Service was exposed as a NodePort.

Verified NodePort:
```text
twenty-crm   NodePort   3000:30438/TCP
```

## Accessing Twenty CRM
The application was accessed through the Kubernetes Service using:
```bash
kubectl port-forward service/twenty-crm 3020:3000
```

Application URL:
```text
http://localhost:3020
```

Twenty CRM successfully loaded in the browser.

## Scaling Twenty CRM
The Deployment was scaled to two replicas:
```bash
kubectl scale deployment twenty-crm --replicas=2
```

Pods were verified with:
```bash
kubectl get pods -l app=twenty-crm -o wide
```

Both replicas reached `1/1 Running`.

Deployment verification:
```bash
kubectl get deployment twenty-crm
```

Verified result:
```text
NAME         READY   UP-TO-DATE   AVAILABLE
twenty-crm   2/2     2            2
```

## Scaling Back to One Replica
```bash
kubectl scale deployment twenty-crm --replicas=1
```

The Deployment was then verified as:
```text
READY   UP-TO-DATE   AVAILABLE
1/1     1            1
```

## Cleanup
After completing deployment, service access, and scaling verification, the Kubernetes resources were deleted as required:
```bash
kubectl delete -f k8s/task18/secret.yaml
kubectl delete -f k8s/task18/deployments.yaml
kubectl delete -f k8s/task18/services.yaml
```

The default `kubernetes` Service remained because it belongs to the Kubernetes cluster itself.

## Task 18 Requirements Checklist
- [x] Set up Kubernetes locally using Docker Desktop Kubernetes
- [x] Create Kubernetes YAML files
- [x] Create Deployment for Twenty CRM
- [x] Create Service to access Twenty CRM
- [x] Use existing Twenty CRM Docker image
- [x] Deploy using `kubectl`
- [x] Verify Twenty CRM pod running
- [x] Access Twenty CRM through Kubernetes Service
- [x] Scale Deployment to 2 replicas
- [x] Verify both Twenty CRM pods
- [x] Scale Deployment back to 1 replica
- [x] Delete Kubernetes resources after testing
- [x] Create `prabhas-task-18` branch
- [x] Commit Task 18 files
- [x] Push branch to GitHub
- [x] Raise Pull Request

## Project Files
```text
k8s/task18/
├── deployments.yaml
├── services.yaml
└── secret.yaml
```

## Git Information
Branch:
```text
prabhas-task-18
```

Commit:
```text
b6ac15d Task 18 deploy Twenty CRM on Kubernetes
```

Committed files:
```text
k8s/task18/deployments.yaml
k8s/task18/services.yaml
k8s/task18/secret.yaml
```

## Evidence
### Kubernetes Cluster
`kubectl get nodes`

### Running Pods
`kubectl get pods -o wide`

### Kubernetes Services
`kubectl get services`

### Twenty CRM Application
`http://localhost:3020`

### Two-Replica Scaling
`kubectl get deployment twenty-crm`

Verified:
```text
2/2     2     2
```

### Final One-Replica State
Twenty CRM was scaled back to one replica and successfully verified.

### Cleanup
Kubernetes resources were deleted after completing the required verification.

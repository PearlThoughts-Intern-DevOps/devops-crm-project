# Task 18: Twenty CRM on Kubernetes (Local)

Deploys Twenty CRM locally on Docker Desktop Kubernetes using the existing
`twentycrm/twenty-app-dev` image.

## Prerequisites

- Docker Desktop with Kubernetes enabled (Settings → Kubernetes → Enable Kubernetes)
- `twentycrm/twenty-app-dev:latest` image already available locally
- `kubectl` configured with context `docker-desktop`

## Project Structure

```
kubernetes/
├── deployment.yaml     # Deployment for the Twenty CRM app
└── service.yaml        # NodePort Service to access the app

screenshots/
├── pods_running.jpeg
├── scaled_2_replicas.jpeg
├── scaled_back_to_1_replica.jpeg
└── deleted_all_pods_svcs.jpeg

README.md
task18.pdf               # Full task documentation
```

## Setup

1. Create the namespace:
   ```
   kubectl create ns devops-crm
   ```

2. Apply the manifests:
   ```
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   ```

3. Check the pod:
   ```
   kubectl get pods -n devops-crm
   kubectl logs -n devops-crm <pod-name> -f
   ```

4. Access the app:
   ```
   http://localhost:30020
   ```

## Scaling

```
kubectl scale deployment twenty-crm -n devops-crm --replicas=2
kubectl get pods -n devops-crm

kubectl scale deployment twenty-crm -n devops-crm --replicas=1
```

## Cleanup

```
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml
```

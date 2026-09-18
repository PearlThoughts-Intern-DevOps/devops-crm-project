# Twenty CRM on Kubernetes (Task 18)

This directory contains all Kubernetes configuration files, manifests, and documentation for deploying Twenty CRM on a local multi-node Kind cluster.

## Files

| File | Purpose |
| :--- | :--- |
| [`cluster.yml`](file:///home/ubuntu/mohitsingh-pre-internship-repo/kubernetes/cluster.yml) | Kind cluster definition (1 control plane, 2 worker nodes) |
| [`deployment.yml`](file:///home/ubuntu/mohitsingh-pre-internship-repo/kubernetes/deployment.yml) | Deployment manifest for Twenty CRM with health probes and resource limits |
| [`service.yml`](file:///home/ubuntu/mohitsingh-pre-internship-repo/kubernetes/service.yml) | NodePort Service exposing Twenty CRM on port 2020 (NodePort 30020) |
| [`kustomization.yaml`](file:///home/ubuntu/mohitsingh-pre-internship-repo/kubernetes/kustomization.yaml) | Kustomize file bundling `deployment.yml` and `service.yml` |
| [`Task-18.md`](file:///home/ubuntu/mohitsingh-pre-internship-repo/kubernetes/Task-18.md) | Full technical report and verification documentation for Task 18 |

## Quick Start Commands

### 1. Create the Kind Cluster
```bash
kind create cluster --config kubernetes/cluster.yml --name local
```

### 2. Load Local Twenty CRM Image
```bash
kind load docker-image twenty-crm:latest --name local
```

### 3. Deploy Twenty CRM
```bash
kubectl apply -k kubernetes/
# or
kubectl apply -f kubernetes/deployment.yml
kubectl apply -f kubernetes/service.yml
```

### 4. Verify Pod Status
```bash
kubectl get pods -o wide
```

### 5. Access the Service
```bash
# Direct NodePort access:
curl -i http://172.18.0.4:30020/healthz

# Or via port-forwarding:
kubectl port-forward svc/twenty-crm-service 2020:2020
curl -i http://localhost:2020/healthz
```

### 6. Scale the Deployment
```bash
# Scale to 2 replicas
kubectl scale deployment twenty-crm-deployment --replicas=2
kubectl get pods -o wide

# Scale back to 1 replica
kubectl scale deployment twenty-crm-deployment --replicas=1
kubectl get pods -o wide
```

### 7. Clean Up Resources
```bash
kubectl delete -k kubernetes/
# or
kubectl delete -f kubernetes/service.yml
kubectl delete -f kubernetes/deployment.yml
```

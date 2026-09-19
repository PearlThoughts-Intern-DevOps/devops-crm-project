# Task 18 — Deploy Twenty CRM on Kubernetes

## 1. Objective

Deploy the existing Twenty CRM Docker image on a local Kubernetes cluster using Kubernetes Deployment and Service resources, verify application access, demonstrate scaling, and document the complete process.

## 2. Prerequisites

- Docker
- Docker Desktop Kubernetes
- `kubectl`
- Existing Twenty CRM Docker image
- Git

## 3. Kubernetes Setup

The application was deployed using Kubernetes provided by Docker Desktop.

Check the Kubernetes cluster:

```bash
kubectl get nodes
```

Expected output:

```text
NAME                    STATUS   ROLES           AGE
desktop-control-plane   Ready    control-plane   ...
```

### Deployment

The Twenty CRM application is deployed using a Kubernetes Deployment with the existing Twenty CRM Docker image.

The application listens on container port `2020`.

### Service

A Kubernetes Service exposes the Twenty CRM application on port `2020`.

## 5. Deploy Twenty CRM

Apply the Kubernetes Deployment:

```bash
kubectl apply -f k8s/deployment.yaml
```

Apply the Kubernetes Service:

```bash
kubectl apply -f k8s/service.yaml
```

Verify the deployed resources:

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

## 6. Verify Twenty CRM Pod

Check the Twenty CRM pod:

```bash
kubectl get pods -l app=twenty-crm
```

The pod should be in the `Running` state:

```text
READY   STATUS
1/1     Running
```

## 7. Access Twenty CRM

The application was accessed through the Kubernetes Service using port forwarding:

```bash
kubectl port-forward service/twenty-crm 8061:2020
```

The application can then be accessed at:

```text
http://localhost:8061
```

Twenty CRM was successfully accessed through the Kubernetes Service.

## 8. Scale Deployment to 2 Replicas

Scale the Twenty CRM Deployment to two replicas:

```bash
kubectl scale deployment twenty-crm --replicas=2
```

Verify that both pods are running:

```bash
kubectl get pods -l app=twenty-crm
```

Expected result:

```text
twenty-crm-xxxxx   1/1   Running
twenty-crm-yyyyy   1/1   Running
```

Both Twenty CRM replicas should be in the `Running` state.

## 9. Scale Deployment Back to 1 Replica

Scale the Deployment back to one replica:

```bash
kubectl scale deployment twenty-crm --replicas=1
```

Verify:

```bash
kubectl get pods -l app=twenty-crm
```

Only one Twenty CRM pod should remain in the `Running` state.

## 10. Cleanup

After completing the task, delete the Kubernetes resources:

```bash
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
```

Verify that the resources have been removed:
```bash
kubectl get pods
kubectl get services
kubectl get deployments
```

### Thank you!

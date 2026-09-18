# Task 18: Deploy Twenty CRM on Kubernetes

## Overview

Deployed Twenty CRM locally on Kubernetes using Docker Desktop Kubernetes.

## Kubernetes Setup

- Platform: Docker Desktop Kubernetes
- Cluster type: Kubeadm
- Node count: 1
- Kubernetes version: v1.36.1
- Node name: docker-desktop
- Node status: Ready

## Kubernetes Resources

Created Kubernetes resources for the Twenty CRM stack:

- Secret for application configuration
- PostgreSQL Service and Deployment
- Redis Service and Deployment
- Twenty CRM Deployment
- Twenty CRM NodePort Service

## Twenty CRM Deployment

- Image: `twentycrm/twenty:latest`
- Initial replicas: 1
- Container port: 3000
- Service type: NodePort
- NodePort: 30080

The application was accessed through:

`http://localhost:30080`

The Twenty CRM welcome page was successfully opened in the browser through the Kubernetes Service.

## Deployment and Verification

The Kubernetes manifest was first validated using:

```bash
kubectl apply --dry-run=client -f kubernetes/twenty-crm.yaml
```

The manifest was then deployed using:

```bash
kubectl apply -f kubernetes/twenty-crm.yaml
```

PostgreSQL and Redis were verified as running, and the Twenty CRM Pod reached `1/1 Running`.

The Kubernetes Service was verified using:

```bash
kubectl get svc
```

The Twenty CRM Service was exposed as a NodePort on port `30080`.

## Scaling

The Twenty CRM Deployment was scaled from 1 replica to 2 replicas using:

```bash
kubectl scale deployment twenty-crm --replicas=2
```

The rollout completed successfully, and both Twenty CRM Pods reached `1/1 Running`.

The Deployment was then scaled back to 1 replica using:

```bash
kubectl scale deployment twenty-crm --replicas=1
```

The remaining Twenty CRM Pod was verified as `1/1 Running`.

## Issues Encountered and Recovery

During the initial deployment, the Twenty CRM container restarted multiple times because PostgreSQL was not ready to accept connections when Twenty CRM first attempted database setup and migrations.

The previous container logs showed:

`connection to server at "twenty-db" ... port 5432 failed: Connection refused`

Kubernetes automatically restarted the failed Twenty CRM container. Once PostgreSQL became ready, Twenty CRM completed its startup process and the Pod reached `1/1 Running`.

## Cleanup

After completing deployment, scaling, and verification, all Task 18 application resources were deleted using:

```bash
kubectl delete -f kubernetes/twenty-crm.yaml
```

Cleanup was verified using:

```bash
kubectl get pods
kubectl get deployments
kubectl get svc
```

No application Pods or Deployments remained in the default namespace after cleanup.

## Evidence

Four screenshots were captured as evidence:

1. Twenty CRM running in the browser through the Kubernetes Service.
2. Two Twenty CRM replicas running successfully after scaling to 2.
3. Twenty CRM scaled back to one replica.
4. Kubernetes resources deleted and cleanup verified.


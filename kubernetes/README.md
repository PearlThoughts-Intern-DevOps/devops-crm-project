# Task 18 – Deploy Twenty CRM on Kubernetes

## Overview

In this task, Twenty CRM was deployed locally on Kubernetes using Minikube.

## Technologies Used

* Kubernetes
* Minikube
* kubectl
* Docker
* Twenty CRM

## Implementation

### 1. Kubernetes Setup

Minikube was used as the local Kubernetes environment.

### 2. Kubernetes Manifests

Two Kubernetes YAML files were created:

* `deployment.yaml` – Defines the Twenty CRM Deployment.
* `service.yaml` – Creates a NodePort Service to expose Twenty CRM.

### 3. Twenty CRM Deployment

The existing Twenty CRM Docker image was used:

`twentycrm/twenty-app-dev:v2.35.0`

The application runs on container port `2020`.

### 4. Kubernetes Service

A NodePort Service named `twenty-crm-service` was created to provide access to the application.

### 5. Verification

The deployment was verified using Kubernetes commands:

```bash
kubectl get pods
kubectl get services
kubectl get endpoints twenty-crm-service
```

The Twenty CRM pod reached the `Running` state and the application was successfully accessed through the Kubernetes Service.

### 6. Scaling

The Deployment was manually scaled:

```text
1 replica → 2 replicas → 1 replica
```

Both replicas were verified as running during the scaling test.

### 7. Cleanup

After completing the task, the Kubernetes Deployment and Service were deleted.

## Evidence

Task 18 screenshots are available in:

`screenshots/task18/`

The screenshots demonstrate:

* Twenty CRM running in the browser
* Kubernetes Service and endpoint
* Manual scaling and cleanup

## Git Branch

`vasundhara-task18`

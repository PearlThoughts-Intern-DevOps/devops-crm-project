# Task 18: Deploy Twenty CRM on Kubernetes

## Objective

Deploy the Twenty CRM application locally on Kubernetes using Minikube and Docker.

## Kubernetes Setup

* Kubernetes platform: Minikube
* Container runtime: Docker
* Kubernetes version: v1.37.0
* kubectl version: v1.36.3
* Minikube version: v1.39.0
* Minikube driver: Docker

## Application Details

* Application: Twenty CRM
* Docker image: `twentycrm/twenty:v2.35.0`
* Application port: `3000`

## Kubernetes Resources

The following Kubernetes resources were created:

* Twenty CRM Deployment
* Twenty CRM NodePort Service
* PostgreSQL Deployment and Service
* Redis Deployment and Service

## Deployment Configuration

Twenty CRM was configured with:

* PostgreSQL database connection
* Redis connection
* Encryption key
* Readiness probe
* Liveness probe

The initial Twenty CRM Deployment was configured with 1 replica.

## Deployment

The Kubernetes manifests were applied using `kubectl`.

Twenty CRM, PostgreSQL, and Redis pods were verified and reached the `Running` and `Ready` state.

## Service Access

Twenty CRM was exposed using a Kubernetes NodePort Service.

The application was accessed through the Minikube service URL and successfully opened in Chrome.

## Scaling

The Twenty CRM Deployment was initially configured with 1 replica.

It was then scaled to 2 replicas and both Twenty CRM pods were verified as running and ready.

The Deployment was subsequently scaled back to 1 replica.

Final Deployment state:

```text
READY: 1/1
UP-TO-DATE: 1
AVAILABLE: 1
```

## Cleanup

After completing the deployment, service access, and scaling verification, all Task 18 Kubernetes resources were deleted.

The default namespace was verified to contain no remaining Task 18 pods or deployments.

## Result

Twenty CRM was successfully deployed on a local Minikube Kubernetes cluster, accessed through a Kubernetes Service, scaled to 2 replicas, scaled back to 1 replica, and cleaned up after verification.


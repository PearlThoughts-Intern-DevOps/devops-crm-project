# Task 18: Deploy Twenty CRM on Kubernetes

**Name:** Mujtaba Shaikh
**Date:** 18 September 2026

## Summary of Work

* Set up a local Kubernetes cluster using Minikube.
* Created Kubernetes YAML files for Namespace, PostgreSQL, Redis, Twenty CRM Deployment, and Service.
* Deployed Twenty CRM using the existing `twentycrm/twenty:latest` Docker image.
* Configured PostgreSQL and Redis as supporting services.
* Exposed Twenty CRM using a Kubernetes LoadBalancer Service on port `2020`.
* Used `minikube tunnel` to access the application locally without port forwarding.
* Verified the Twenty CRM application using `curl` with HTTP `200 OK`.
* Scaled the Twenty CRM Deployment from 1 replica to 2 replicas.
* Verified both Twenty CRM pods were running.
* Scaled the Deployment back to 1 replica.
* Verified the final Kubernetes resources.
* Kubernetes resources were deleted after completing the task.

## Kubernetes Files

* `namespace.yml`
* `postgres.yml`
* `redis.yml`
* `deployment.yml`
* `service.yml`

## Verification

Twenty CRM was successfully accessed through the Kubernetes Service at:

`http://10.111.240.176:2020`

The application returned:

`HTTP/1.1 200 OK`

## Git

**Branch:** `Mujtaba-Task-18-PT`

**Task:** Deploy Twenty CRM on Kubernetes locally.


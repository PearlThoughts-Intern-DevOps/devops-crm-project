# Task 18 – Deploy Twenty CRM on Kubernetes

**Name:** P. Harish
**Date:** 18 September 2026
**PR link:** [https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project/pull/438]
**Loom link:** [https://drive.google.com/file/d/1KCBr1trFyr7qT-9GyIG4Tn7r1rvApfVd/view?usp=drive_link]

## Objective

* Deploy Twenty CRM on a local Kubernetes cluster using Kind.
* Create Kubernetes resources for Twenty CRM, PostgreSQL, and Redis.
* Expose Twenty CRM through a Kubernetes Service.
* Scale the CRM application and verify multiple replicas.

## 1. Kubernetes Setup Using Kind

Kind was used to create the local Kubernetes cluster.

Check Kind Version

```bash
kind version
```

Create Kind Cluster

```bash
kind create cluster --name twenty-crm
```

Verify Kind Cluster

```bash
kind get clusters
```

Expected:

```text
twenty-crm
```

Check Kubernetes Nodes

```bash
kubectl get nodes
```

The Kind control-plane node should show:

```text
STATUS   Ready
```

Check Kubernetes Cluster Information

```bash
kubectl cluster-info
```

Check Current Context

```bash
kubectl config current-context
```

Expected:

```text
kind-twenty-crm
```

## 2. Create Kubernetes Directory

From the project repository:

```bash
cd ~/devops-crm-project
```

Create the Kubernetes directory:

```bash
mkdir -p k8s
```

Kubernetes files created:

```text
k8s/
├── deployment.yaml
├── services.yaml
└── secret.yaml
```

## 3. Kubernetes Secret

The Secret stores the application secret and PostgreSQL password.

```bash
kubectl apply -f k8s/secret.yaml
```

Verify:

```bash
kubectl get secrets
```

## 4. Kubernetes Deployments

Three Deployments were created:

* `twenty-db`
* `twenty-redis`
* `twenty-crm`

PostgreSQL

Image:

```text
postgres:16
```

Port:

```text
5432
```

Database:

```text
twenty
```

Redis

Image:

```text
redis:7
```

Port:

```text
6379
```

Twenty CRM

Existing image:

```text
twentycrm/twenty:latest
```

Port:

```text
3000
```

## 5. Validate Kubernetes YAML

Before applying the Deployment:

```bash
kubectl apply --dry-run=client -f k8s/deployment.yaml
```

Apply the Deployment:

```bash
kubectl apply -f k8s/deployment.yaml
```

Apply the Services:

```bash
kubectl apply -f k8s/services.yaml
```

Or apply all Kubernetes files together:

```bash
kubectl apply -f k8s/
```

## 6. Verify Pods

```bash
kubectl get pods
```

Detailed pod information:

```bash
kubectl get pods -o wide
```

Check the Twenty CRM logs:

```bash
kubectl logs deployment/twenty-crm
```

Check PostgreSQL logs:

```bash
kubectl logs deployment/twenty-db
```

Check Redis logs:

```bash
kubectl logs deployment/twenty-redis
```

Expected application state:

```text
twenty-crm     1/1 Running
twenty-db      1/1 Running
twenty-redis   1/1 Running
```

## 7. Verify Services

```bash
kubectl get services
```

Expected Services:

```text
twenty-crm
twenty-db
twenty-redis
```

The CRM Service uses:

```text
NodePort: 30000
```

PostgreSQL and Redis use:

```text
ClusterIP
```

because they only need to be accessed inside the Kubernetes cluster.

## 8. Access Twenty CRM

Because the cluster is running with Kind, port forwarding was used to access the application locally.

```bash
kubectl port-forward service/twenty-crm 3000:3000
```

Open:

```text
http://localhost:3000
```

The Twenty CRM application was successfully accessed through the Kubernetes Service.

## 9. Scale Twenty CRM

Scale the CRM Deployment from 1 replica to 2:

```bash
kubectl scale deployment twenty-crm --replicas=2
```

Verify:

```bash
kubectl get pods
```

Two Twenty CRM pods should be running.

Check the Deployment:

```bash
kubectl get deployment twenty-crm
```

Expected:

```text
READY   2/2
```

## 10. Scale Back to One Replica

```bash
kubectl scale deployment twenty-crm --replicas=1
```

Verify:

```bash
kubectl get pods
```

Only one Twenty CRM pod should remain running.

## 11. Kubernetes Architecture

```text
                         Browser
                            |
                            v
                   twenty-crm Service
                     NodePort :30000
                            |
                   +--------+--------+
                   |                 |
                   v                 v
             Twenty CRM Pod     Twenty CRM Pod
                   |                 |
                   +--------+--------+
                            |
                  +---------+---------+
                  |                   |
                  v                   v
          twenty-db Service    twenty-redis Service
                  |                   |
                  v                   v
           PostgreSQL Pod          Redis Pod
```

When the CRM was scaled to two replicas, both CRM application pods connected to the same PostgreSQL and Redis Services.

## 12. Useful Kubernetes Commands

Check all resources:

```bash
kubectl get all
```

Check Deployments:

```bash
kubectl get deployments
```

Check Services:

```bash
kubectl get services
```

Check Pods:

```bash
kubectl get pods
```

Describe a pod:

```bash
kubectl describe pod <pod-name>
```

Check pod logs:

```bash
kubectl logs <pod-name>
```

Watch pod status:

```bash
kubectl get pods -w
```

## 13. Cleanup

Delete all Task 18 Kubernetes resources:

```bash
kubectl delete -f k8s/
```

Verify:

```bash
kubectl get pods
kubectl get services
kubectl get deployments
```

Delete the Kind cluster after completing the task:

```bash
kind delete cluster --name twenty-crm
```

Verify the cluster was deleted:

```bash
kind get clusters
```

## 14. Task Status

* Installed and used Kind
* Created `twenty-crm` Kind cluster
* Verified Kubernetes node
* Created Kubernetes YAML files
* Created PostgreSQL Deployment
* Created Redis Deployment
* Created Twenty CRM Deployment
* Used existing `twentycrm/twenty:latest` image
* Created PostgreSQL ClusterIP Service
* Created Redis ClusterIP Service
* Created Twenty CRM NodePort Service
* Verified all pods
* Accessed Twenty CRM through Kubernetes Service
* Scaled Twenty CRM to 2 replicas
* Verified both replicas
* Scaled back to 1 replica
* Cleaned up Kubernetes resources
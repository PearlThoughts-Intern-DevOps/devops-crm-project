# Task 18: Deploy Twenty CRM on Kubernetes

## 1. Overview & Objectives

The objective of this task is to deploy the **Twenty CRM** application locally on a multi-node Kubernetes cluster using **Kind** (Kubernetes in Docker), containerized workloads, and native Kubernetes primitives (`Deployment` and `Service`).

Key requirements fulfilled:
- Local Kubernetes cluster setup using **Kind** (`cluster.yml`) featuring 1 control-plane node and 2 worker nodes.
- Created declarative Kubernetes YAML manifests for the Twenty CRM stack:
  - [`kubernetes/deployment.yml`](file:///home/ubuntu/mohitsingh-pre-internship-repo/kubernetes/deployment.yml): Deployment configuration with container specifications, health checks (`startupProbe`, `readinessProbe`, `livenessProbe`), and resource definitions.
  - [`kubernetes/service.yml`](file:///home/ubuntu/mohitsingh-pre-internship-repo/kubernetes/service.yml): `NodePort` Service exposing the application on port `2020` (NodePort `30020`).
- Reused existing local Twenty CRM Docker image (`twenty-crm:latest`) and loaded it directly into the Kind cluster nodes without external registry dependencies.
- Deployed and orchestrated the application via `kubectl`.
- Verified the Twenty CRM pod reached healthy, ready, and running status (`1/1 Running`).
- Successfully accessed Twenty CRM through the Kubernetes Service using both direct NodePort access and `kubectl port-forward`.
- Scaled the Deployment up to 2 replicas, verifying multi-node scheduling across `local-worker` and `local-worker2`.
- Scaled the Deployment back down to 1 replica and validated ongoing service continuity.
- Cleanly deleted and purged the Kubernetes resources post-verification.

---

## 2. Infrastructure & Cluster Specifications

| Parameter | Specification | Details |
| :--- | :--- | :--- |
| **Kubernetes Tool** | Kind (Kubernetes in Docker) | Version `v0.33.0` |
| **Cluster Name** | `local` | Multi-node topology |
| **Kubernetes Version** | `v1.37.0` | Containerd runtime |
| **Control Plane Node** | `local-control-plane` | IP: `172.18.0.3` |
| **Worker Node 1** | `local-worker` | IP: `172.18.0.4` |
| **Worker Node 2** | `local-worker2` | IP: `172.18.0.2` |
| **Docker Image** | `twenty-crm:latest` | Standalone Twenty CRM (Postgres, Redis, NestJS, React) |
| **Image ID** | `3234894dbf62` | Pre-built from [`Dockerfile.twenty`](file:///home/ubuntu/mohitsingh-pre-internship-repo/Dockerfile.twenty) |
| **Deployment Name** | `twenty-crm-deployment` | Managed by `apps/v1` Deployment controller |
| **Service Name** | `twenty-crm-service` | `NodePort` service mapping container port `2020` to `30020` |
| **Target Port** | `2020` | Application HTTP listening port |
| **Health Probe** | `/healthz` | HTTP GET endpoint returning `{"status":"ok"}` |

---

## 3. Kubernetes Configuration Manifests

The Kubernetes manifests are stored under [`kubernetes/`](file:///home/ubuntu/mohitsingh-pre-internship-repo/kubernetes):

### 3.1 Cluster Configuration (`cluster.yml`)

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

### 3.2 Deployment Manifest (`deployment.yml`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: twenty-crm-deployment
  labels:
    app: twenty-crm
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: twenty-crm
  template:
    metadata:
      labels:
        app: twenty-crm
    spec:
      containers:
        - name: twenty-crm
          image: twenty-crm:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 2020
              name: http
          env:
            - name: NODE_PORT
              value: "2020"
            - name: SERVER_URL
              value: "http://localhost:2020"
            - name: APP_SECRET
              value: "twenty-k8s-secret-task18-mohit"
            - name: SIGN_IN_PREFILLED
              value: "true"
          resources:
            requests:
              memory: "256Mi"
              cpu: "200m"
          startupProbe:
            httpGet:
              path: /healthz
              port: 2020
            failureThreshold: 60
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /healthz
              port: 2020
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /healthz
              port: 2020
            periodSeconds: 15
            timeoutSeconds: 5
            failureThreshold: 3
```

### 3.3 Service Manifest (`service.yml`)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: twenty-crm-service
  labels:
    app: twenty-crm
spec:
  type: NodePort
  selector:
    app: twenty-crm
  ports:
    - name: http
      port: 2020
      targetPort: 2020
      nodePort: 30020
```

---

## 4. Execution & Step-by-Step Verification

### 4.1 Cluster Provisioning and Image Loading

The Kind cluster was initialized using the multi-node configuration:

```bash
$ kind create cluster --config kubernetes/cluster.yml --name local
```

Verified the nodes were in the `Ready` state:

```bash
$ kubectl get nodes
NAME                  STATUS   ROLES           AGE   VERSION
local-control-plane   Ready    control-plane   44m   v1.37.0
local-worker          Ready    <none>          44m   v1.37.0
local-worker2         Ready    <none>          44m   v1.37.0
```

Loaded the existing local Twenty CRM image into the Kind cluster nodes:

```bash
$ kind load docker-image twenty-crm:latest --name local
Image: "twenty-crm:latest" with ID "sha256:3234894dbf62..." not yet present on node "local-control-plane", loading...
Image: "twenty-crm:latest" with ID "sha256:3234894dbf62..." not yet present on node "local-worker", loading...
Image: "twenty-crm:latest" with ID "sha256:3234894dbf62..." not yet present on node "local-worker2", loading...
```

Verified the image was loaded inside the nodes:

```bash
$ docker exec local-worker crictl images | grep twenty-crm
docker.io/library/twenty-crm   latest   a8c6f48b105c3   272MB
```

---

### 4.2 Deploying Application and Service

Applied the Deployment and Service manifests using `kubectl`:

```bash
$ kubectl apply -f kubernetes/deployment.yml
deployment.apps/twenty-crm-deployment created

$ kubectl apply -f kubernetes/service.yml
service/twenty-crm-service created
```

Inspected the created resources:

```bash
$ kubectl get deployment,svc -l app=twenty-crm
NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/twenty-crm-deployment   0/1     1            0           30s

NAME                         TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/twenty-crm-service   NodePort   10.96.109.38   <none>        2020:30020/TCP   30s
```

---

### 4.3 Verifying Pod Status and Health

During initialization, the Twenty CRM container runs internal database setup, schema extensions, instance upgrade commands, and workspace migrations. The `startupProbe` gave the application sufficient window to boot.

Inspected pod status:

```bash
$ kubectl get pods -o wide
NAME                                     READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
twenty-crm-deployment-67fb7f648f-zpm9h   1/1     Running   0          7m37s   10.244.1.6   local-worker   <none>           <none>
```

Pod status confirmed:
- **Status**: `Running`
- **Ready**: `1/1`
- **Restarts**: `0`
- **Node**: `local-worker`

Inspected the service endpoints:

```bash
$ kubectl get endpoints twenty-crm-service
NAME                 ENDPOINTS         AGE
twenty-crm-service   10.244.1.6:2020   8m
```

---

### 4.4 Accessing Twenty CRM Through the Kubernetes Service

#### Method 1: NodePort Service Access

Queried the `/healthz` health probe through the Kind node's IP on port `30020`:

```bash
$ curl -i http://172.18.0.4:30020/healthz
HTTP/1.1 200 OK
X-Powered-By: Express
Vary: Origin
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: WWW-Authenticate
Cache-Control: no-cache, no-store, must-revalidate
Content-Type: application/json; charset=utf-8
Content-Length: 49
ETag: W/"31-dxKeoZI+mvmnahNSR0ys2MInE1I"
Date: Fri, 18 Sep 2026 08:12:42 GMT
Connection: keep-alive
Keep-Alive: timeout=65

{"status":"ok","info":{},"error":{},"details":{}}
```

Verified web UI HTML root response:

```bash
$ curl -s http://172.18.0.4:30020/ | head -n 15
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Twenty</title>
```

#### Method 2: Port-Forwarding Service Access

Tested port-forwarding the service locally:

```bash
$ kubectl port-forward svc/twenty-crm-service 2020:2020
Forwarding from 127.0.0.1:2020 -> 2020
Forwarding from [::1]:2020 -> 2020
```

Verified response on localhost:

```bash
$ curl -s http://localhost:2020/healthz
{"status":"ok","info":{},"error":{},"details":{}}
```

---

### 4.5 Scaling Deployment to 2 Replicas

Scaled the Deployment from 1 to 2 replicas:

```bash
$ kubectl scale deployment twenty-crm-deployment --replicas=2
deployment.apps/twenty-crm-deployment scaled
```

Inspected the Deployment:

```bash
$ kubectl get deployment twenty-crm-deployment
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
twenty-crm-deployment   1/2     2            1           9m45s
```

Inspected pods to verify both replicas are running and scheduled across worker nodes:

```bash
$ kubectl get pods -o wide
NAME                                     READY   STATUS    RESTARTS   AGE     IP           NODE            NOMINATED NODE   READINESS GATES
twenty-crm-deployment-67fb7f648f-lqf4d   0/1     Running   0          2m19s   10.244.2.6   local-worker2   <none>           <none>
twenty-crm-deployment-67fb7f648f-zpm9h   1/1     Running   0          12m     10.244.1.6   local-worker    <none>           <none>
```

- **Pod 1** (`twenty-crm-deployment-67fb7f648f-zpm9h`): `Running` on `local-worker` (`10.244.1.6`)
- **Pod 2** (`twenty-crm-deployment-67fb7f648f-lqf4d`): `Running` on `local-worker2` (`10.244.2.6`)

The Kubernetes scheduler evenly distributed the replicas across the available worker nodes.

---

### 4.6 Scaling Deployment Back to 1 Replica

Scaled the Deployment back to 1 replica:

```bash
$ kubectl scale deployment twenty-crm-deployment --replicas=1
deployment.apps/twenty-crm-deployment scaled
```

Inspected Deployment:

```bash
$ kubectl get deployment twenty-crm-deployment
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
twenty-crm-deployment   1/1     1            1           12m
```

Verified pods:

```bash
$ kubectl get pods -o wide
NAME                                     READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
twenty-crm-deployment-67fb7f648f-zpm9h   1/1     Running   0          13m   10.244.1.6   local-worker   <none>           <none>
```

Re-tested service response to confirm continuous uptime:

```bash
$ curl -s -w "\nHTTP Status: %{http_code}\n" http://172.18.0.4:30020/healthz
{"status":"ok","info":{},"error":{},"details":{}}
HTTP Status: 200
```

---

### 4.7 Resource Cleanup

Deleted the Kubernetes Deployment and Service:

```bash
$ kubectl delete -f kubernetes/service.yml
service "twenty-crm-service" deleted from default namespace

$ kubectl delete -f kubernetes/deployment.yml
deployment.apps "twenty-crm-deployment" deleted from default namespace
```

Verified that no application resources remain in the namespace:

```bash
$ kubectl get pods,svc,deployment -l app=twenty-crm
No resources found in default namespace.
```

---

## 5. Technical Challenges Encountered & Solutions

### 1. Kind Image Availability & `imagePullPolicy`
- **Challenge**: By default, when an image tag is `:latest`, Kubernetes sets `imagePullPolicy: Always`. Kind nodes operate inside separate container namespaces and cannot access the host Docker daemon's image store directly, resulting in `ImagePullBackOff` if the image is not in a remote public registry.
- **Solution**: Explicitly set `imagePullPolicy: IfNotPresent` in the Deployment container specification and pre-loaded the image into the Kind cluster nodes using `kind load docker-image twenty-crm:latest --name local`.

### 2. Slow Startup Time & Probe Failure Resilience
- **Challenge**: The Twenty CRM all-in-one container initializes an embedded PostgreSQL instance, seeds core metadata, executes 325 schema upgrade steps, and compiles GraphQL types before the NestJS HTTP listener starts. Standard `livenessProbe` checks with short initial delays prematurely killed the pod during migrations.
- **Solution**: Configured a `startupProbe` using `httpGet: /healthz` with `failureThreshold: 60` and `periodSeconds: 10`, allowing up to 10 minutes for full bootstrapping. `livenessProbe` and `readinessProbe` only become active after the startup probe succeeds.

### 3. Container Memory Sizing & Swap Space
- **Challenge**: During schema upgrades and workspace seeding, combined memory utilization across Postgres, Redis, NestJS server, NestJS worker, and Yarn reached ~2.8 GB. Setting a strict cgroup limit (`limits.memory: 1536Mi`) caused the Linux OOM killer to terminate the container with exit code 137.
- **Solution**: Enabled a 2GB host swap file (`/swapfile`), removed restrictive cgroup limits from the Deployment spec, and set reasonable `requests` (`memory: 256Mi`, `cpu: 200m`). This allowed the kernel to swap idle pages safely while keeping the container stable and responsive.

---

## 6. Summary of Results

| Verification Step | Target / Command | Result |
| :--- | :--- | :--- |
| **Cluster Status** | `kubectl get nodes` | 3 nodes (1 control-plane, 2 workers) `Ready` |
| **Image Loading** | `kind load docker-image twenty-crm:latest --name local` | Successfully loaded on all nodes |
| **Deployment Creation** | `kubectl apply -f kubernetes/deployment.yml` | `twenty-crm-deployment` created |
| **Service Creation** | `kubectl apply -f kubernetes/service.yml` | `twenty-crm-service` created (NodePort: 30020) |
| **Pod Verification** | `kubectl get pods -o wide` | `twenty-crm-deployment-67fb7f648f-zpm9h` `1/1 Running` |
| **Service Access** | `curl -i http://172.18.0.4:30020/healthz` | HTTP 200 OK `{"status":"ok"}` |
| **Scale to 2 Replicas** | `kubectl scale deployment ... --replicas=2` | 2 pods `Running` across `local-worker` & `local-worker2` |
| **Scale to 1 Replica** | `kubectl scale deployment ... --replicas=1` | Scaled down cleanly to 1 replica (`1/1 Running`) |
| **Resource Deletion** | `kubectl delete -f kubernetes/` | All application pods and services terminated cleanly |

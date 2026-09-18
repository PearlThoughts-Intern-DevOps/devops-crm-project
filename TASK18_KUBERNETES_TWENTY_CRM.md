# Task 18 – Deploy Twenty CRM on Kubernetes

## Objective

Deploy Twenty CRM locally on Kubernetes using Docker Desktop Kubernetes.

Requirements completed:
- Create Kubernetes YAML files
- Deploy Twenty CRM using the existing Docker image
- Deploy PostgreSQL and Redis dependencies
- Create Kubernetes Services
- Verify the Twenty CRM pod
- Access Twenty CRM through a Kubernetes Service
- Scale from 1 to 2 replicas and verify both
- Scale back to 1 replica
- Delete Kubernetes resources

## Kubernetes Environment

Docker Desktop Kubernetes was used instead of Minikube to avoid the additional resource usage of a separate Minikube environment.

- Context: `docker-desktop`
- Kubernetes version: `v1.36.1`
- Node: `desktop-control-plane`

Verification:

```bash
kubectl config get-contexts
kubectl get nodes
```

## Project Structure

```text
kubernetes/
└── twenty-crm.yaml
```

The final working manifest contains seven resources:

1. Secret – `twenty-crm-db`
2. PostgreSQL Deployment – `twenty-postgres`
3. PostgreSQL Service – `twenty-postgres`
4. Redis Deployment – `twenty-redis`
5. Redis Service – `twenty-redis`
6. Twenty CRM Deployment – `twenty-crm`
7. Twenty CRM Service – `twenty-crm`

## Manifest Explanation

### 1. PostgreSQL Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: twenty-crm-db
type: Opaque
stringData:
  POSTGRES_DB: twenty
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres
```

The Secret stores the PostgreSQL database name, username, and password. These values are for this local development/task environment only.

### 2. PostgreSQL Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: twenty-postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: twenty-postgres
  template:
    metadata:
      labels:
        app: twenty-postgres
    spec:
      containers:
        - name: postgres
          image: postgres:16
          ports:
            - containerPort: 5432
          envFrom:
            - secretRef:
                name: twenty-crm-db
```

This creates one PostgreSQL pod using `postgres:16`.

- Port `5432` is the PostgreSQL port.
- `envFrom` loads the database configuration from the Secret.
- The label `app: twenty-postgres` is used by the Service to find this pod.

### 3. PostgreSQL Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: twenty-postgres
spec:
  selector:
    app: twenty-postgres
  ports:
    - port: 5432
      targetPort: 5432
```

The Service provides a stable DNS name for PostgreSQL:

```text
twenty-postgres:5432
```

Twenty CRM can therefore connect to PostgreSQL without using the changing pod IP.

### 4. Redis Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: twenty-redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: twenty-redis
  template:
    metadata:
      labels:
        app: twenty-redis
    spec:
      containers:
        - name: redis
          image: redis:7
          ports:
            - containerPort: 6379
```

This creates one Redis pod using `redis:7`.

Port `6379` is the Redis port.

### 5. Redis Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: twenty-redis
spec:
  selector:
    app: twenty-redis
  ports:
    - port: 6379
      targetPort: 6379
```

The Service provides the stable DNS name:

```text
twenty-redis:6379
```

Twenty CRM uses this name to communicate with Redis.

### 6. Twenty CRM Deployment

The main application uses:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: twenty-crm
  labels:
    app: twenty-crm
spec:
  replicas: 1
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
          image: twentycrm/twenty:latest
          ports:
            - containerPort: 3000
          env:
            - name: PG_DATABASE_URL
              value: "postgresql://postgres:postgres@twenty-postgres:5432/twenty"
            - name: REDIS_URL
              value: "redis://twenty-redis:6379"
            - name: SERVER_URL
              value: "http://localhost:3000"
            - name: NODE_PORT
              value: "3000"
            - name: ENCRYPTION_KEY
              value: "task18-local-development-encryption-key-123456789012345678901234567890"
```

Important points:

- `twentycrm/twenty:latest` is the existing Twenty CRM image.
- `replicas: 1` starts one application pod.
- Port `3000` is the application port.
- `PG_DATABASE_URL` points to the PostgreSQL Kubernetes Service.
- `REDIS_URL` points to the Redis Kubernetes Service.
- `SERVER_URL` and `NODE_PORT` configure the local application.
- The encryption key is a dummy local-development value and is not a production secret.

The important Kubernetes concept is that Twenty CRM connects to PostgreSQL and Redis through Kubernetes Service names rather than pod IP addresses.

### 7. Twenty CRM Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: twenty-crm
spec:
  selector:
    app: twenty-crm
  ports:
    - port: 3000
      targetPort: 3000
  type: NodePort
```

This Service selects all pods with:

```text
app: twenty-crm
```

It forwards Service port `3000` to container port `3000`.

For local access, port forwarding was used:

```bash
kubectl port-forward service/twenty-crm 3000:3000
```

Then Twenty CRM was opened at:

```text
http://localhost:3000
```

## Deployment Steps

### Validate the YAML

```bash
kubectl apply --dry-run=client -f kubernetes/twenty-crm.yaml
```

The client-side dry run completed successfully.

### Apply the manifest

```bash
kubectl apply -f kubernetes/twenty-crm.yaml
```

### Verify pods

```bash
kubectl get pods
```

The final running state was:

```text
twenty-crm       1/1   Running
twenty-postgres  1/1   Running
twenty-redis     1/1   Running
```

### Verify the application

The application was tested from inside the Twenty CRM pod:

```bash
kubectl exec deployment/twenty-crm -- sh -c 'wget -S -O /dev/null http://127.0.0.1:3000/ 2>&1'
```

The application returned:

```text
HTTP/1.1 200 OK
```

The process was also checked and Node.js was listening on port `3000`.

### Access through the Kubernetes Service

```bash
kubectl port-forward service/twenty-crm 3000:3000
```

Open:

```text
http://localhost:3000
```

Twenty CRM successfully displayed its welcome page.

## Scaling Test

### Scale from 1 to 2

```bash
kubectl scale deployment/twenty-crm --replicas=2
```

Verify:

```bash
kubectl get pods -l app=twenty-crm
```

Both replicas reached:

```text
1/1   Running
1/1   Running
```

### Scale back to 1

```bash
kubectl scale deployment/twenty-crm --replicas=1
```

Verify:

```bash
kubectl get pods -l app=twenty-crm
```

One Twenty CRM pod remained in `Running` state.

## Troubleshooting

### Initial PostgreSQL issue

The first attempt deployed only the Twenty CRM application. It failed because PostgreSQL was not available:

```text
connection to server on socket "/run/postgresql/.s.PGSQL.5432" failed
```

Resolution: PostgreSQL and Redis Deployments and Services were added, and Twenty CRM was configured with `PG_DATABASE_URL` and `REDIS_URL` using Kubernetes Service names.

### Temporary port-forward issue

During startup, port forwarding temporarily returned connection refused. The pod was inspected and the Node.js process was found listening on:

```text
:::3000
```

A subsequent HTTP request returned:

```text
HTTP/1.1 200 OK
```

This confirmed that the application had completed startup and was serving traffic.

## Cleanup

All Task 18 resources were deleted after testing:

```bash
kubectl delete -f kubernetes/twenty-crm.yaml
```

Final verification:

```bash
kubectl get pods,services,deployments,secrets | grep -E 'twenty-crm|twenty-postgres|twenty-redis' || echo "Task 18 resources successfully deleted"
```

Result:

```text
Task 18 resources successfully deleted
```

## Task 18 Checklist

- [x] Docker Desktop Kubernetes used
- [x] Kubernetes YAML created
- [x] Twenty CRM deployed
- [x] PostgreSQL deployed
- [x] Redis deployed
- [x] Kubernetes Services created
- [x] Twenty CRM pod verified
- [x] HTTP 200 verified
- [x] Accessed through Kubernetes Service
- [x] Scaled from 1 to 2 replicas
- [x] Both replicas verified as Running
- [x] Scaled back to 1 replica
- [x] All Kubernetes resources deleted

## Conclusion

Twenty CRM was successfully deployed locally on Docker Desktop Kubernetes with PostgreSQL and Redis dependencies. The application was verified through its Kubernetes Service, successfully scaled from one to two replicas and back to one, and all Task 18 resources were removed after testing.

# Task 18: Deploy Twenty CRM on Kubernetes

## Objective

Deploy the Twenty CRM application on a local Kubernetes cluster using Docker Desktop Kubernetes.

The task includes:

- Setting up local Kubernetes
- Creating Kubernetes YAML manifests
- Deploying Twenty CRM
- Creating a Kubernetes Service
- Accessing the application through the Service
- Scaling the Deployment
- Verifying replicas
- Scaling back to one replica
- Cleaning up Kubernetes resources
- Managing the project using Git and GitHub

---

# 1. Environment

## Operating System

- macOS
- Docker Desktop

## Kubernetes

- Kubernetes: Docker Desktop Kubernetes
- Kubernetes Version: v1.34.1
- Kubernetes Context: `docker-desktop`

## Container Platform

- Docker Desktop
- Docker Server Version: 29.2.0

## Application

- Twenty CRM

## Docker Image

```text
twentycrm/twenty-app-dev:latest
Kubernetes Resources
- Deployment
- Service
- Pod


2. Project Structure
The Task 18 files are organized as follows:
task18-twenty-k8s/
├── deployment.yaml
├── service.yaml
├── task18.md
└── screenshots/


3. Kubernetes Cluster Setup
Docker Desktop Kubernetes was enabled and configured for local Kubernetes deployment.
The Kubernetes context was changed to:
kubectl config use-context docker-desktop
The active context was verified using:
kubectl config current-context
Expected output:
docker-desktop
The Kubernetes node was verified using:
kubectl get nodes
Expected result:
NAME             STATUS   ROLES           VERSION
docker-desktop   Ready    control-plane   v1.34.1
This confirmed that the local Kubernetes cluster was running successfully.


4. Existing Twenty CRM Docker Image
The existing Twenty CRM Docker images were checked using:
docker images
The image used for this task was:
twentycrm/twenty-app-dev:latest
The image configuration was inspected using:
docker image inspect twentycrm/twenty-app-dev:latest \
--format 'Entrypoint: {{json .Config.Entrypoint}}'
Output:
Entrypoint: ["/init"]
The exposed port was checked using:
docker image inspect twentycrm/twenty-app-dev:latest \
--format 'ExposedPorts: {{json .Config.ExposedPorts}}'
Output:
ExposedPorts: {"2020/tcp":{}}
Therefore, the Kubernetes configuration uses port 2020.


5. Kubernetes Deployment
A Kubernetes Deployment was created in:
task18-twenty-k8s/deployment.yaml
The Deployment uses the existing Twenty CRM Docker image.
deployment.yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: twenty-crm

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
          image: twentycrm/twenty-app-dev:latest
          imagePullPolicy: IfNotPresent

          ports:
            - containerPort: 2020

          env:
            - name: PORT
              value: "2020"

            - name: NODE_ENV
              value: "development"

            - name: STORAGE_TYPE
              value: "local"

            - name: APPLICATION_LOG_DRIVER
              value: "CONSOLE"


6. Deployment YAML Validation
Before deploying, the Kubernetes YAML was validated using:
kubectl apply --dry-run=client -f deployment.yaml
The validation was successful:
deployment.apps/twenty-crm created (dry run)
This confirmed that the Deployment manifest was syntactically valid.


7. Kubernetes Service
A Kubernetes Service was created in:
task18-twenty-k8s/service.yaml
The Service provides network access to the Twenty CRM Deployment.
service.yaml
apiVersion: v1
kind: Service

metadata:
  name: twenty-crm

spec:
  type: NodePort

  selector:
    app: twenty-crm

  ports:
    - port: 2020
      targetPort: 2020
The Service uses:
Service Port: 2020
Target Port: 2020
Service Type: NodePort


8. Service YAML Validation
The Service manifest was validated using:
kubectl apply --dry-run=client -f service.yaml
Validation was successful:
service/twenty-crm created (dry run)


9. Deploy Twenty CRM
The Deployment and Service were deployed using:
kubectl apply -f deployment.yaml -f service.yaml
The resources were created successfully.


10. Verify Twenty CRM Pod
The running Pods were checked using:
kubectl get pods
The Twenty CRM Pod reached:
READY   STATUS
1/1     Running
Example:
twenty-crm-xxxxxxxxxx-xxxxx   1/1   Running
This confirmed that the Twenty CRM container was running successfully inside Kubernetes.


11. Verify Deployment
The Deployment was checked using:
kubectl get deployment twenty-crm
Expected result:
NAME         READY   UP-TO-DATE   AVAILABLE
twenty-crm   1/1     1            1
This confirmed that one replica was successfully deployed and available.


12. Verify Kubernetes Service
The Service was checked using:
kubectl get service twenty-crm
The Service was configured as:
TYPE       PORT(S)
NodePort   2020:32039/TCP
The exact NodePort may vary depending on Kubernetes allocation, but during this deployment it was:
32039
Therefore:
2020 → 32039


13. Application Access
The Twenty CRM application was accessed through the Kubernetes Service using:
kubectl port-forward service/twenty-crm 2020:2020
The port forwarding command provided:
Forwarding from 127.0.0.1:2020 -> 2020
The application was then opened in the browser at:
http://localhost:2020
Twenty CRM loaded successfully in the browser.
This confirmed that the Kubernetes Service was successfully routing traffic to the Twenty CRM Pod.


14. Application Verification
The application was also tested from inside the Kubernetes Pod using:
kubectl exec deployment/twenty-crm -- \
sh -c 'curl -I http://127.0.0.1:2020'
The application returned:
HTTP/1.1 200 OK
This confirmed that the Twenty CRM HTTP server was responding successfully on port 2020.


15. Scale Deployment to 2 Replicas
The Deployment was scaled from one replica to two replicas using:
kubectl scale deployment twenty-crm --replicas=2
The Pods were then verified using:
kubectl get pods -l app=twenty-crm
Two Pods were running:
twenty-crm-xxxxxxxxxx-xxxxx   1/1   Running
twenty-crm-xxxxxxxxxx-xxxxx   1/1   Running


16. Verify Two Replicas
The Deployment status was verified using:
kubectl get deployment twenty-crm
The result was:
NAME         READY   UP-TO-DATE   AVAILABLE
twenty-crm   2/2     2            2
This confirmed that both replicas were successfully running.


17. Scale Deployment Back to One Replica
After verifying two replicas, the Deployment was scaled back to one replica:
kubectl scale deployment twenty-crm --replicas=1
The Deployment was verified using:
kubectl get deployment twenty-crm
Result:
NAME         READY   UP-TO-DATE   AVAILABLE
twenty-crm   1/1     1            1
The Pods were verified using:
kubectl get pods -l app=twenty-crm
Final state:
twenty-crm-xxxxxxxxxx-xxxxx   1/1   Running
This confirmed that the Deployment successfully returned to one replica.


18. Kubernetes Resource Cleanup
After completing the deployment, access, scaling, and verification steps, the Kubernetes resources were deleted.
The following command was used:
kubectl delete -f deployment.yaml -f service.yaml
The resources were successfully deleted:
deployment.apps "twenty-crm" deleted
service "twenty-crm" deleted
The cleanup was verified using:
kubectl get all -l app=twenty-crm
Result:
No resources found in default namespace.
This confirmed that the Task 18 Kubernetes resources were successfully removed.


19. Git Branch
A dedicated Git branch was created for Task 18:
git switch -c bkkrish007-task18
The active branch was verified using:
git branch --show-current
Result:
bkkrish007-task18


20. Files Added
The Task 18 Kubernetes files are:
task18-twenty-k8s/deployment.yaml
task18-twenty-k8s/service.yaml
task18-twenty-k8s/task18.md
Screenshots documenting the implementation are stored under:
task18-twenty-k8s/screenshots/


21. Git Commit
The Task 18 changes were committed using:
git commit -m "Add Kubernetes deployment for Twenty CRM"
The commit included the Kubernetes manifests and task evidence screenshots.


22. Git Push
The Task 18 branch will be pushed to the remote repository using:
git push -u origin bkkrish007-task18


23. Pull Request
A Pull Request will be created from:
bkkrish007-task18
to:
devops-crm-project
Suggested PR title:
Task 18: Deploy Twenty CRM on Kubernetes
The PR will include:
- Kubernetes Deployment
- Kubernetes Service
- Task documentation
- Screenshots
- Verification details
- Loom video


24. Evidence Screenshots
The following screenshots were captured as evidence for the task:
1. Docker Desktop Kubernetes running
2. Kubernetes node status
3. Twenty CRM Deployment and Pod status
4. Kubernetes Service status
5. Twenty CRM application running in browser
6. Port forwarding
7. Scaling from 1 replica to 2 replicas
8. Two Pods running
9. Deployment showing 2/2 replicas
10. Scaling back to 1 replica
11. Final single Pod running
12. Kubernetes resource deletion
13. Verification showing no remaining Kubernetes resources


25. Task Completion Checklist
Requirement	Status
Set up local Kubernetes	Completed
Create Kubernetes YAML files	Completed
Create Deployment	Completed
Create Service	Completed
Use existing Twenty CRM image	Completed
Deploy using kubectl	Completed
Verify Pod running	Completed
Access Twenty CRM through Service	Completed
Scale to 2 replicas	Completed
Verify both Pods running	Completed
Scale back to 1 replica	Completed
Delete Kubernetes resources	Completed
Create Task 18 Git branch	Completed
Add Task 18 files	Completed
Commit changes	Completed
Push branch	Pending/To be completed
Raise Pull Request	Pending/To be completed
Loom video	Pending/To be completed


26. Conclusion
Twenty CRM was successfully deployed on a local Kubernetes cluster using Docker Desktop Kubernetes.
The application was deployed using a Kubernetes Deployment and exposed using a NodePort Service. The application was successfully accessed through Kubernetes Service port forwarding.
The Deployment was tested with both one and two replicas, confirming that Kubernetes scaling worked correctly. After verification, the Deployment was scaled back to one replica and all Kubernetes resources were deleted as required.
The Kubernetes manifests, documentation, screenshots, and Git history provide evidence of the complete Task 18 implementation.
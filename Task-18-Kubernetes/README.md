\# Task 18: Deploy Twenty CRM on Kubernetes



\## 1. Overview



This task demonstrates the deployment of Twenty CRM on a local Kubernetes cluster using Minikube.



The existing Twenty CRM Docker image was deployed using Kubernetes Deployment and Service manifests. The application was verified through the Kubernetes Service and the Deployment was scaled from one replica to two replicas and then scaled back to one replica.



After completing the verification, the Kubernetes resources were deleted as required.



\---



\## 2. Objectives



The objectives of this task were:



\- Set up Kubernetes locally using Minikube.

\- Create Kubernetes YAML manifests.

\- Deploy Twenty CRM using a Kubernetes Deployment.

\- Expose Twenty CRM using a Kubernetes Service.

\- Use the existing Twenty CRM Docker image.

\- Deploy the application using `kubectl`.

\- Verify the application Pod.

\- Access Twenty CRM through the Kubernetes Service.

\- Scale the Deployment from 1 to 2 replicas.

\- Verify both replicas are running.

\- Scale the Deployment back to 1 replica.

\- Delete Kubernetes resources after completing the task.



\---



\## 3. Technologies Used



\- Kubernetes

\- Minikube

\- Docker Desktop

\- kubectl

\- Twenty CRM

\- YAML

\- Windows PowerShell



\---



\## 4. Architecture



The deployment architecture is:



```text

&#x20;                   Windows 11

&#x20;                       |

&#x20;                 Docker Desktop

&#x20;                       |

&#x20;                   Minikube

&#x20;                       |

&#x20;               Kubernetes Cluster

&#x20;                       |

&#x20;             +---------+---------+

&#x20;             |                   |

&#x20;       Deployment              Service

&#x20;      twenty-crm              twenty-crm

&#x20;             |                   |

&#x20;      +------+------+

&#x20;      |             |

&#x20;    Pod 1         Pod 2

&#x20;      |             |

&#x20;  Twenty CRM    Twenty CRM



The Deployment manages the Twenty CRM Pods, while the Kubernetes Service provides access to the application.



5\. Minikube Setup



Minikube was used as the local Kubernetes environment with the Docker driver.



The cluster was verified using:



minikube status



The Kubernetes node was verified using:



kubectl get nodes



The node reached the Ready state.



6\. Project Structure

Task-18-Kubernetes/

│

├── README.md

│

└── k8s/

&#x20;   ├── deployment.yaml

&#x20;   └── service.yaml

7\. Twenty CRM Docker Image



The existing Twenty CRM image was used:



twentycrm/twenty-app-dev:v2.35



The image was specified directly in the Kubernetes Deployment manifest.



8\. Kubernetes Deployment



The Deployment was defined in:



k8s/deployment.yaml



The Deployment uses:



apiVersion: apps/v1

kind: Deployment



The application container uses:



image: twentycrm/twenty-app-dev:v2.35



The application listens on:



Port: 2020



The initial replica count was:



replicas: 1

9\. Environment Configuration



The Deployment defines the following environment variables:



NODE\_ENV=production

PORT=2020

NODE\_PORT=2020

SIGN\_IN\_PREFILLED=true

STORAGE\_TYPE=local

STORAGE\_LOCAL\_PATH=/app/.local-storage



These variables configure the Twenty CRM container for the Kubernetes deployment.



10\. Health Checks



Kubernetes health checks were configured using the Twenty CRM health endpoint:



/healthz



A startup probe was configured to allow sufficient time for the application to initialize its internal services.



Readiness and liveness probes were also configured.



Example:



startupProbe:

&#x20; httpGet:

&#x20;   path: /healthz

&#x20;   port: 2020

&#x20; periodSeconds: 10

&#x20; timeoutSeconds: 5

&#x20; failureThreshold: 30



The readiness probe determines whether the application is ready to receive traffic.



The liveness probe allows Kubernetes to detect an unhealthy application container.



11\. Kubernetes Service



The Service was defined in:



k8s/service.yaml



The Service uses:



kind: Service

type: NodePort



The application port is:



2020



The Service selects Pods using:



selector:

&#x20; app: twenty-crm



This connects the Service to the Twenty CRM Pods managed by the Deployment.



12\. Manifest Validation



The Deployment manifest was validated using:



kubectl apply --dry-run=client -f k8s\\deployment.yaml



The Service manifest was validated using:



kubectl apply --dry-run=client -f k8s\\service.yaml

13\. Application Deployment



The Kubernetes resources were deployed using:



kubectl apply -f k8s\\



The Deployment was verified using:



kubectl get deployments



The Pods were verified using:



kubectl get pods

14\. Pod Verification



After application initialization, the Twenty CRM Pod reached:



READY   STATUS

1/1     Running



The Pod had zero restarts after successful startup.



This confirmed that the Twenty CRM application was running successfully inside Kubernetes.



15\. Accessing Twenty CRM



The Kubernetes Service was used to access the application.



The Minikube Service URL was obtained using:



minikube service twenty-crm --url



The returned local URL was opened in a browser.



The Twenty CRM Companies page loaded successfully.



This confirmed that:



The Kubernetes Service was working.

Traffic was reaching the Twenty CRM application.

The application was functioning successfully.

16\. Scaling to Two Replicas



The Deployment was scaled from one replica to two replicas using:



kubectl scale deployment twenty-crm --replicas=2



The Pods were monitored using:



kubectl get pods -w



Both Pods successfully reached:



READY   STATUS

1/1     Running



with zero restarts.



Example:



twenty-crm-xxxxxxxxxx-xxxxx   1/1   Running   0

twenty-crm-xxxxxxxxxx-yyyyy   1/1   Running   0



This verified that Kubernetes successfully maintained two Twenty CRM replicas.



17\. Scaling Back to One Replica



After verifying two replicas, the Deployment was scaled back to one:



kubectl scale deployment twenty-crm --replicas=1



The Deployment was verified using:



kubectl get deployment



The final state was:



NAME         READY   UP-TO-DATE   AVAILABLE

twenty-crm   1/1     1            1



The remaining Pod was:



READY   STATUS    RESTARTS

1/1     Running   0



This confirmed successful scaling back to one replica.



18\. Kubernetes Resource Cleanup



After completing the deployment, service access, and scaling verification, the Kubernetes resources were deleted as required.



The resources were removed using:



kubectl delete -f k8s\\



The Deployment and Service were successfully deleted.



Verification:



kubectl get deployments

kubectl get pods

kubectl get services



The default namespace contained no Twenty CRM Deployment or Pod.



The built-in Kubernetes API Service remained, which is expected.



19\. Troubleshooting



During the deployment, the Twenty CRM Pod initially remained in the Running state but was not Ready.



Investigation using:



kubectl describe pod <pod-name>



showed failed health probes and container restarts.



The container was performing internal initialization including:



PostgreSQL startup

Redis startup

Database initialization

Database migrations

Twenty server startup

Twenty worker startup



The container was initially terminated with exit code 137.



The Kubernetes configuration was adjusted to use a startup probe, allowing sufficient time for the application to initialize before liveness and readiness checks became active.



After the configuration was applied and the Kubernetes environment was restarted cleanly, the Twenty CRM Pod successfully reached:



1/1 Running



with zero restarts.



20\. Verification Summary

Requirement	Result

Minikube Kubernetes cluster	Completed

Kubernetes Deployment	Completed

Kubernetes Service	Completed

Twenty CRM image deployed	Completed

Pod verification	Completed

Twenty CRM browser access	Completed

Scale 1 → 2 replicas	Completed

Verify 2 healthy Pods	Completed

Scale 2 → 1 replica	Completed

Resource cleanup	Completed

21\. Evidence



The following evidence was captured during the task:



Minikube/Kubernetes cluster status.

Kubernetes node status.

Twenty CRM Pod running and Ready.

Twenty CRM accessed through Kubernetes Service.

Two Twenty CRM replicas running simultaneously.

Deployment scaled back to one replica.

Kubernetes resources successfully deleted.

22\. Conclusion



This task demonstrated the deployment and basic management of Twenty CRM using Kubernetes and Minikube.



The application was successfully deployed using a Kubernetes Deployment, exposed through a NodePort Service, accessed through the browser, scaled from one to two replicas, and scaled back to one replica.



After verification, the Kubernetes resources were removed successfully.





Save and close Notepad.



\---



\## 2. Check the Task 18 files



Run:



```powershell

Get-ChildItem Task-18-Kubernetes -Recurse -File


# Task 18: Deploy Twenty CRM on Kubernetes

## Objective

Deploy the Twenty CRM application on a local Kubernetes cluster, verify it is accessible through a Kubernetes Service, scale the deployment, and clean up all created resources.

## Environment

Kubernetes was enabled locally using **Docker Desktop Kubernetes** (not Minikube).

## Overview of Work Done

- Enabled Kubernetes through Docker Desktop and confirmed the cluster was up and running.
- Created Kubernetes YAML manifests for Twenty CRM:
  - A **Deployment** file, configured to use the existing Twenty CRM Docker image.
  - A **Service** file, used to expose the application so it could be accessed from the browser.
- Applied both manifests to the cluster using `kubectl`.
- Verified that the Twenty CRM pod came up successfully and was in a `Running` state.
- Accessed the Twenty CRM application through the Kubernetes Service and confirmed it loaded correctly.
- Scaled the Deployment from 1 replica to **2 replicas** and verified that both pods were running.
- Scaled the Deployment back down to **1 replica**.
- Deleted the Deployment and Service resources from the cluster to clean up after the task was completed.

## Result

The Twenty CRM application was successfully deployed on a local Docker Desktop Kubernetes cluster, accessed via the Service, scaled up and down as required, and the resources were cleanly removed afterward.

## Git Workflow

- **Branch:** `Bhavish-task-18`
- Added the Kubernetes YAML files to this branch.
- Raised a Pull Request in `devops-crm-project`.
- Included a Loom video walking through the work, with face visible throughout.

## Deadline

Submitted and PR raised before **7:00 PM**.

## Documentation

Detailed documentation, including commands and screenshots, is available in:

\`\`\`text
Documentation/Task-18-Documentation.docx
\`\`\`

# Task 17 - Twenty CRM Deployment using Terraform and Ansible

## Overview

Task 17 demonstrates the deployment and configuration of the Twenty CRM application using **Terraform** and **Ansible**.

Terraform is used to provision the AWS infrastructure, while Ansible is used to configure the server, install Docker and Docker Compose, create the Twenty CRM Docker Compose configuration, and start the application.

---

## Technologies Used

- AWS
- Terraform
- Ansible
- Docker
- Docker Compose
- PostgreSQL
- Redis
- Twenty CRM
- Git
- GitHub

---

## Project Structure

```text
terraform-task-17/
│
├── ansible/
│   ├── inventory
│   └── playbook.yml
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── .terraform.lock.hcl
└── README.md

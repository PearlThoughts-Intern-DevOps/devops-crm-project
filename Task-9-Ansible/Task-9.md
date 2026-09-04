\# Task 9 – Automating Twenty CRM Deployment with Ansible



\## 1. Objective



The objective of this task was to automate the deployment of Twenty CRM using Ansible.



The implementation was required to:



\- Create an Ansible inventory with a target host.

\- Install required dependencies and Docker.

\- Create a dedicated application user.

\- Create application directories with appropriate permissions.

\- Clone the Twenty CRM repository.

\- Configure Twenty CRM using Ansible variables and Jinja2 templates.

\- Deploy Twenty CRM using Docker Compose.

\- Use an Ansible handler to restart the application when configuration changes.

\- Verify that Twenty CRM runs successfully.

\- Ensure that the playbook is idempotent.



\---



\## 2. Environment



The implementation was developed and tested in an Ubuntu Linux playground.



| Component | Version |

|---|---|

| Operating System | Ubuntu 26.04.1 LTS |

| Ansible | 2.20.1 |

| Python | 3.14.4 |

| Docker | 29.1.3 |

| Docker Compose | 2.40.3 |

| community.docker | 5.0.4 |



\---



\## 3. Project Structure



```text

Task-9-Ansible/

├── .gitignore

├── README.md

├── inventory.ini

├── group\_vars.yml

├── playbook.yml

├── screenshots/

└── templates/

&#x20;   ├── .env.j2

&#x20;   └── docker-compose.yml.j2


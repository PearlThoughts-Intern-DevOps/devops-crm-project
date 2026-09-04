\# Task 9 - Ansible Playbook for Twenty CRM



\## Objective



Automate the setup and deployment of Twenty CRM using Ansible.



The implementation covers:



\- Inventory creation

\- Required dependency and Docker installation

\- Dedicated application user creation

\- Application directory creation and permissions

\- Twenty CRM repository cloning

\- Secure secret generation

\- Jinja2-based application configuration

\- Docker Compose configuration

\- Twenty CRM deployment

\- Ansible handler for configuration changes

\- Application health verification

\- Idempotency testing



\## Environment



| Component | Details |

|---|---|

| Playground | Killercoda |

| Operating System | Ubuntu 24.04 LTS |

| Ansible | ansible-core 2.16.3 |

| Docker | Docker 29.1.3 |

| Docker Compose | 2.40.3 |

| community.docker | 3.13.3 |



\## Project Structure



```text

ansible/

├── group\_vars/

│   └── all.yml

├── inventory.ini

├── playbook.yml

└── templates/

&#x20;   ├── .env.j2

&#x20;   └── docker-compose.yml.j2


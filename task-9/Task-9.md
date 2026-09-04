# Task 9: Ansible Playbook

## Objective

The objective of this task was to automate the setup and deployment of
Twenty CRM using Ansible inside a Linux playground.

The implementation automates the installation of required dependencies,
Docker setup, application user creation, directory configuration, Twenty
CRM repository cloning, application configuration using Ansible
variables and Jinja2 templates, Docker Compose deployment, application
verification, and idempotency testing.

---

## 1. Playground Environment

The complete implementation was created and tested inside an Ubuntu
24.04 Linux playground using Killercoda.

Ansible was installed and verified before starting the implementation.

The Ubuntu playground itself was used as the Ansible target host through
a local connection.

---

## 2. Ansible Project Structure

```text
task-9/
├── inventory
├── site.yml
├── Task-9.md
├── group_vars/
│   └── all.yml
└── templates/
    └── docker-compose.yml.j2
```

### Purpose of the files

- `inventory` - Defines the hosts that Ansible manages and the connection method used to reach them.
- `site.yml` - The main Ansible playbook containing the automation tasks, handler, deployment steps, and application verification.
- `group_vars/all.yml` - Stores reusable application configuration used by the playbook and templates.
- `templates/docker-compose.yml.j2` - A Jinja2 template used by Ansible to generate the Docker Compose configuration dynamically from the defined variables.
- `Task-9.md` - Documents the implementation, testing process, issues faced, verification results.

---

## 3. Inventory

The inventory defines the target host:

``` ini
[twenty]
localhost ansible_connection=local
```

Ansible connectivity was tested using:

``` bash
ansible -i inventory twenty -m ping
```
---

## 4. Ansible Variables

Application configuration was stored in `group_vars/all.yml`.

-  Linux user created by ansible
- Directory on target machine
- The repo address from where ansible clones the source code
- Git Branch/Version of repo
- Port whihc is used to expose the Twenty CRM app.

Using variables makes the configuration easier to maintain and allows
the Jinja2 template to use dynamic values.

---

## 5. Ansible Playbook

The `site.yml` playbook automates the complete setup.

- Installing Dependencies

- Creating the Application User

- Creating Application Directories

- Cloning Twenty CRM

---

## 6. Jinja2 Template

The Docker Compose configuration is generated using:

``` text
templates/docker-compose.yml.j2
```

The template uses Ansible variables such as:

- Port through which Twenty CRM is exposed.
- PostgreSQl username, password and database
- Redis port connected to CRM.
- Encryption key for handling encrypted application data.

This allows the Docker Compose configuration to be generated dynamically
from the Ansible variables.

------------------------------------------------------------------------

## 7. Docker Compose Deployment

Twenty CRM was started using Docker Compose.

The deployment consists of:

-   Twenty server
-   Twenty worker
-   PostgreSQL
-   Redis

The application was exposed on port `2020`.

---

## 8. Application Verification

The Docker Compose services were checked using:

``` bash
docker compose ps
```

The required services were running and healthy.

The application was then verified using:

``` bash
curl -I http://localhost:2020
```

The application returned:

``` text
HTTP/1.1 200 OK
```

This confirmed that Twenty CRM was successfully running.

------------------------------------------------------------------------

## 9. Idempotency Test

After the initial successful deployment, the Ansible playbook was
executed again.

The second execution completed with:

``` text
ok=10
changed=0
unreachable=0
failed=0
skipped=0
```
The `changed=0` result demonstrates that the second execution did not
make unnecessary changes to the existing configuration.

------------------------------------------------------------------------

## 10. Issues Faced

### Issue 1:  Undefined Ansible Variable

During testing, the playbook reported:

``` text
'redis_port' is undefined
```

The missing variable was added to `group_vars/all.yml`, after which the
playbook continued successfully.

### Issue 2: Twenty Server Initially Unhealthy

During startup, the Twenty server initially reported as unhealthy while
the application and its dependencies were initializing.

After initialization, the server became healthy and the application was
successfully verified using:

``` bash
curl -I http://localhost:2020
```

which returned:

``` text
HTTP/1.1 200 OK
```
---

## 11. Screenshots
The screenshots demonstrate:

1.  Ansible inventory.
2.  Ansible variables.
3.  Ansible playbook.
4.  Jinja2 Docker Compose template.
5.  Successful Ansible execution and idempotency.
6.  Healthy Docker Compose services.
7.  Twenty CRM HTTP verification.

---
## 12. Conclusion

This task demonstrated how Ansible can automate the setup and deployment
of Twenty CRM in a Linux environment.

Twenty CRM was successfully deployed and verified.

### Thank you!

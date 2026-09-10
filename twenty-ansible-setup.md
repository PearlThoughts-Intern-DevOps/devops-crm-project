# Twenty CRM Deployment Using Ansible

## **Overview**

I deployed the **Twenty CRM application** using **Ansible** on a Linux-based KodeKloud Ansible Playground.

The main goal was to automate the application deployment instead of manually configuring the target server.

**Environment:**

- **Ansible Controller:** `ansible-controller`
- **Target Server:** `web1`
- **Application User:** `twenty`
- **Application Directory:** `/opt/twenty`
- **Inventory:** `inventory/hosts.ini`
- **Playbook:** `twenty_site.yml`
- **Repository:** `https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git`

## **1. Verify Ansible**

I first checked whether Ansible was installed and verified its version.

```bash
ansible --version
```

## **2. Create Inventory**

I created `inventory/hosts.ini` to define the target server.

```ini
[twenty]
web1 ansible_host=web1 ansible_user=root ansible_password=Passw0rd
```

I tested connectivity using:

```bash
ansible -i inventory/hosts.ini twenty -m ansible.builtin.ping
```

The target returned **pong**, confirming that Ansible could communicate with the server.

## **3. Inspect the Target Server**

I checked the operating system and Docker installation:

```bash
ansible -i inventory/hosts.ini twenty -m ansible.builtin.command -a "cat /etc/os-release"
ansible -i inventory/hosts.ini twenty -m ansible.builtin.command -a "docker --version"
ansible -i inventory/hosts.ini twenty -m ansible.builtin.command -a "docker compose version"
```

Docker was initially unavailable, so I added the required installation tasks to the playbook.

## **4. Install Dependencies and Docker**

In `twenty_site.yml`, I used Ansible's **apt** module to install the required packages, Docker, and Docker Compose.

I also used the **service** module to ensure Docker was running and enabled at system startup.

```bash
ansible-playbook -i inventory/hosts.ini twenty_site.yml
```

I verified the installation with:

```bash
docker --version
docker compose version
systemctl is-active docker
```

## **5. Create Application User**

I created a dedicated **twenty** user and group instead of running the application directly as root.

The application directory was created at:

```text
/opt/twenty
```

I used Ansible's **user**, **group**, and **file** modules to manage the user, group, directory, and ownership.

## **6. Clone the Repository**

I used Ansible's **git** module to clone the Twenty CRM repository into `/opt/twenty`.

```yaml
repo: "https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git"
dest: /opt/twenty
```

I initially faced an issue because `become_user: twenty` caused Ansible temporary files to be created inside the destination directory. This made the directory non-empty and the Git task failed.

I fixed the issue by removing the unnecessary `become_user` from the Git task and then setting the correct application ownership.

## **7. Variables and Jinja2 Templates**

I learned how Ansible separates configuration from task logic using **variables**.

I created:

```text
group_vars/twenty.yml
```

for deployment-specific values.

I also used a Jinja2 template:

```text
templates/docker-compose.yml.j2
```

The template allows the Docker Compose configuration to be generated dynamically using Ansible variables instead of hardcoding deployment values.

## **8. Docker Compose Deployment**

I used the generated Docker Compose configuration to start the Twenty CRM application.

The application files and configuration are maintained under:

```text
/opt/twenty
```

The deployment is controlled through Ansible, making the process repeatable instead of manually executing commands on the server.

## **9. Ansible Handler**

I added an Ansible **handler** to restart or re-apply the Twenty CRM deployment when the Compose configuration changes.

The configuration task uses:

```yaml
notify: Restart Twenty CRM
```

This means the handler runs only when the configuration task reports a change, avoiding unnecessary application restarts.

## **10. Verification**

After deployment, I verified that the Docker containers were running successfully.

```bash
docker compose -f /opt/twenty/docker-compose.yml ps
docker ps
```

I also checked the application/service status to confirm that the deployment completed successfully.

## **11. Idempotency**

An important concept I learned was **idempotency**.

Running the same playbook multiple times should not repeatedly recreate resources that are already in the desired state.

I tested this by running:

```bash
ansible-playbook -i inventory/hosts.ini twenty_site.yml
```

again after the initial deployment and checking that unnecessary changes were not reported.

## **Final Flow**

**Inventory → Connectivity Test → Server Inspection → Dependencies → Docker → Application User → Git Clone → Variables → Jinja2 Template → Docker Compose → Handler → Verification → Idempotency**

## **What I Learned**

Through this task, I learned the practical Ansible deployment flow, including **inventory management, Ansible modules, privilege escalation, variables, Jinja2 templates, handlers, Git deployment, Docker integration, and idempotency**.

The main takeaway was understanding how Ansible can convert a manual deployment process into a **repeatable, automated, and maintainable configuration workflow**.

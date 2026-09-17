# Task 17: Ansible and AWS EC2 Deployment

## Objective

Deploy Twenty CRM on an AWS EC2 instance provisioned with Terraform,
configure the server and application with Ansible, verify the
deployment, and then destroy the EC2 infrastructure with Terraform.

## AWS / Terraform Configuration

-   Region: `us-east-1`
-   Instance type: `t3.small`
-   AMI: `ami-0b6d9d3d33ba97d99`
-   VPC: Default VPC
-   Subnet: Default subnet in the default VPC
-   Root volume: 20 GiB `gp3`
-   EC2 public IP: `98.92.131.149`
-   EC2 instance ID: `i-00ef43fc9b65f8e0b`
-   Terraform-created key pair: `twenty-task17-key`
-   Security group: `prabhas-task17-sg`
-   Application port: `2020`

Terraform created five resources:

1.  TLS private key
2.  AWS EC2 key pair
3.  Local sensitive private-key file
4.  Security group
5.  EC2 instance

Terraform plan result:

``` text
Plan: 5 to add, 0 to change, 0 to destroy.
```

Terraform output before cleanup:

``` text
instance_id = "i-00ef43fc9b65f8e0b"
private_key_path = "./twenty-task17-key.pem"
public_ip = "98.92.131.149"
```

## Ansible Configuration

Ansible was installed in the Ubuntu WSL distribution.

Ansible version:

``` text
ansible [core 2.20.1]
```

Inventory:

``` ini
[twenty]
twenty-server ansible_host=98.92.131.149 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/twenty-task17-key.pem
```

Ansible SSH connectivity was verified successfully with the `ping`
module.

The playbook file is:

``` text
ansible/task17/deploy-twenty.yml
```

The playbook performs the following:

-   Updates the apt package cache
-   Upgrades installed packages
-   Installs Docker and required dependencies
-   Enables and starts Docker
-   Creates `/opt/twenty`
-   Creates `/opt/twenty/data`
-   Creates `/opt/twenty/logs`
-   Creates the `twenty-net` Docker network
-   Deploys PostgreSQL 16
-   Deploys Redis 7
-   Creates the Twenty CRM environment file
-   Generates an application secret on the EC2 host
-   Deploys Twenty CRM
-   Configures Docker restart policy as `always`
-   Configures the Twenty CRM health check
-   Waits for the container to become healthy
-   Verifies HTTP status `200`
-   Displays Docker container status
-   Displays application logs

## Twenty CRM Docker Configuration

Containers deployed:

  Container        Image                       Purpose
  ---------------- --------------------------- ------------------------
  `twenty-db`      `postgres:16`               PostgreSQL database
  `twenty-redis`   `redis:7`                   Redis service
  `twenty-crm`     `twentycrm/twenty:latest`   Twenty CRM application

Twenty CRM is exposed as:

``` text
EC2 port 2020 -> Container port 3000
```

Health check:

``` text
curl -f http://localhost:3000/ || exit 1
```

Health-check configuration:

-   Interval: 30 seconds
-   Timeout: 10 seconds
-   Retries: 3
-   Start period: 60 seconds

## Ansible Deployment Result

The complete playbook execution finished successfully:

``` text
PLAY RECAP
twenty-server : ok=21 changed=8 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

This confirms there were no unreachable or failed tasks.

## Deployment Verification

Docker verification showed:

``` text
twenty-crm    twentycrm/twenty:latest    Up ... (healthy)    0.0.0.0:2020->3000/tcp
twenty-redis  redis:7                    Up ...
twenty-db     postgres:16                Up ...
```

Twenty CRM health status:

``` text
healthy
```

HTTP verification:

``` text
status: 200
url: http://127.0.0.1:2020
```

Restart-policy verification:

``` text
/twenty-db restart=always
/twenty-redis restart=always
/twenty-crm restart=always
```

Application logs returned successfully with exit code `0` and showed
normal Nest application activity.

Twenty CRM was also opened successfully through the public URL:

``` text
http://98.92.131.149:2020
```

## SSH / WSL Note

Ansible was run from Ubuntu WSL rather than Git Bash because Ansible was
not installed in Git Bash. The Terraform-generated private key was
copied into WSL and assigned restrictive permissions:

``` text
~/.ssh/twenty-task17-key.pem
```

This was necessary because the key stored on the Windows-mounted
filesystem was initially seen by Linux as having permissions `0777`.

## Evidence

Recommended Loom/screenshots:

1.  Terraform `plan` showing 5 resources to add.
2.  Terraform `apply` output showing EC2 instance ID and public IP.
3.  Ansible syntax check.
4.  Successful Ansible playbook recap with `failed=0`.
5.  Docker container status.
6.  Twenty CRM health status: `healthy`.
7.  HTTP verification showing status `200`.
8.  Restart policy showing `always` for all three containers.
9.  Twenty CRM application page in the browser.
10. Application logs.

## Cleanup

After evidence and documentation are captured, destroy the EC2
infrastructure with:

``` bash
cd ~/Downloads/devops-crm-project/terraform/task17
terraform destroy
```

Confirm with:

``` text
yes
```

The cleanup is required by Task 17.

## Summary

Terraform provisioned the required AWS EC2 infrastructure in
`us-east-1`. Ansible successfully configured the server and deployed
Twenty CRM together with PostgreSQL and Redis. The Twenty CRM container
became healthy, returned HTTP 200 locally, used the required `always`
restart policy, and was accessible through the EC2 public IP on port
2020.

The EC2 resources should be destroyed with Terraform after the final
evidence and Loom recording are complete.


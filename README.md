# Task 17 — Ansible and AWS EC2 Deployment (Twenty CRM)

Terraform provisions a single EC2 instance; Ansible configures it and deploys
Twenty CRM via Docker Compose. Full write-up is in `documentation/DOCUMENTATION.md`.

## Folder structure

```
task17/
├── README.md                    - this file
├── terraform/                   - infrastructure (EC2 + networking)
│   ├── main.tf                  - default VPC/subnet lookup, security group, EC2 instance
│   ├── variables.tf             - region, instance type, AMI, key pair, name_prefix, etc.
│   └── outputs.tf                - public IP / DNS / instance ID after apply
├── ansible/                     - configuration + deployment
│   ├── ansible.cfg              - points at inventory.ini and the SSH key
│   ├── inventory.ini            - target host (EC2 public IP)
│   ├── playbook.yml             - full deployment playbook (see documentation)
│   └── templates/
│       └── env.j2               - template for the app's .env file
├── documentation/
│   └── DOCUMENTATION.md         - full task write-up: steps, issues hit, fixes, verification
└── ss/                          - screenshots for the PR / Loom reference
    ├── terraform-apply.png
    ├── ansible-run.png
    ├── docker-ps.png
    └── app-ui.png
```

## Quick start

```bash
# 1. Provision infrastructure
cd terraform
terraform init
terraform apply -var="key_name=<your-key-pair>" -var="name_prefix=<your-name>"

# 2. Point Ansible at the new instance
#    edit ansible/inventory.ini -> replace REPLACE_WITH_EC2_PUBLIC_IP with the
#    ec2_public_ip Terraform just printed

# 3. Deploy
cd ../ansible
ansible twenty_crm -m ping
ansible-playbook playbook.yml

# 4. Open the app
#    http://<EC2_PUBLIC_IP>:2020

# 5. Tear down once done
cd ../terraform
terraform destroy -var="key_name=<your-key-pair>" -var="name_prefix=<your-name>"
```

See `documentation/DOCUMENTATION.md` for the detailed step-by-step, the issues
encountered during this run, and how each was resolved.

# Task 17 — Ansible and AWS EC2 Deployment (Twenty CRM)

Terraform provisions a single EC2 instance; Ansible configures it and deploys
Twenty CRM via Docker Compose. Full write-up is in `Documentation/Document 6.pdf`.

## Folder structure

```
.
├── README.md
├── .gitignore
├── terraform files/
│   ├── main.tf              - default VPC/subnet lookup, security group, EC2 instance
│   ├── variables.tf         - region, instance type, AMI, key pair, name_prefix, etc.
│   └── outputs.tf           - public IP / DNS / instance ID after apply
├── ansible files/
│   ├── ansible.cfg          - points at inventory.ini and the SSH key
│   ├── inventory.ini        - target host (EC2 public IP)
│   ├── playbook.yml         - full deployment playbook
│   └── templates/
│       └── env.j2           - template for the app's .env file
├── Documentation/
│   └── Document 6.pdf       - architecture, step-by-step, issues hit and fixes
└── screenshots/
    ├── terraform apply.png
    ├── playbook.png
    └── ui.png
```

## Quick start

```bash
# 1. Provision infrastructure
cd "terraform files"
terraform init
terraform apply -var="key_name=<your-key-pair>" -var="name_prefix=<your-name>"

# 2. Point Ansible at the new instance
#    edit "../ansible files/inventory.ini" -> replace REPLACE_WITH_EC2_PUBLIC_IP
#    with the ec2_public_ip Terraform just printed

# 3. Deploy
cd "../ansible files"
ansible twenty_crm -m ping
ansible-playbook playbook.yml

# 4. Open the app
#    http://<EC2_PUBLIC_IP>:2020

# 5. Tear down once done
cd "../terraform files"
terraform destroy -var="key_name=<your-key-pair>" -var="name_prefix=<your-name>"
```

See `Documentation/Document 6.pdf` for the detailed step-by-step, the issues
encountered during this run, and how each was resolved.

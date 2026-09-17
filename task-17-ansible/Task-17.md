# Task 17 – Ansible and AWS EC2 Deployment

## Objective

Deploy Twenty CRM on an AWS EC2 instance using Terraform and configure the instance using Ansible.

## Terraform Configuration

- Region: us-east-1
- Instance type: t3.small
- AMI: ami-0b6d9d3d33ba97d99
- Default VPC
- Default VPC subnet
- Root volume: 20 GiB gp3
- Security group:
    - SSH: 22
    - Twenty CRM: 2020

Terraform was used to provision the EC2 instance and output its public IP address.

## Ansible Configuration

Ansible was used to:

1. Update system packages
2. Upgrade installed packages
3. Install Docker
4. Start and enable Docker
5. Install required Docker dependencies
6. Create the Twenty CRM application directory
7. Configure Twenty CRM environment variables
8. Pull the Twenty CRM Docker image
9. Deploy the Twenty CRM container
10. Configure Docker restart policy
11. Configure Docker health check
12. Verify the container status
13. Verify application availability
14. Display application logs

## Docker Configuration

Twenty CRM was deployed using:

- Image: `twentycrm/twenty-app-dev:latest`
- Container name: `twenty-crm`
- Port: `2020:2020`
- Restart policy: `unless-stopped`
- Docker health check configured for port 2020

## Application Verification

The Twenty CRM application was verified using:

```bash
curl -I http://localhost:2020
```

The application returned:
```
HTTP/1.1 200 OK
```

Docker container status, restart policy, health check configuration, and application logs were also verified.

## Ansible Execution Result

The final Ansible playbook completed successfully:
```
PLAY RECAP
twenty-crm : ok=16 changed=15 unreachable=0 failed=0 skipped=0
```

## Conclusion

Twenty CRM was successfully provisioned on AWS EC2 using Terraform and configured and deployed using Ansible and Docker. Application availability and Docker configuration were verified successfully.

### Thank you!
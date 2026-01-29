# Runbook

This document describes how to safely run, apply, and destroy the infrastructure
and configuration in this project.

## Prerequisites

- AWS account with credentials configured
- Terraform installed
- Ansible installed
- SSH key pair available

## Execution order (important)

Infrastructure must exist before configuration.

````
1. Terraform provisions EC2
2. Ansible configures EC2
````

## Terraform usage

From the `terraform/` directory:

```bash
terraform init
terraform validate
terraform plan
terraform apply
````

Terraform outputs are later used to populate the Ansible inventory.

## Ansible usage

From the project root:

```bash
ansible-inventory -i ansible/inventory.ini --list
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

Ansible connects to EC2 using SSH with the key pair created by Terraform.

## SSH model

- Ansible runs locally (control node)
- EC2 instances are managed nodes
- Authentication is key-based
- Port 22 must be allowed by the security group

## Teardown

To destroy all infrastructure:

```bash
terraform destroy
```

Always destroy resources when finished to avoid unnecessary cloud costs.

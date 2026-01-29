# Architecture

This project provisions and configures a sandbox virtual machine on AWS using
Terraform and Ansible.

The design follows industry-standard separation of concerns:

- Terraform handles infrastructure provisioning
- Ansible handles server configuration
- (Optional) Jenkins orchestrates execution in CI

## High-level system flow 

```
Data / control flow

Local machine or CI
|
| terraform apply
v
AWS Infrastructure
(VPC, Subnet, Security Group, EC2)
|
| ansible-playbook (SSH)
v
Configured EC2 Instance VM
```

## Tool responsibilities

### Terraform (Provisioning layer)

- Creates AWS resources (networking + EC2)
- Manages infrastructure state
- Outputs connection details (e.g., public IP)

Terraform is responsible for **existence** of resources.

### Ansible (Configuration layer)

- Runs from a control node (local machine or CI)
- Connects to EC2 instances over SSH
- Applies idempotent configuration steps

No agent is installed on the EC2 instance.

```
Ansible (control node)
|
| SSH (key-based auth, port 22)
v
EC2 instance (managed node)
```

Ansible is responsible for **state of the server**.

### Jenkins (optional extension)

- Automates the same Terraform and Ansible commands
- Adds validation, approval gates, and repeatability
- Does not replace Terraform or Ansible

```
Git push
|
v
Jenkins Pipeline
|
| terraform plan / apply
| ansible-playbook
v
AWS + EC2
```

## Design principles

- Clear separation between infra and config
- SSH-based, agentless configuration
- Reproducible and automation-ready

## State management (Terraform)

Terraform manages infrastructure state separately from configuration logic.

During development, local state is used to validate the infrastructure model.
Once stable, state can be migrated to a remote backend for collaboration and safety.

```
terraform/
|
| terraform.tfstate (local or remote)
v
Terraform state
```

In production-style setups, remote state is typically stored in:
- Amazon S3 (state storage)
- DynamoDB (state locking)

This prevents concurrent modifications and enables safe team workflows.

## Security model

- No long-lived credentials are hardcoded
- SSH access uses key-based authentication
- Network access is restricted via security groups
- Configuration is applied over encrypted SSH transport

```
Ansible
|
| SSH (encrypted, key-based)
v
EC2 VM
```

## Execution environments

This project supports two execution contexts:

1) **Local execution**
   - Terraform and Ansible run from a developer machine
   - Used for learning, validation, and iteration

2) **CI execution (optional)**
   - Jenkins runs the same Terraform and Ansible commands
   - Adds validation, approvals, and repeatability

Both environments follow the same architecture and execution order.

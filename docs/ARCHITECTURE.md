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

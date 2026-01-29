# InfraPro — Terraform + Ansible (AWS Sandbox VM)

This project provisions an AWS sandbox VM with Terraform and configures it with Ansible.

## Repo Structure

- `terraform/` — AWS infrastructure provisioning
- `ansible/` — VM configuration via Ansible
- `docs/` — architecture + runbook

## Workflow (high level)

1) Terraform provisions infra (VPC + EC2)
2) Ansible configures the EC2 instance
3) (Extension) Jenkins orchestrates plan/apply + ansible-playbook

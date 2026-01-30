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

## Verification Evidence

To demonstrate successful execution and correctness of the infrastructure and configuration workflow, verification artifacts have been captured from real runs.

### Included Evidence

The following outputs were generated directly from live executions:

* **Terraform**

  * `terraform plan` output
  * `terraform apply` output

* **Ansible**

  * Initial failing runs (for troubleshooting context)
  * Final successful `site.yml` execution
  * Clean `ansible-playbook` output confirming idempotent configuration

### Evidence Location

All verification artifacts are provided **separately** in a zipped directory:

```
infrapro-screenshots/
```

This directory contains:

* Terminal output files (`.txt`)
* Screenshots where applicable
* Final successful Ansible run confirmation

> These artifacts are intentionally separated from the repository to keep the codebase clean while still providing full execution proof for reviewers.

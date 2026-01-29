# Architecture

## Data / control flow

```
Local or CI
|
| terraform apply
v
AWS: VPC/Subnet/SG/EC2
|
| ansible-playbook
v
Configured EC2 VM
```

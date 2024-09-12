# Ansible Elastic

Ansible Elastic repository contains roles, playbooks, and configurations to automate Elastic-related tasks using Ansible.

## Prerequisites

- Ansible 2.9 or higher
- Python 3.8 or higher
- Hashicorp Packer 

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/tamal-pension/ansible-elastic.git
   cd ansible-api

## Command to run goldenimage.pkr.hcl locally

```bash
curl -O https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/default/packer/goldenimage.pkr.hcl && packer build --only=amazon-ebs.amzn2_x86 -var cpu_arch=x86 -var 'verbose=true' -var 'aws_profile=<profile>' -var 'tag=<tag>' -var app=<app name> -var 'aws_region=<region>' -var 'base_path=<s3 playbooks base path>' goldenimage.pkr.hcl
```

## fast and easy way to create launch template
a script that create launch templates:

```bash
curl -O https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/master/create_template.sh && bash create_template.sh --template-name <template name> --region <region> --profile <profile>
```

# Terraform infrastructure for Munch Catering

This repository contains a modular Terraform implementation for a small AWS-based infrastructure stack used to host the Munch Catering application on an EC2 instance with secure access patterns. The project was built while learning Terraform and AWS, and it is now being used as a portfolio example that complements the Munch Catering application. It is intended as a hands-on learning project and a practical DevOps showcase rather than a production baseline.

## What this project demonstrates

- Terraform module structure with separate environment and reusable modules
- AWS networking, IAM, EC2, SSM, security group, and CloudWatch configuration
- Safe-by-default deployment behavior through a dry-run switch
- Secure access patterns using AWS Systems Manager Session Manager instead of public SSH by default
- GitHub Actions workflows for validation and manual apply

## Architecture at a glance

The environment creates a custom VPC, one public subnet, one private subnet, an EC2 instance, an IAM role/profile, security groups, optional CloudWatch logging, and SSM parameters for runtime configuration.

![Munch Catering AWS architecture](docs/architecture_diagram.png)

The diagram is a simplified view of the Terraform topology and uses CIDR ranges for the network layout rather than actual host addresses.

## Repository structure

- `environments/dev/main.tf` — wires the environment together and calls each module
- `environments/dev/variables.tf` — defines inputs, defaults, and validation rules
- `environments/dev/backend.tf` — contains an example remote state backend block
- `environments/dev/terraform.tfvars.example` — example values for local configuration
- `modules/network` — VPC, subnets, route tables, internet gateway, and optional NAT gateway
- `modules/security` — security groups, ingress/egress rules, and optional KMS key
- `modules/ec2` — EC2 instance and bootstrap user data
- `modules/iam` — IAM role, instance profile, and scoped policies
- `modules/ssm` — SSM parameters for app configuration
- `modules/monitoring` — CloudWatch log group for optional logging

## What each Terraform layer does

### 1. Environment layer

The dev environment file is the entry point. It defines the AWS provider, common tags, and module calls. The main decisions made here are:

- whether resources are created at all (`dry_run_mode`)
- the naming prefix for resources
- which modules should be enabled based on flags such as SSM, CloudWatch, and public access

### 2. Networking module

The networking module creates:

- a custom VPC with DNS support enabled
- a public subnet and a private subnet
- an internet gateway
- route tables for public and private traffic
- an optional NAT gateway for outbound internet access from private resources

This is the foundation for a simple AWS-hosted application environment.

### 3. Security module

The security module creates a security group for the EC2 instance and controls access through rules. By default:

- SSH is disabled unless explicitly enabled
- application ports are closed unless you deliberately open them
- egress is allowed on HTTP, HTTPS, and DNS so the instance can install packages and reach AWS services
- an optional customer-managed KMS key can be created for EBS encryption

### 4. EC2 module

The EC2 module provisions an Ubuntu-based instance and uses user data to bootstrap the host. In practice, the bootstrap script:

- updates the system
- installs Docker, Docker Compose, Git, AWS CLI, and supporting packages
- creates a dedicated application directory
- writes a runtime environment file for the application
- configures Docker logging
- optionally installs the CloudWatch agent

This is the most operational part of the stack because it turns a plain EC2 instance into a usable application host.

### 5. IAM module

The IAM module creates an instance role for the EC2 host and attaches policies that allow:

- EC2 to assume the role
- SSM Session Manager access
- read-only access to the application-specific SSM parameter paths
- optional CloudWatch agent access

The permissions are intentionally narrow and scoped to the application path used by the deployment.

### 6. SSM module

The SSM module creates parameters used to store non-secret runtime values such as the application directory path. It is designed to keep configuration outside of Terraform state and outside the repository.

### 7. Monitoring module

The monitoring module creates a CloudWatch log group for host/application logs when the feature is enabled.

## Prerequisites

You will need:

- Terraform 1.6.x or newer
- AWS CLI configured locally or an AWS role that can be assumed by your environment
- permission to create basic networking, EC2, IAM, SSM, and CloudWatch resources
- an S3 bucket and DynamoDB lock table if you want to use remote state

## Local deployment workflow

1. Change into the environment directory:

```bash
cd infra/terraform/environments/dev
```

2. Create a local variable file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Review the values in `terraform.tfvars`. The default configuration keeps resources disabled until you deliberately switch `dry_run_mode` to `false`.

4. Initialize Terraform:

```bash
terraform init -backend=false
```

5. Review the plan:

```bash
terraform plan -out=plan.out
```

6. Apply the plan when you are ready:

```bash
terraform apply plan.out
```

## Why this setup looks the way it does

I kept this Terraform project deliberately simple because the goal was to learn the core of AWS and Terraform without turning the first version into a large production platform. The design choices below reflect that intent.

## Why I switched to a remote backend

As the project grew to resemble a real-world infrastructure deployment, I wanted the Terraform workflow to reflect that as well. I also wanted to understand how remote backends work in practice rather than just reading about them.

Terraform state is stored remotely in an Amazon S3 bucket, allowing both local development and GitHub Actions to work from the same source of truth. This avoids state drift, makes collaboration safer, and provides a more production-like workflow.

Before running Terraform for the first time, ensure you have access to the configured backend bucket and initialize the working directory:

```bash
terraform init
```

### Why I chose Session Manager over public SSH

The default configuration is set up around AWS Systems Manager Session Manager rather than opening SSH broadly. That was a conscious choice because it keeps access more controlled and avoids exposing the instance to the internet unless it is really needed. In practice, this makes the environment feel more like a real AWS deployment than a quick lab setup.

### Why the defaults are conservative

The instance size, storage, and network settings are kept modest on purpose. This keeps the project affordable while learning, and it also makes the Terraform plan easier to reason about. The trade-off is that this is not a production-grade architecture yet; it is a safe baseline for learning and iteration.

### Why the project is still useful for GitHub

Even though this is not a full production platform, it is still a useful repository to keep because it shows that I can take a real application idea and connect it to infrastructure, IAM, networking, and deployment automation.

## How I would use it in practice

If I were using this repository for a real deployment, I would approach it in this order:

1. keep the local Terraform setup for learning and testing
2. switch to remote state once the project is shared or used by more than one person
3. use AWS credentials through a named profile or SSO profile
4. keep secrets out of the repository and use SSM or Secrets Manager for application values
5. use the GitHub Actions workflow as a validation path before any change is applied to AWS







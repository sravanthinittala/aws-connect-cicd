# AWS CONNECT CI/CD

This project aims to use Terraform and GitHub Actions to provision and deploy basic infrastructure for a contact center using AWS Connect.

## How to Run

We must initally setup an S3 bucket on AWS for the Terraform state and a DynamoDB table for state-lock. In this project, both these resources were created manually using AWS console.

### Setup

Run the `bootstrap/` scripts first to create OIDC roles. Ensure that `export TF_VAR_aws_account_id=<your-aws-account-id>` is set before running `iam.tf`

To run the bootstrap script, run the following commands:

```
cd ./bootstrap
terraform init #First time
terraform apply
```
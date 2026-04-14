terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.2"

  backend "s3" {
    bucket       = "connect-iac"
    key          = "connect/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
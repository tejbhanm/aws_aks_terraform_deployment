# versions.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "tejbhan-tf-state-123456789012"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

# Add it here:
provider "aws" {
  region = "ap-south-1"             # Cluster / VPC deployment region
}
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16.0"
    }
  }

  # Supply bucket, key, region, encryption, and locking settings per environment.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

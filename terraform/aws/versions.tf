terraform {
  backend "s3" {}
}
provider "aws" {
  region = "ap-southeast-2"
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "<= 6.16.0"
    }
  }
}

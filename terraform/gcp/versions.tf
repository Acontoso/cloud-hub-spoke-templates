terraform {
  required_version = ">= 1.10.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0, < 7.0"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project
  region  = var.region
}

# Required by terraform-google-modules/network/google v18, which creates the
# VPC networks with the google-beta provider.
provider "google-beta" {
  project = var.project
  region  = var.region
}

terraform {
  backend "gcs" {}
}

provider "google" {
  project = ""
  region  = ""
}

data "google_project" "project" {}

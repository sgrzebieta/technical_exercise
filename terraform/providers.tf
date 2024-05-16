terraform {
  required_version = ">= 1.8.3"

  backend "gcs" {
    bucket = "tf-state-867675"
    prefix = "terraform/state/wiz_tc"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.28.0"
    }
  }
}
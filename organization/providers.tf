terraform {
  required_version = ">= 1.8.3"

  backend "gcs" {
    bucket = "tf-state-1972356"
    prefix = "terraform/state/folders-and-policies"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.28.0"
    }
  }
}
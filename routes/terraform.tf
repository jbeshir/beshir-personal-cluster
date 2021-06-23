terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}
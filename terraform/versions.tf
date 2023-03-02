terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.0.16"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
  required_version = ">= 1.0.0"
}
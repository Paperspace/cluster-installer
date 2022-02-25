terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.27.0"
    }
    paperspace = {
      source  = "Paperspace/paperspace"
      version = "0.4.3"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.17.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.5.0"
    }
  }
}
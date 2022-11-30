variable "host" {
  description = "Service name, what this resource will appear as in the cluster"
  type        = string
}

variable "cluster_domain" {
  type        = string
  description = "The domain name of the cluster"
}

variable "ip_addresses" {
  type        = list(string)
  description = "IP addresses external to the kubernetes cluster to associate with the ingress"
}

variable "http_port" {
  type        = number
  description = "The port to use for http traffic on ip_addresses"
}

variable "namespace" {
  type        = string
  description = "The k8s namespace to deploy the ingress into"
  default     = "default"
}

locals {
  fqdn = "${var.host}.${var.cluster_domain}"
}

resource "kubernetes_endpoints" "endpoints" {
  metadata {
    name      = var.host
    namespace = var.namespace
  }

  subset {
    dynamic "address" {
      for_each = var.ip_addresses
      content {
        ip = each.value
      }
    }

    port {
      name     = "http"
      port     = var.http_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = var.host
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "http"
      port        = 80
      target_port = var.http_port
    }
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name      = var.host
    namespace = var.namespace
  }

  spec {
    rule {
      host = local.fqdn
      http {
        path {
          path = "/"
          backend {
            service_name = var.host
            service_port = 80
          }
        }
      }
    }
  }
}

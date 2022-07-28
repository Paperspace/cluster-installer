resource "random_string" "ha_shared_secret" {
  length  = 12
  special = true
  upper   = true
}

resource "kubernetes_namespace" "docker_registry" {
  metadata {
    name = "docker-registry"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "helm_release" "docker_mirror" {
  depends_on = [helm_release.cert_manager]
  name       = "docker-registry-mirror"
  version    = "1.10.3"
  repository = "https://t83714.github.io/docker-registry-mirror"
  chart      = "docker-registry-mirror"
  namespace  = kubernetes_namespace.docker_registry.metadata[0].name

  values = [
    templatefile("${path.module}/files/docker-registry-mirror.yaml.tpl", {
      fullname        = var.service_name
      hostname        = var.hostname
      replica_count   = var.replica_count
      docker_username = var.docker_registry_mirror_docker_username
      docker_password = var.docker_registry_mirror_docker_password

      ha_shared_secret = random_string.ha_shared_secret.result

      s3  = var.docker_registry_s3_storage
      pvc = var.docker_registry_pvc_storage
    })
  ]
}

resource "kubernetes_ingress" "docker_registry_mirror_debug" {
  metadata {
    name      = "${local.docker_registry_mirror_name}-debug"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/auth-type" : "basic"
      "nginx.ingress.kubernetes.io/auth-secret" : kubernetes_secret.docker_registry_mirror_debug_auth.metadata[0].name
      "nginx.ingress.kubernetes.io/force-ssl-redirect" : "false"
    }
  }
  spec {
    rule {
      host = local.docker_registry_mirror_hostname
      http {
        path {
          path = "/metrics"
          backend {
            service_name = kubernetes_service.docker_registry_mirror_debug.metadata[0].name
            service_port = kubernetes_service.docker_registry_mirror_debug.spec[0].port[0].port
          }
        }
      }
    }
  }
}

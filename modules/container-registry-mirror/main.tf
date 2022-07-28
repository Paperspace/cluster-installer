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
      docker_username = var.docker_hub_username
      docker_password = var.docker_hub_password

      ha_shared_secret = random_string.ha_shared_secret.result

      storage = var.s3_storage != null ? "s3" : "filesystem"
      s3      = var.s3_storage
      pvc     = var.pvc_storage
    })
  ]
}

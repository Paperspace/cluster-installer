resource "helm_release" "cloud_controller_manager" {
  name                = "cloud-controller-manager"
  repository          = var.helm_repo_url
  repository_username = var.helm_repo_username
  repository_password = var.helm_repo_password
  chart               = "paperspace-cloud-controller-manager"
  version             = var.chart_version

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "paperspace.baseURL"
    value = var.paperspace_base_url
  }

  set_sensitive {
    name  = "paperspace.apiKey"
    value = var.cluster_apikey
  }
}

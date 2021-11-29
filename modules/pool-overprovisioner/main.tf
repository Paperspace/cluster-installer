resource "helm_release" "pool-overprovisioner" {
  name                = "pool-overprovisioner"
  repository          = var.helm_repo_url
  repository_username = var.helm_repo_username
  repository_password = var.helm_repo_password
  chart               = "pool-overprovisioner"
  version             = var.chart_version
  set {
    name  = "poolOverprovisions"
    value = yamlencode(tomap(var.pool_overprovisions))
  }
}

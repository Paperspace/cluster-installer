resource "helm_release" "descheduler" {
  name       = "descheduler"
  version    = var.chart_version
  repository = "https://kubernetes-sigs.github.io/descheduler"
  chart      = "descheduler"

  values = [
    templatefile("${path.module}/files/descheduler.yaml.tpl", {
    })
  ]
}

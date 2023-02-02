resource "helm_release" "descheduler" {
  name       = "descheduler"
  version    = "0.26.0"
  repository = "https://kubernetes-sigs.github.io/descheduler"
  chart      = "descheduler"

  values = [
    templatefile("${path.module}/files/descheduler.yaml.tpl", {
    })
  ]
}

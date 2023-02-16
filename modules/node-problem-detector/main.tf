resource "kubernetes_config_map" "extra_plugins" {
  metadata {
    name      = "node-problem-detector-extra-plugins"
    namespace = "kube-system"
  }

  data = var.custom_plugin_scripts
}

resource "helm_release" "node_problem_detector" {
  name       = "node-problem-detector"
  repository = "https://charts.deliveryhero.io/"
  chart      = "node-problem-detector"
  version    = var.node_problem_detector_version
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/templates/values.json.tpl", {
      image          = var.image
      custom_plugins = [for name in keys(var.custom_plugin_configs) : "/custom-config/${name}"]
      plugin_configs = { for name, config in var.custom_plugin_configs : name => jsonencode(config) }
      extra_volume_mounts = concat([
        {
          name      = "extra-plugin-bin"
          mountPath = "/custom-plugin/bin"
          readOnly  = true
        },
      ], var.extra_volume_mounts)
      extra_volumes = concat([
        {
          name = "extra-plugin-bin"
          configMap = {
            name        = kubernetes_config_map.extra_plugins.metadata[0].name
            defaultMode = 493 # octal 755
          }
        },
      ], var.extra_volumes)
    })
  ]
}

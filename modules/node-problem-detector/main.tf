locals {
  namespace = "kube-system"
  common_labels = {
    "app.kubernetes.io/name"       = "node-problem-detector"
    "app.kubernetes.io/managed-by" = "terraform"
  }

  draino_labels = merge({
    "app.kubernetes.io/instance" = "draino"
  }, local.common_labels)
}

resource "kubernetes_config_map" "extra_plugins" {
  metadata {
    name      = "node-problem-detector-extra-plugins"
    namespace = local.namespace
    labels    = local.common_labels
  }

  data = var.custom_plugin_scripts
}


resource "helm_release" "node_problem_detector" {
  name       = "node-problem-detector"
  repository = "https://charts.deliveryhero.io/"
  chart      = "node-problem-detector"
  version    = var.node_problem_detector_helm_version
  namespace  = local.namespace

  values = [
    templatefile("${path.module}/templates/values.json.tpl", {
      image          = var.node_problem_detector_image
      custom_plugins = [for name in keys(var.custom_plugin_configs) : "/custom-config/${name}"]
      plugin_configs = { for name, config in var.custom_plugin_configs : name => jsonencode(config) }
      extra_volume_mounts = concat([
        {
          name      = "extra-plugin-bin"
          mountPath = "/custom-plugin/bin"
          readOnly  = true
        },
      ], var.node_problem_detector_extra_volume_mounts)
      extra_volumes = concat([
        {
          name = "extra-plugin-bin"
          configMap = {
            name        = kubernetes_config_map.extra_plugins.metadata[0].name
            defaultMode = 493 # octal 755
          }
        },
      ], var.node_problem_detector_extra_volumes)
    })
  ]
}

resource "kubernetes_service_account" "draino" {
  metadata {
    name      = "draino"
    namespace = local.namespace
    labels    = local.draino_labels
  }
}

resource "kubernetes_cluster_role" "draino_rbac" {
  metadata {
    name   = "draino"
    labels = local.draino_labels
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/status"]
    verbs      = ["patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["statefulsets"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get", "create", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "draino_rbac" {
  metadata {
    name   = "draino"
    labels = local.draino_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.draino_rbac.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.draino.metadata[0].name
    namespace = local.namespace
  }
}


locals {
  node_problem_detector_default_conditions = [
    "KernelDeadlock", "ReadonlyFilesystem", "FrequentKubeletRestart", "FrequentDockerRestart", "FrequentContainerdRestart",
    "KubeletUnhealthy", "ContainerRuntimeUnhealthy", "CorruptDockerOverlay2"
  ]

  draino_flags = flatten([
    for flag, value in var.draino_flags : value == null ? [] : [
      "--${replace(flag, "_", "-")}=${value}"
    ]
  ])

  custom_conditions = flatten([
    for name, config in var.custom_plugin_configs : [
      for condition in config.conditions : condition.type
    ]
  ])

  draino_command = concat(
    "/draino",
    local.draino_flags,
    "--namespace=${local.namespace}",
    local.node_problem_detector_default_conditions,
    local.custom_conditions
  )
}

resource "kubernetes_deployment" "draino" {
  metadata {
    name      = "draino"
    namespace = local.namespace
    labels    = local.draino_labels
  }

  spec {
    replicas = var.draino_replicas

    selector {
      match_labels = local.draino_labels
    }

    template {
      metadata {
        labels = local.draino_labels
      }
      spec {
        container {
          name    = "draino"
          image   = var.draino_image
          command = local.draino_command

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 10002
            }
            initial_delay_seconds = 30
          }

          security_context {
            privileged                = false
            read_only_root_filesystem = true
          }

          resources {
            limits   = var.draino_resources.limits
            requests = var.draino_resources.requests
          }
        }

        service_account_name = kubernetes_service_account.draino.metadata[0].name
        security_context {
          fs_group        = 101
          run_as_group    = 101
          run_as_non_root = true
          run_as_user     = 100
        }

        node_selector = var.draino_node_selector
      }
    }
  }
}

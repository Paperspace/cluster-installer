variable "custom_plugin_configs" {
  type = map(
    object({
      plugin = optional(string, "custom")
      pluginConfig = optional(object({
        invoke_interval                              = optional(string) // how frequently to check this plugin
        timeout                                      = optional(string) // default rule timeout
        max_output_length                            = optional(number) // the stdout of the script will be truncated to this length
        concurrency                                  = optional(number) // concurrency of all rule runs
        enable_message_change_based_condition_update = optional(bool)   // change the condition if the message changes
        skip_initial_status                          = optional(bool)   // don't report anything unitl the check first ran
      }), {})
      source           = string         // name to report in the node status
      metricsReporting = optional(bool) // report to prometheus
      conditions = list(                // This is the list of conditions that will be reported to the node status in kubelet
        object({
          type    = string           // This is the name that will appear in kubelet
          status  = optional(string) // Default state before the plugin runs
          reason  = optional(string) // Reason supplied before the plugin runs or if the plugin is successful
          message = optional(string) // Message supplied before the plugin runs or if the plugin is successful
        })
      )
      rules = list( // Ways to check status of the conditions for this plugin
        object({
          type      = string                     // permitted values: "temporary", "permanent". "temporary" is reported as a node event only, "permanent" is reported as a node condition
          condition = string                     // match the type of the condition in the conditions list, this is the condition that will be updated on kublet
          reason    = string                     // reason to report if the script fails
          path      = string                     // path to the script to run
          args      = optional(list(string), []) // arguments for the script
          timeout   = optional(string)           // per rule timeout override
        })
      )
    })
  )
  description = "Custom plugin monitor definitions"
  default     = {}
}

variable "custom_plugin_scripts" {
  type        = map(string)
  description = "Custom plugin monitor scripts. These are mounted in /custom-plugin/bin"
  default     = {}
}

variable "custom_plugin_binaries" {
  type        = map(string)
  description = "Custom plugin monitor binaries. These are mounted in /custom-plugin/bin. Strings must be base64 encoded."
  default     = {}
}

variable "extra_volumes" {
  type = list(object({
    name = string
    hostPath = optional(object({
      path = string
      type = optional(string)
    }))
    configMap = optional(object({
      name        = string
      defaultMode = optional(number)
    }))
    persistentVolumeClaim = optional(object({
      claimName = string
    }))
  }))
  description = "Extra volumes to mount in the node-problem-detector pod"
  default     = []
}

variable "extra_volume_mounts" {
  type = list(object({
    name      = string
    mountPath = string
    readOnly  = optional(bool)
  }))
  description = "Extra volume mounts to mount in the node-problem-detector pod"
  default     = []
}

resource "kubernetes_config_map" "extra_plugins" {
  metadata {
    name      = "node-problem-detector-extra-plugins"
    namespace = "kube-system"
  }

  data        = var.custom_plugin_scripts
  binary_data = var.custom_plugin_binaries
}

resource "helm_release" "node_problem_detector" {
  name       = "node-problem-detector"
  repository = "https://charts.deliveryhero.io/"
  chart      = "node-problem-detector"
  version    = var.node_problem_detector_version
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/templates/values.json.tpl", {
      custom_plugins = [for name in keys(var.custom_plugin_configs) : "/custom-config/${name}"]
      plugin_configs = { for name, config in var.custom_plugin_configs : name => jsonencode(config) }
    })
  ]

  set {
    name = "extraVolumeMounts"
    value = jsonencode(concat([
      {
        name      = "extra-plugin-bin"
        mountPath = "/custom-plugin/bin"
        readOnly  = true
      },
    ], var.extra_volume_mounts))
  }

  set {
    name = "extraVolumes"
    value = jsonencode(concat([
      {
        name = "extra-plugin-bin"
        configMap = {
          name        = kubernetes_config_map.extra_plugins.metadata[0].name
          defaultMode = 0777
        }
      },
    ], var.extra_volumes))
  }
}

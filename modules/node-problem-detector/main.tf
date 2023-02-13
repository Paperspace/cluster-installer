variable "custom_plugins" {
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

resource "helm_release" "node_problem_detector" {
  name       = "node-problem-detector"
  repository = "https://charts.deliveryhero.io/"
  chart      = "node-problem-detector"
  version    = var.node_problem_detector_version
  namespace  = "kube-system"

  dynamic "set" {
    for_each = var.custom_plugins

    content {
      name  = "settings.custom_monitor_definitions.${set.key}"
      value = jsonencode(set.value)
    }
  }

  set {
    name  = "settings.custom_plugin_monitors"
    value = jsonencode(keys(var.custom_plugins))
  }
}

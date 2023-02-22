variable "node_problem_detector_helm_version" {
  type        = string
  description = "Version of the node-problem-detector chart to install"
  default     = "2.3.3"
}

variable "node_problem_detector_image" {
  type = object({
    repository = optional(string)
    tag        = optional(string)
  })
  description = "Image to use for the node-problem-detector, must supply both repository and tag or neither"
  default     = {}
}

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

variable "node_problem_detector_extra_volumes" {
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

variable "node_problem_detector_extra_volume_mounts" {
  type = list(object({
    name      = string
    mountPath = string
    readOnly  = optional(bool)
  }))
  description = "Extra volume mounts to mount in the node-problem-detector pod"
  default     = []
}

variable "draino_flags" {
  type = object({
    dry_run                  = optional(string)
    max_grace_period         = optional(string)
    eviction_headroom        = optional(string)
    drain_buffer             = optional(string)
    node_label_expr          = optional(string)
    skip_drain               = optional(bool)
    evict_daemonset_pods     = optional(bool)
    evict_emptydir_pods      = optional(bool)
    evict_unreplicated_pods  = optional(bool)
    protected_pod_annotation = optional(bool)
  })
  description = "Flags to pass to draino. If unset the flag is ommited and upstream defaults are used https://github.com/planetlabs/draino"
  default     = {}
}

variable "draino_node_selector" {
  type        = map(string)
  description = "Node selector for draino"
  default     = {}
}

variable "draino_replicas" {
  type        = number
  description = "Number of draino replicas to run"
  default     = 1
}


variable "draino_resources" {
  type = object({
    requests = optional(object({
      cpu    = optional(string, "100m")
      memory = optional(string, "128Mi")
    }))
    limits = optional(object({
      cpu    = optional(string, "100m")
      memory = optional(string, "128Mi")
    }))
  })
  description = "Resources to request for draino"
  default     = {}
}

variable "draino_image" {
  type        = string
  description = "Image to use for the draino"
  default     = "planetlabs/draino:e0d5277"
}

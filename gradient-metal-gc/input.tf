variable "cluster_autoscaler_autoscaling_groups" {
  type        = list(any)
  description = "Cluster autoscaler autoscaling groups"
  default     = []
}

variable "cluster_autoscaler_cloudprovider" {
  description = "Cluster autoscaler cloud provider"
  default     = ""
}

variable "cluster_autoscaler_enabled" {
  description = "Cluster autoscaler enabled"
  default     = false
}

/*
  k8s_master_node schema:
    {
        "ip": {{ ip address }},
        "pool-name": "{{ host }}",
        "pool-type": "{{ pool type name }}"
    }
*/


/*
  k8s_workers schema
  ["ipv4 address worker a", "ipv4 address worker b"]
*/

variable "k8s_workers" {
  type        = list(any)
  description = "Kubernetes workers"
}

variable "ssh_key" {
  description = "Private SSH key"
  default     = ""
}

variable "ssh_key_path" {
  description = "Private SSH key file path"
  default     = ""
}

variable "ssh_user" {
  description = "SSH user"
  default     = "upaperspace"
}

variable "cpu_selector" {
  description = "Node CPU selector"
  default     = "ipu-host"
}

variable "gpu_selector" {
  description = "Node GPU selector"
  default     = "metal-gpu"
}

variable "service_pool_name" {
  description = "Service node selector"
  default     = "services-small"
}

variable "use_pod_anti_affinity" {
  description = "Use pod anti-affinity"
  default     = false
}

variable "api_host" {
  description = "api host"
  default     = "https://staging-api.paperspace.io"
}

variable "paperspace_api_next_url" {
  description = "Paperspace API next URL"
  default     = "https://staging-api.paperspace.com"
}
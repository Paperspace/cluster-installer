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
  default     = "https://api.paperspace.io"
}

variable "paperspace_api_next_url" {
  description = "Paperspace API next URL"
  default     = "https://api.paperspace.com"
}

variable "ipu_controller_server" {
  description = "IPU Controller Server Hostname"
  type        = string
  default     = ""
}

variable "ipu_model_cache_pvc_name" {
  description = "PVC containing precompiled models for IPU hosts"
  type        = string
  default     = ""
}

variable "ipuof_vipu_api_host" {
  description = "Sets the IPUOF_VIPU_API_HOST for ipu configuration"
  type        = string
  default     = "localhost"
}

variable "ipuof_vipu_api_port" {
  description = "Sets the IPUOF_VIPU_API_PORT for ipu configuration"
  type        = number
  default     = 8090
}

variable "victoria_metrics_prometheus_node_exporter_host_port" {
  description = "Victoria Metrics Prometheus Node Exporter"
  type        = number
  default     = 9105
}

variable "prometheus_pool_name" {
  description = "Victoria Metrics Kubernetes Node Selector Identifier"
  type        = string
  default     = "metrics"
}

variable "rbd_storage_config" {
  description = "Local storage config json"
  default     = ""
}

variable "notebook_volume_type" {
  description = "Flag to indicate which volume type notebooks are using"
  type        = string
  default     = "disk-image"
}

variable "is_tls_config_from_file" {
  description = "Are the variables tls_cert and tls_key files and not strings"
  type        = bool
  default     = true
}

variable "docker_hub_username" {
  description = "Username for docker hub. Must be associated with a paid account"
  type        = string
}

variable "docker_hub_password" {
  description = "Password for docker hub"
  type        = string
}

variable "registry_pool_name" {
  description = "What node pool to run the docker registry mirror on"
  type        = string
  default     = ""
}

variable "external_s3_ip_addresses" {
  description = "IP addresses for S3 datacenter local s3 service"
  type        = list(string)
  default     = []
}

variable "external_s3_port" {
  description = "Port for http access to a datacenter local s3 service"
  type        = number
}

variable "metrics_storage_class" {
  description = "Name of the storage class for the metrics server"
  type        = string
  default     = "gradient-processing-shared"
}

variable "victoria_metrics_vmcluster_vmstorage_replicacount" {
  description = "How many vmstorage replicas do you want running?"
  type        = number
  default     = 3
}

variable "lb_count" {
  description = "How many load balancer nodes are available"
  type        = number
  default     = 2
}

variable "enable_cephbackup_job" {
  description = "Backup the disk to the pure storage volume"
  type        = bool
  default     = true
}

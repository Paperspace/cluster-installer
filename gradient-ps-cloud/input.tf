variable "admin_email" {
  description = "Paperspace admin API email"
}

variable "admin_user_api_key" {
  description = "Paperspace admin API key"
}

variable "api_host" {
  description = "api host"
  default     = "https://api.paperspace.io"
}

variable "asg_max_sizes" {
  description = "Autoscaling Group max sizes"
  default     = {}
}

variable "asg_min_sizes" {
  description = "Autoscaling Group min sizes"
  default     = {}
}

variable "aws_access_key_id" {
  description = "AWS access key id"
  default     = ""
}
variable "aws_secret_access_key" {
  description = "AWS secret access key"
  default     = ""
}

variable "cloudflare_api_key" {
  description = "Cloudflare API key"
  default     = ""
}
variable "cloudflare_email" {
  description = "Cloudflare email"
  default     = ""
}
variable "cloudflare_zone_id" {
  description = "Cloudflare zone id"
  default     = ""
}

variable "kind" {
  description = "Kind of cluster"
  default     = "singlenode"
}

variable "gradient_machine_config" {
  description = "Gradient machine config"
  default     = ""
}
variable "machine_storage_main" {
  type        = number
  description = "Main storage id"
  default     = 500
}
variable "machine_template_id_main" {
  description = "Main template id"
  default     = "tpi7gqht"
}
variable "machine_type_main" {
  description = "Main machine type"
  type        = string
  default     = "C7"
}

variable "machine_count_main" {
  description = "Main machine count"
  type        = number
  default     = 1
}
variable "machine_type_controlplane" {
  description = "Controlplane machine type"
  default     = "C8"
}

variable "machine_count_controlplane" {
  description = "Main machine count"
  type        = number
  default     = 0
}

variable "machine_storage_lb" {
  type        = number
  description = "LB storage"
  default     = 250
}

variable "machine_template_id_lb" {
  description = "LB template id"
  default     = "tpi7gqht"
}

variable "machine_type_lb" {
  description = "LB machine type"
  default     = "C5"
}

variable "machine_template_id_admin" {
  description = "admin template id"
  default     = "tpi7gqht"
}

variable "machine_type_admin" {
  description = "admin machine type"
  default     = "C5"
}

variable "admin-machine-name-suffix" {
  default = "bastion-host"
}

variable "machine_storage_admin" {
  type        = number
  description = "admin storage"
  default     = 200
}

variable "gradient_admin_vm_enabled" {
  description = "gradient admin public box is enabled"
  default     = false
}

variable "gradient_workspace_vm_enabled" {
  description = "gradient workspace job box is enabled"
  default     = true
}

variable "machine_storage_service" {
  type        = number
  description = "Service storage"
  default     = 500
}

variable "machine_template_id_service" {
  description = "Service template id"
  default     = "tpi7gqht"
}

variable "machine_type_service" {
  description = "Service machine type"
  default     = "C5"
}

variable "machine_count_service" {
  description = "Service machine count"
  default     = 0
}

variable "machine_storage_worker_cpu" {
  type        = number
  description = "CPU worker storage"
  default     = 500
}
variable "machine_template_id_cpu" {
  description = "CPU template id"
  default     = "tpi7gqht"
}

variable "machine_storage_worker_gpu" {
  type        = number
  description = "GPU worker storage"
  default     = 500
}
variable "machine_template_id_gpu" {
  description = "GPU template id"
  default     = "tmun4o2g"
}

variable "rancher_api_url" {
  description = "Rancher API URL"
}
variable "rancher_access_key" {
  description = "Rancher access_key"
}
variable "rancher_secret_key" {
  description = "Rancher secret_key"
}

variable "region" {
  description = "Cloud region"
  default     = "East Coast (NY2)"
}

variable "team_id" {
  description = "Cluster team id"
}

variable "team_id_integer" {
  description = "Cluster team id integer"
}

variable "workers" {
  type        = list(any)
  description = "Additional workers"
  default     = []
}

variable "anti_crypto_miner_regex" {
  description = "Scan for crytpo miner processes using this regex"
  default     = ""
}

variable "service_pool_name" {
  description = "Service pool node selector"
  default     = "services-small"
}

variable "rbd_storage_config" {
  description = "Local storage config json"
  default     = ""
}

variable "ccm_chart_version" {
  description = "Cloud Controller Manager chart version"
  default     = "v0.1.1"
}

variable "ccm_image_tag" {
  description = "Cloud Controller Manager image tag"
  default     = "v0.20.0"
}

variable "pop_chart_version" {
  description = "Pool Overprovisioner chart version"
  default     = "0.1.0"
}

variable "paperspace_api_next_url" {
  description = "Paperspace API next URL"
  default     = "https://api.paperspace.com"
}


variable "use_dedicated_etcd_volume" {
  description = "Use dedicated etcd volume. Set to true this will assume /var/lib/etcd is a dedicated volume on the host"
  default     = false
}

variable "etcd_backup_config" {
  description = "etcd backup config"
  type = object({
    bucket_name = string
    endpoint    = string
    region      = string
    access_key  = string
    secret_key  = string
    prefix      = string
  })
  default = null
}

variable "environment" {
  description = "paperspace environment"
  default     = "production"
  type        = string
}

variable "admin_email" {
    description = "Paperspace admin API email"
}

variable "admin_user_api_key" {
    description = "Paperspace admin API key"
}

variable "api_host" {
    description = "api host"
    default = "api.paperspace.io"
}

variable "asg_max_sizes" {
    description = "Autoscaling Group max sizes"
    default = {}
}

variable "asg_min_sizes" {
    description = "Autoscaling Group min sizes"
    default = {}
}

variable "aws_access_key_id" {
    description = "AWS access key id"
    default = ""
}
variable "aws_secret_access_key" {
    description = "AWS secret access key"
    default = ""
}

variable "cluster_autoscaler_enabled" {
    description = "Cluster Autoscaler enabled"
    type = bool
    default = true
}
variable "cluster_autoscaler_image_repository" {
    description = "Cluster Autoscaler image repository"
    default = "paperspace/cluster-autoscaler"
}
variable "cluster_autoscaler_image_tag" {
    description = "Cluster Autoscaler image tag"
    default = "v1.15"
}

variable "cloudflare_api_key" {
    description = "Cloudflare API key"
    default = ""
}
variable "cloudflare_email" {
    description = "Cloudflare email"
    default = ""
}
variable "cloudflare_zone_id" {
    description = "Cloudflare zone id"
    default = ""
}

variable "is_managed" {
    type = bool
    description = "Is PS Cloud cluster managed by Paperspace"
    default = false
}

variable "is_proxied" {
    type = bool
    description = "Should cluster proxy traffic through Cloudflare"
    default = false
}

variable "machine_storage_main" {
    type = number
    description = "Main storage id"
    default = 500
}
variable "machine_template_id_main" {
    description = "Main template id"
    default = "tpi7gqht" # tpi7gqht comes pre-installed with docker
}
variable "machine_type_main" {
    description = "Main machine type"
    default = "C5"
}

variable "machine_count_worker_cpu" {
    type = number
    description = "Number of CPU workers"
    default = 3
}
variable "machine_storage_worker_cpu" {
    type = number
    description = "CPU worker storage"
    default = 100
}
variable "machine_template_id_cpu" {
    description = "CPU template id"
    default = "tpi7gqht" # tpi7gqht comes pre-installed with docker
}
variable "machine_type_worker_cpu" {
    description = "CPU worker machine type"
    default = "C5"
}

variable "machine_count_worker_gpu" {
    type = number
    description = "Number of GPU workers"
    default = 3
}
variable "machine_storage_worker_gpu" {
    type = number
    description = "GPU worker storage"
    default = 100
}
variable "machine_template_id_gpu" {
    description = "GPU template id"
    default = "tmun4o2g"
}
variable "machine_type_worker_gpu" {
    description = "GPU worker machine type"
    default = "P4000"
}

variable "region" {
    description = "Cloud region"
    default = "East Coast (NY2)"
}

variable "team_id" {
    description = "Cluster team id"
}

variable "team_id_integer" {
    description = "Cluster team id integer"
}

variable "workers" {
    type = list
    description = "Additional workers"
    default = []
}
variable "replica_count" {
  description = "How many instances of the mirror to run"
  default     = 2
  type        = number
}

variable "docker_hub_username" {
  description = "Username for docker hub. Must be associated with a paid account"
  type        = string
}

variable "docker_hub_password" {
  description = "Password for docker hub"
  type        = string
}

variable "hostname" {
  description = "Externally accessible hostname for the mirror"
  type        = string
}

variable "service_name" {
  description = "Name of the mirror service in the cluster"
  default     = "docker-registry-mirror"
  type        = string
}

variable "docker_registry_s3_storage" {
  description = "S3 configuration for mirror storage"
  default     = null
  type = object({
    access_key      = string
    secret_key      = string
    region          = string
    region_endpoint = string
    bucket          = string
  })
}

variable "docker_registry_pvc_storage" {
  description = "Persistent volume configuration for mirror storage"
  default     = null
  type = object({
    size           = string
    storage_class  = string
    existing_claim = string
  })
}

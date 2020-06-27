variable "admin_email" {
    default = ""
}

variable "admin_user_api_key" {
    default = ""
}

variable "cluster_id" {
    default = ""
}

variable "machine_storage_main" {
    default = 50
}
variable "machine_template_id_main" {
    default = "t04azgph"
}
variable "machine_type_main" {
    default = "C5"
}

variable "machine_count_worker_cpu" {
    default = 3
}
variable "machine_storage_worker_cpu" {
    default = 50
}
variable "machine_template_id_cpu" {
    default = "t04azgph"
}
variable "machine_type_worker_cpu" {
    default = "C5"
}

variable "machine_count_worker_gpu" {
    default = 3
}
variable "machine_storage_worker_gpu" {
    default = 50
}
variable "machine_template_id_gpu" {
    default = "tmun4o2g"
}
variable "machine_type_worker_gpu" {
    default = "P4000"
}

variable "name" {
    default = ""
}

variable "network_id" {
    default = ""
}

variable "region" {
    default = "East Coast (NY2)"
}

variable "team_handle" {
    default = ""
}

variable "ssh_key_public" {
    default = ""
}

variable "ssh_key_private" {
    default = ""
}

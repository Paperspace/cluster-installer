variable "docker_socket" {
    description = "Path to remote docker socket"
    default = "/var/run/docker.sock"
}

variable "enable" {
    type = bool
    description = "If module should be enabled"
}

variable "k8s_version" {
    description = "Kubernetes version"
}

variable "kubeconfig_path" {
    description = "kubeconfig path"
}

variable "local_storage_path" {
    description = "Local storage path for nodes"
}

variable "master_ips" {
    type = list
    description = "Kubernetes master ips"
}

variable "master_pool_type" {
    description = "Master pool type"
}

variable "name" {
    description = "Name"
}

variable "setup_docker" {
    description = "Setup docker"
}
variable "setup_nvidia" {
    description = "Setup NVIDIA drivers and nvidia-docker"
}

variable "service_pool_name" {
    description = "Service pool selector"
}

variable "ssh_key" {
    description = "SSH key"
}

variable "ssh_key_path" {
    description = "SSH key path"
}

variable "ssh_user" {
    description = "SSH user"
}

variable "workers" {
    type = list
    description = "Kubernetes workers"
}
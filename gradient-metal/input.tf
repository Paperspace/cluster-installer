variable "become_ssh_user" {
    description = "Remote ssh user with elevated privileges"
    default = "root"
}

variable "cluster_autoscaler_enabled" {
    description = "Cluster autoscaler enabled"
    default = false
}

variable "cluster_autoscaler_image_repository" {
    description = "Cluster autoscaler image repository"
    default = ""
}
variable "cluster_autoscaler_image_tag" {
    description = "Cluster autoscaler image tag"
    default = ""
}

variable "k8s_master_node" {
    type = map
    description = "Kubernetes master node"
}

variable "k8s_sans" {
    type = list
    description = "List of hostname or IPs used for Kubernetes authentications"
    default = []
}

variable "k8s_workers" {
    type = list
    description = "Kubernetes workers"
}

variable "reboot_gpu_nodes" {
    type = bool
    description = "Reboot GPU nodes"
    default = false
}

variable "ssh_key" {
    description = "Private SSH key"
    default = ""
}

variable "ssh_key_path" {
    description = "Private SSH key file path"
    default = "~/.ssh/id_rsa"
}

variable "ssh_user" {
    description = "SSH user"
    default = "ubuntu"
}

variable "cpu_selector" {
    description = "Node CPU selector"
    default = "metal-cpu"
}
variable "gpu_selector" {
    description = "Node GPU selector"
    default = "metal-gpu"
}

variable "local_storage_path" {
    description = "Local storage path on nodes"
    default = ""
}

variable "local_storage_server" {
    description = "Local storage server"
    default = ""
}

variable "local_storage_type" {
    description = "Local storage type"
    default = ""
}

variable "setup_docker" {
    description = "Setup docker"
    default = false
}

variable "setup_nvidia" {
    description = "Setup NVIDIA Cuda drivers, docker, and kubernetes integrations (Requires reboot)"
    default = false
}

variable "service_pool_name" {
    description = "Service node selector"
    default = "services-small"
}

variable "use_pod_anti_affinity" {
    description = "Use pod anti-affinity"
    default = false
}

variable "helm_repo_username" {
  description = "Helm repo username"
}

variable "helm_repo_password" {
  description = "Helm repo password"
}

variable "chart_version" {
  description = "Chart version"
  default     = "v3.4.0"
}

variable "image_tag" {
  description = "Docker image tag"
  default     = "v0.20.0"
}

variable "cluster_apikey" {
  description = "PS API Key"
}

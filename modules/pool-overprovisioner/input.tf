variable "helm_repo_url" {
  description = "Helm repo username"
}

variable "helm_repo_username" {
  description = "Helm repo username"
}

variable "helm_repo_password" {
  description = "Helm repo password"
}

variable "chart_version" {
  description = "Chart version"
}

variable "pool_overprovisions" {
  description = "Mapping of vm types to overprovision count"
  default = {}
}

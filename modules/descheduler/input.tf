variable "chart_version" {
  description = "Version of the descheduler chart"
  default     = "0.21.0"
  type        = string
}

variable "pool_name" {
  description = "Name of the node pool to run the mirror on"
  type        = string
}

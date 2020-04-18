# AMQP
variable "amqp_hostname" {
    description = "AMQP hostname"
    default = "broker.paperspace.io"
}

variable "amqp_port" {
    description = "AMQP port"
    default = "5672"
}
variable "amqp_protocol" {
    description = "AMQP protocol"
    default = "amqps"
}

# AWS
variable "aws_region" {
    description = "AWS region"
    default = "us-east-1"
}

# Cluster
variable "artifacts_access_key_id" {
    description = "S3 compatibile access key for artifacts object storage"
}

variable "artifacts_object_storage_endpoint" {
    description = "Object storage endpoint to be used for Gradient"
}

variable "artifacts_path" {
    description = "Object storage path used for Gradient"
}

variable "artifacts_secret_access_key" {
    description = "S3 compatible access key for artifacts object storage"
}

variable "cluster_apikey" {
  description = "Gradient cluster apikey"
}
variable "cluster_autoscaler_enabled" {
    type = bool
    description = "Enable cluster-autoscaler"
    default = false
}
variable "cluster_handle" {
  description = "Gradient cluster handle"
}

variable "domain" {
  description = "domain"
}

variable "elastic_search_host" {
    description = "Elastic search host"
    default = "b35b1cdf227c418b8353fd3b282527c5.us-east-1.aws.found.io"
}
variable "elastic_search_password" {
    description = "Elastic search password"
    default = "Rd9zjAWFWMMj5skOxeV7arv6"
}
variable "elastic_search_port" {
    description = "Elastic search port"
    default = 9243
}
variable "elastic_search_user" {
    description = "Elastic search user"
    default = "elastic"
}

variable "enabled" {
    description = "If module is enabled"
    default = "true"
}

variable "environment" {
    description = "Cluster environment"
    default = "production"
}

variable "global_selector" {
    description = "Node selector prefix used globally"
    default = ""
}

variable "gradient_processing_version" {
  description = "Gradient processing version"
}

variable "label_selector_cpu" {
  description = "Node selector for cpu"
  default = ""
}

variable "label_selector_gpu" {
  description = "Node selector for gpu"
  default = ""
}

variable "logs_host" {
  description = "Logs host endpoint"
}

variable "name" {
  description = "Cloud provider name"
}

variable "shared_storage_path" {
  description = "Shared storage path "
  default = "/"
}
variable "shared_storage_server" {
  description = "Shared storage server"
}

variable "shared_storage_type" {
  description = "Default shared storage type"
}

# k8s
variable "k8s_namespace" {
  description = "K8s namespace"
  default = "default"
}

variable "minikube" {
  type = bool
  description = "Set to true if minikube is being used"
  default = false
}

variable "service_pool_name" {
    description = "Service pool node selector"
    default = "services-small"
}

variable "sentry_dsn" {
  description = "DSN for sentry alerts"
}

# tls
variable "tls_cert" {
  description = "TLS certificate"
}
variable "tls_key" {
  description = "TLS key"
}

variable "use_pod_anti_affinity" {
    description = "Use pod antiaffinity"
    default = "false"
}
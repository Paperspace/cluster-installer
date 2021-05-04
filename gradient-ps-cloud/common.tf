variable "amqp_hostname" {
  description = "AMQP hostname"
  default     = "broker.paperspace.io"
}

variable "amqp_port" {
  description = "AMQP port"
  default     = "5672"
}
variable "amqp_protocol" {
  description = "AMQP protocol"
  default     = "amqps"
}

variable "artifacts_access_key_id" {
  description = "S3 compatibile access key for artifacts object storage"
}

variable "artifacts_object_storage_endpoint" {
  description = "Object storage endpoint to be used for Gradient"
  default     = ""
}

variable "artifacts_path" {
  description = "Object storage path used for Gradient"
}

variable "artifacts_region" {
  description = "Object storage region used for Gradient"
  default     = "us-east-1"
}

variable "artifacts_secret_access_key" {
  description = "S3 compatible access key for artifacts object storage"
}

variable "cluster_apikey" {
  description = "Gradient cluster API key"
}

variable "cluster_handle" {
  description = "Gradient cluster API handle"
}

variable "domain" {
  description = "Domain used to host gradient"
}

variable "elastic_search_host" {
  description = "Elastic search host"
  default     = "b35b1cdf227c418b8353fd3b282527c5.us-east-1.aws.found.io"
}

variable "elastic_search_index" {
  description = "Elastic search index"
  default     = ""
}

variable "elastic_search_password" {
  description = "Elastic search password"
  default     = "6qKRFJHBXygLfTtLTTnn2!yH"
}

variable "elastic_search_port" {
  description = "Elastic search port"
  default     = 9243
}

variable "elastic_search_user" {
  description = "Elastic search user"
  default     = "gradient"
}

variable "gradient_processing_chart" {
  description = "Gradient processing chart"
  default     = "gradient-processing"
}

variable "gradient_processing_version" {
  description = "Gradient processing version"
  default     = "*"
}

variable "helm_repo_username" {
  description = "Paperspace repo username"
  default     = ""
}

variable "helm_repo_password" {
  description = "Paperspace repo password"
  default     = ""
}

variable "helm_repo_url" {
  description = "Paperspace repo URL"
  default     = ""
}

variable "logs_host" {
  description = "Logs host"
  default     = "logs.paperspace.io"
}

variable "k8s_endpoint" {
  description = "Kubernetes endpoint (https://k8s_endpoint:6443)"
  default     = ""
}

variable "k8s_version" {
  description = "Kubernetes version"
  default     = ""
}

variable "kubeconfig_path" {
  description = "Kubeconfig path"
  default     = "./gradient-kubeconfig"
}

variable "letsencrypt_dns_name" {
  description = "letsencrypt dns provider name"
  default     = "default"
}
variable "letsencrypt_dns_settings" {
  type        = map(any)
  description = "letsencrypt settings"
  default     = {}
}

variable "local_storage_config" {
  description = "Local storage config json"
  default     = ""
}
variable "local_storage_path" {
  description = "Local storage path on nodes"
  default     = ""
}

variable "local_storage_server" {
  description = "Local storage server"
  default     = ""
}

variable "local_storage_type" {
  description = "Local storage type"
  default     = ""
}

variable "name" {
  description = "Name"
}

variable "public_key_path" {
  description = "Login key path"
  default     = ""
}

variable "sentry_dsn" {
  description = "DSN for sentry alerts"
  default     = ""
}

variable "shared_storage_config" {
  description = "Shared storage configuration json"
  default     = ""
}

variable "shared_storage_server" {
  description = "Shared storage server to be used for Gradient"
  default     = ""
}
variable "shared_storage_path" {
  description = "Shared storage path to be used for Gradient"
  default     = "/"
}
variable "shared_storage_type" {
  description = "Shared storage type"
  default     = ""
}

variable "tls_cert" {
  description = "SSL certificate used for loadbalancers"
  default     = ""
}

variable "tls_key" {
  description = "SSL key used for loadbalancers"
  default     = ""
}

variable "traefik_prometheus_auth" {
  description = "Traefik basic auth for ingress `htpasswd user:pass`"
  default     = ""
}

variable "write_kubeconfig" {
  description = "Write kubeconfig to a file"
  default     = "true"
}

variable "prometheus_resources" {
  description = "map of k8s resource requests for prometheus"
  type        = map(string)
  default     = null
}

variable "cert_manager_enabled" {
  description = "Enable cert-manager helm package, this is required for gradient but should only be installed once per cluster"
  default     = true
  type        = bool
}

variable "image_cache_enabled" {
  description = "enable installation of the kubefledged operator to cache basic workload images on your nodes"
  type = bool
  default = true
}

variable "image_cache_list" {
  description = "list of containers to cache on your worker nodes"
  type = list(string)
  default = [
    "paperspace/fastai:2.0-CUDA9.2-fastbook-v0.1.0",
    "tensorflow/tensorflow:2.4.1-jupyter",
    "paperspace/transformers-gpu:0.4.0",
    "nvcr.io/nvidia/rapidsai/rapidsai:0.18-cuda11.0-base-ubuntu18.04",
    "nvcr.io/nvidia/pytorch:21.02-py3",
    "paperspace/gradient-base:tf24-py36-0.10-small",
    "paperspace/gradient-base:tf24-py36-0.10",
    "paperspace/gradient-base:tf115-py36-0.10",
  ]
}

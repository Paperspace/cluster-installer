# AMQP
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


# Cluster
variable "artifacts_access_key_id" {
  description = "S3 compatible access key for artifacts object storage"
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

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "chart" {
  description = "Helm chart for gradient-processing"
  default     = "gradient-processing"
}

variable "cluster_apikey" {
  description = "Gradient cluster apikey"
}

variable "cluster_authorization_token" {
  description = "Cluster auth token to facilitate secure internal communication between API and processing site"
}

variable "cluster_autoscaler_autoscaling_groups" {
  type        = list(any)
  description = "Cluster autoscaler autoscaling groups"
  default     = []
}
variable "cluster_autoscaler_cloudprovider" {
  description = "Cluster autoscaler provider"
  default     = "aws"
}
variable "cluster_autoscaler_enabled" {
  type        = bool
  description = "Enable cluster autoscaler"
  default     = false
}
variable "cluster_autoscaler_delay_after_add" {
  description = "Cluster autoscaler scale-down delay after scale-up"
  default     = ""
}
variable "cluster_autoscaler_unneeded_time" {
  description = "Cluster autoscaler unneeded time before de-scaling a node"
  default     = ""
}

variable "cluster_handle" {
  description = "Gradient cluster handle"
}


variable "dispatcher_host" {
  description = "Dispatcher host"
}

variable "domain" {
  description = "domain"
}

variable "elastic_search_host" {
  description = "Elastic search host"
}
variable "elastic_search_index" {
  description = "Elastic search index"
  default     = ""
}

# write only key
variable "elastic_search_password" {
  description = "Elastic search password"

}
variable "elastic_search_port" {
  description = "Elastic search port"
}
variable "elastic_search_user" {
  description = "Elastic search user"
}

variable "enabled" {
  description = "If module is enabled"
  default     = "true"
}

variable "global_selector" {
  description = "Node selector prefix used globally"
  default     = ""
}

variable "gradient_processing_version" {
  description = "Gradient processing version"
}

variable "label_selector_cpu" {
  description = "Node selector for cpu"
  default     = ""
}

variable "label_selector_gpu" {
  description = "Node selector for gpu"
  default     = ""
}

variable "letsencrypt_dns_name" {
  description = "letsencrypt dns name"
}

variable "letsencrypt_dns_settings" {
  type        = map(any)
  description = "letsencrypt dns settings"
}

variable "logs_host" {
  description = "Logs host endpoint"
}

variable "name" {
  description = "Cloud provider name"
}

variable "local_storage_config" {
  description = "Local storage config json"
  default     = ""
}

variable "local_storage_path" {
  description = "Local storage path "
  default     = "/"
}
variable "local_storage_server" {
  description = "Local storage server"
  default     = ""
}
variable "local_storage_type" {
  description = "Local local storage type"
}

variable "shared_storage_config" {
  description = "Shared storage config json"
  default     = ""
}

variable "shared_storage_path" {
  description = "Shared storage path "
  default     = "/"
}
variable "shared_storage_server" {
  description = "Shared storage server"
  default     = ""
}

variable "shared_storage_type" {
  description = "Default shared storage type"
}

variable "lb_count" {
  description = "Number of LB pods"
  default     = 1
}
variable "lb_pool_name" {
  description = "LB pool node selector"
  default     = "services-small"
}

# k8s
variable "k8s_namespace" {
  description = "K8s namespace"
  default     = "default"
}

variable "minikube" {
  type        = bool
  description = "Set to true if minikube is being used"
  default     = false
}

variable "paperspace_base_url" {
  description = "Paperspace base URL"
  default     = "https://api.paperspace.io"
}

variable "service_pool_name" {
  description = "Service pool node selector"
  default     = "services-small"
}

variable "sentry_dsn" {
  description = "DSN for sentry alerts"
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

# tls
variable "tls_cert" {
  description = "TLS certificate"
}
variable "tls_key" {
  description = "TLS key"
}

variable "use_pod_anti_affinity" {
  description = "Use pod antiaffinity"
  default     = "false"
}

# Metrics New Relic

variable "metrics_new_relic_key" {
  description = "New Relic access key"
  default     = ""
}

variable "metrics_new_relic_enabled" {
  description = "Enables New Relic monitoring on the metrics API"
  default     = "false"
}

variable "metrics_new_relic_name" {
  description = "Postfix for New Relic application name"
  default     = ""
}

variable "pod_assignment_label_name" {
  description = "Label that your nodes will be selected against"
  default     = ""
}

variable "legacy_datasets_host_path" {
  description = "This directory will be mounted as `/data` in your notebooks"
  default     = ""
}

variable "legacy_datasets_pvc_name" {
  description = "This volume will be mounted as `/data` in your notebooks"
  default     = ""
}

variable "legacy_datasets_sub_path" {
  description = "This sub-directory of your host path or pvc will be mounted as `/data` in your notebooks"
  default     = ""
}

variable "anti_crypto_miner_regex" {
  description = "Scan for crytpo miner processes using this regex"
  default     = ""
}

variable "is_public_cluster" {
  description = "designate whether the cluster is a public cluster"
  type        = bool
  default     = false
}

variable "prometheus_resources" {
  description = "map of k8s resource requests for prometheus"
  type        = map(string)
  default     = null
}

variable "metrics_storage_class" {
  description = "Name of the storage class for the metrics server"
  type        = string
  default     = "gradient-processing-local"
}

variable "cert_manager_enabled" {
  description = "enable installation of the cert-manager operator"
  type        = bool
  default     = true
}

variable "cert_manager_version" {
  description = "Version of the cert-manager chart to install"
  type        = string
  default     = "v1.3.1"
}

variable "image_cache_enabled" {
  description = "enable installation of the kubefledged operator to cache basic workload images on your nodes"
  type        = bool
  default     = true
}

variable "image_cache_list" {
  description = "list of containers to cache on your worker nodes"
  type        = list(string)
  default     = []
}

variable "prometheus_pool_name" {
  description = "paperspace.com/pool-name for prometheus"
  type        = string
  default     = ""
}

variable "rbd_storage_config" {
  description = "Local storage config json"
  default     = ""
}

variable "metrics_server_enabled" {
  description = "enable installation of the metrics server"
  default     = true
}

variable "metrics_server_version" {
  description = "Version of the metrics server chart to install"
  default     = "3.7.0" # metrics-server 3.5.0 same as rancher
}

variable "paperspace_api_next_url" {
  description = "Paperspace API next URL"
  default     = "https://api.paperspace.com"
}

variable "victoria_metrics_vmsingle_enabled" {
  description = "Is VMSingle Enabled?"
  type        = bool
  default     = false
}

variable "victoria_metrics_vmsingle_service_endpoint" {
  type    = string
  default = "http://vmsingle-gradient-processing-victoria-metrics:8429/prometheus"
}

variable "victoria_metrics_vmcluster_enabled" {
  description = "Is VMCluster Mode Enabled?"
  type        = bool
  default     = true
}

variable "victoria_metrics_vmcluster_service_endpoint" {
  type    = string
  default = "http://vmselect-gradient-processing-victoria-metrics:8481/select/0/prometheus"
}

variable "victoria_metrics_vmcluster_vmselect_replicacount" {
  description = "How many vmselect replicas do you want running?"
  type        = number
  default     = 2
}

variable "victoria_metrics_vmcluster_vmstorage_replicacount" {
  description = "How many vmstorage replicas do you want running?"
  type        = number
  default     = 3
}

variable "volume_fs_new_relic_license_key" {
  description = "New Relic license key"
  default     = ""
}

variable "volume_fs_new_relic_enabled" {
  description = "Enables New Relic monitoring on the Volume FS API"
  default     = "false"
}

variable "volume_fs_new_relic_app_name" {
  description = "Postfix for New Relic application name"
  default     = ""
}

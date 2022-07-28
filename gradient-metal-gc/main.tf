terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.17.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.5.0"
    }
  }
}

locals {
  shared_storage_type     = var.shared_storage_type == "" ? "nfs" : var.shared_storage_type
  is_single_node          = length(var.k8s_workers) == 0
  service_pool_name       = var.service_pool_name
  load_balancer_pool_name = "lb"
  tls_cert                = var.is_tls_config_from_file ? file(var.tls_cert) : var.tls_cert
  tls_key                 = var.is_tls_config_from_file ? file(var.tls_key) : var.tls_key
}


provider "helm" {
  debug = true
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

variable "gradient_processing_enabled" {
  type    = number
  default = 1
}

// Gradient
module "gradient_processing" {
  source  = "../modules/gradient-processing"
  enabled = var.gradient_processing_enabled == 0 ? false : true

  amqp_hostname                         = var.amqp_hostname
  amqp_port                             = var.amqp_port
  amqp_protocol                         = var.amqp_protocol
  artifacts_access_key_id               = var.artifacts_access_key_id
  artifacts_object_storage_endpoint     = var.artifacts_object_storage_endpoint
  artifacts_path                        = var.artifacts_path
  artifacts_secret_access_key           = var.artifacts_secret_access_key
  chart                                 = var.gradient_processing_chart
  cluster_apikey                        = var.cluster_apikey
  cluster_authorization_token           = var.cluster_authorization_token
  cluster_autoscaler_autoscaling_groups = var.cluster_autoscaler_autoscaling_groups
  cluster_autoscaler_cloudprovider      = var.cluster_autoscaler_cloudprovider
  cluster_autoscaler_enabled            = var.cluster_autoscaler_enabled
  cluster_handle                        = var.cluster_handle
  dispatcher_host                       = var.dispatcher_host
  domain                                = var.domain

  helm_repo_username = var.helm_repo_username
  helm_repo_password = var.helm_repo_password
  helm_repo_url      = var.helm_repo_url

  label_selector_cpu       = var.cpu_selector
  label_selector_gpu       = var.gpu_selector
  letsencrypt_dns_name     = var.letsencrypt_dns_name
  letsencrypt_dns_settings = var.letsencrypt_dns_settings
  // Use shared storage by default for now
  local_storage_server        = var.local_storage_server
  local_storage_path          = var.local_storage_path
  local_storage_type          = var.local_storage_type
  logs_host                   = var.logs_host
  paperspace_base_url         = var.api_host
  paperspace_api_next_url     = var.paperspace_api_next_url
  gradient_processing_version = var.gradient_processing_version
  name                        = var.name
  sentry_dsn                  = var.sentry_dsn
  service_pool_name           = local.service_pool_name
  lb_count                    = 1
  lb_pool_name                = local.load_balancer_pool_name
  shared_storage_server       = var.shared_storage_server
  shared_storage_path         = ""
  shared_storage_type         = local.shared_storage_type
  shared_storage_config       = var.shared_storage_config
  tls_cert                    = local.tls_cert
  tls_key                     = local.tls_key
  use_pod_anti_affinity       = var.use_pod_anti_affinity
  cert_manager_enabled        = var.cert_manager_enabled
  image_cache_enabled         = true
  image_cache_list = length(var.image_cache_list) != 0 ? var.image_cache_list : [
    # Ordered by most used
    "graphcore/pytorch-jupyter:2.5.1-ubuntu-20.04",
    "graphcore/tensorflow-jupyter:1-amd-2.5.1-ubuntu-20.04",
    "graphcore/tensorflow-jupyter:2-amd-2.5.1-ubuntu-20.04",

    # Images used internally
    "paperspace/notebook_idle:v1.0.5",
  ]
  metrics_server_enabled                              = false
  victoria_metrics_vmcluster_enabled                  = false
  victoria_metrics_vmsingle_enabled                   = true
  metrics_storage_class                               = "gradient-processing-local"
  pod_assignment_label_name                           = "paperspace.com/pool-name"
  ipu_controller_server                               = var.ipu_controller_server
  ipu_model_cache_pvc_name                            = "gradient-processing-images"
  is_graphcore                                        = true
  victoria_metrics_prometheus_node_exporter_host_port = var.victoria_metrics_prometheus_node_exporter_host_port
  prometheus_pool_name                                = var.prometheus_pool_name
  node_health_check_enabled                           = false // only needed on ps clouds
  nfs_subdir_external_provisioner_path                = var.local_storage_path
  nfs_subdir_external_provisioner_server              = var.local_storage_server
  notebook_volume_type                                = var.notebook_volume_type
}


module "container_registry_mirror" {
  source              = "../modules/container-registry-mirror"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  hostname            = "container-registry-mirror.${var.domain}"
  pvc_storage = {
    size           = "500Gi"
    storage_class  = "gradient-processing-images"
    existing_claim = ""
  }
  pool_name = var.registry_pool_name != "" ? var.registry_pool_name : var.service_pool_name
}

terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 1.17.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.5.0"
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

variable "nats_storage_class" {
  type = string
  default = "gradient-processing-shared"
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
  cluster_api_host                      = var.cluster_api_host
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
  lb_count                    = var.lb_count
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
    # Images used internally
    # "paperspace/notebook_idle:v1.0.5",
    "paperspace/gradient-integrations-sidecar:latest",

    # Ordered by most used
    "graphcore/pytorch-paperspace:3.3.0-ubuntu-20.04-20230703",
    "graphcore/pytorch-geometric-paperspace:3.3.0-ubuntu-20.04-20230703",
    "graphcore/tensorflow-paperspace:3.3.0-ubuntu-20.04-20230703",
    "graphcore/pytorch-jupyter:3.1.0-ubuntu-20.04-20230224",
    "graphcore/tensorflow-jupyter:2-amd-3.1.0-ubuntu-20.04-20230224",
    "graphcore/tensorflow-jupyter:ogb-competition-2022-11-21",
    "graphcore/pytorch-geometric-jupyter:3.2.1-ubuntu-20.04-20230531",
    "graphcore/pytorch-jupyter:3.2.1-ubuntu-20.04-20230531",
  ]
  metrics_server_enabled                              = false
  victoria_metrics_vmcluster_enabled                  = false
  victoria_metrics_vmcluster_vmstorage_replicacount   = var.victoria_metrics_vmcluster_vmstorage_replicacount
  metrics_port                                        = 8429
  metrics_service_name                                = "vmsingle-gradient-processing-victoria-metrics"
  metrics_path                                        = "/prometheus"
  victoria_metrics_vmsingle_enabled                   = true
  metrics_storage_class                               = var.metrics_storage_class
  pod_assignment_label_name                           = "paperspace.com/pool-name"
  ipu_controller_server                               = var.ipu_controller_server
  ipuof_vipu_api_host                                 = var.ipuof_vipu_api_host
  ipuof_vipu_api_port                                 = var.ipuof_vipu_api_port
  legacy_datasets_host_path                           = "/mnt/public/data"
  is_graphcore                                        = true
  victoria_metrics_prometheus_node_exporter_host_port = var.victoria_metrics_prometheus_node_exporter_host_port
  prometheus_pool_name                                = var.prometheus_pool_name
  node_health_check_enabled                           = false // only needed on ps clouds
  nfs_subdir_external_provisioner_path                = ""
  nfs_subdir_external_provisioner_server              = var.shared_storage_server
  rbd_storage_config                                  = var.rbd_storage_config
  notebook_volume_type                                = var.notebook_volume_type
  ceph_provisioner_replicas                           = var.ceph_provisioner_replicas
  nats_storage_class                                  = var.nats_storage_class
  service_resources = merge(local.service_resource_defaults, {
    "vmsingle" = {
      "limits" = {
        "cpu"    = "1400m"
        "memory" = "30Gi"
      }
      "storage" : "400Gi"
    }
  })
  bad_nodes_interval = -1
}


module "container_registry_mirror" {
  source              = "../modules/container-registry-mirror"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  hostname            = "container-registry-mirror.${var.domain}"
  pvc_storage = {
    size           = "500Gi"
    storage_class  = "gradient-processing-shared"
    existing_claim = ""
  }
  pool_name = var.registry_pool_name != "" ? var.registry_pool_name : var.service_pool_name
}

module "s3_external_ingress" {
  source = "../modules/external-ingress"

  host           = "s3"
  cluster_domain = var.domain
  ip_addresses   = var.external_s3_ip_addresses
  http_port      = var.external_s3_port
  custom_repsonse_headers = [
    "Access-Control-Allow-Origin:https://${var.console_host}",
    "Access-Control-Allow-Methods:HEAD,GET,PUT,POST,OPTIONS",
    "Access-Control-Allow-Headers:*",
    "Access-Control-Expose-Headers:Content-Length,Content-Range",
    "Access-Control-Allow-Credentials:true",
  ]
}

module "node_problem_detector" {
  source = "../modules/node-problem-detector"
}

resource "kubernetes_cron_job" "gradient_processing_shared_backup_job" {
  count = var.enable_cephbackup_job ? 1 : 0

  metadata {
    name = "gradient-processing-shared-backup"
  }

  spec {
    schedule                      = "@hourly"
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 3
    starting_deadline_seconds     = 60
    successful_jobs_history_limit = 3
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 3600
        template {
          metadata {}
          spec {
            container {
              name  = "rsync"
              image = "alpinelinux/rsyncd"
              command = [
                "rsync",
                "-av",
                "--no-specials",
                "--no-devices",
                "--no-group",
                "--no-owner",
                "--delete",
                "--exclude", "/mnt/gradient/volumes", // exclude csi volumes we don't care about prom data and rsync chokes on them
                "/mnt/gradient/",
                "/mnt/gradient-backup/gradient-volumes"
              ]

              volume_mount {
                name       = "gradient-shared"
                mount_path = "/mnt/gradient"
                read_only  = true
              }
              volume_mount {
                name       = "gradient-shared-backup"
                mount_path = "/mnt/gradient-backup"
              }
              security_context {
                allow_privilege_escalation = false
                run_as_user                = 0
              }
            }

            node_selector = {
              "paperspace.com/pool-name" = local.service_pool_name
            }

            volume {
              name = "gradient-shared"
              persistent_volume_claim {
                claim_name = "gradient-processing-shared"
              }
            }

            volume {
              name = "gradient-shared-backup"
              host_path {
                path = "/mnt/poddata"
              }
            }
          }
        }
      }
    }
  }
}

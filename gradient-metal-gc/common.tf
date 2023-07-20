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

variable "cluster_authorization_token" {
  description = "Cluster auth token to facilitate secure internal communication between API and processing site"
}

variable "cluster_handle" {
  description = "Gradient cluster API handle"
}

variable "dispatcher_host" {
  description = "Dispatcher host"
  default     = "dispatcher.paperspace.com"
}

variable "cluster_api_host" {
  description = "Cluster API host"
  default     = "cluster-api.paperspace.com"
}

variable "domain" {
  description = "Domain used to host gradient"
}

variable "secondary_domain" {
  description = "Secondary domain used to host gradient"
  default = ""
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

variable "cert_manager_enabled" {
  description = "Enable cert-manager helm package, this is required for gradient but should only be installed once per cluster"
  default     = false
  type        = bool
}


variable "image_cache_enabled" {
  description = "enable caching of common workload images on your nodes"
  type        = bool
  default     = false
}

variable "image_cache_list" {
  description = "list of containers to cache on your worker nodes"
  type        = list(string)
  default     = []
}

variable "admin_team_handle" {
  description = "Team handle that should have extra admin access on workloads executed on the cluster. This setting should only be used on multi-team clusters."
  type        = string
  default     = ""
}

variable "ceph_provisioner_replicas" {
  description = "Number of replicas to run for the cephfs-csi-provisioner"
  type        = number
  default     = 3
}

variable "console_host" {
  description = "Console host"
  default     = "console.paperspace.com"
  type        = string
}

variable "service_resources" {
  description = "Map of resources for various components. If you only provide a limits value, it will be used for both requests and limits."
  type = map(object({
    requests = optional(object({
      cpu    = string
      memory = string
    }), null),
    limits = object({
      cpu    = string
      memory = string
    })
    storage = optional(string, null)
  }))
  // note that defaults are set in the locals block below so that we can merge
  default = {}
}

locals {
  service_resource_defaults = merge({
    "default" = {
      "limits" = {
        "cpu"    = "100m"
        "memory" = "128Mi"
      }
    },
    "cluster-autoscaler" = {
      "limits" = {
        "cpu"    = "100m"
        "memory" = "512Mi"
      }
    },
    "vmsingle" = {
      "limits" = {
        "cpu"    = "2"
        "memory" = "2Gi"
      }
    }
    "vminsert" = {
      "limits" = {
        "cpu"    = "2"
        "memory" = "2Gi"
      }
    },
    "vmselect" = {
      "limits" = {
        "cpu"    = "1"
        "memory" = "1Gi"
      }
    }
    "vmstorage" = {
      "limits" = {
        "cpu"    = "1"
        "memory" = "1Gi"
      }
    },
    "vmagent" = {
      "limits" = {
        "cpu"    = "1"
        "memory" = "1Gi"
      }
    },
    "argo-rollouts" = {
      "limits" = {
        "cpu"    = "100m"
        "memory" = "128Mi"
      }
    },
    "volume-controller" = {
      "limits" = {
        "cpu"    = "500m"
        "memory" = "1Gi"
      }
    },
  }, var.service_resources)
}

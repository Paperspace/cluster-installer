terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3"
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

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ec2_instance_type_offerings" "available" {
  for_each = local.az_map

  filter {
    name   = "instance-type"
    values = local.instance_types
  }

  filter {
    name   = "location"
    values = [each.key]
  }

  location_type = "availability-zone"
}

locals {
  az     = compact([for name in data.aws_availability_zones.available.names : length(data.aws_ec2_instance_type_offerings.available[name].instance_types) == length(local.instance_types) ? name : ""])
  az_map = zipmap(data.aws_availability_zones.available.names, data.aws_availability_zones.available.names)

  has_k8s            = var.k8s_endpoint == "" ? false : true
  has_shared_storage = var.shared_storage_server == "" ? false : true
  instance_types = [
    "c5.xlarge",
    "c5.2xlarge",
    "c5.4xlarge",
    "p2.xlarge",
    "p3.2xlarge",
    "p3.16xlarge"
  ]
  k8s_version         = var.k8s_version == "" ? "1.20" : var.k8s_version
  shared_storage_type = var.shared_storage_type == "" ? "efs" : var.shared_storage_type
}

module "network" {
  source = "./modules/network"
  enable = !local.has_k8s

  availability_zones = length(var.availability_zones) >= 2 ? slice(var.availability_zones, 0, 2) : slice(local.az, 0, 2)
  cidr               = var.cidr
  name               = var.name
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = 1
  }
  subnet_netmask = var.subnet_netmask
  vpc_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

// Kubernetes
module "kubernetes" {
  source = "./modules/kubernetes"
  enable = !local.has_k8s

  name = var.name
  additional_userdata = templatefile("${path.module}/files/post-userdata.sh.tpl", {
    enable_gcr_mirror = var.enable_gcr_mirror
  })
  k8s_version             = local.k8s_version
  kubeconfig_path         = var.kubeconfig_path
  iam_accounts            = var.iam_accounts
  iam_roles               = var.iam_roles
  iam_users               = var.iam_users
  node_asg_max_sizes      = var.k8s_node_asg_max_sizes
  node_asg_min_sizes      = var.k8s_node_asg_min_sizes
  node_instance_types     = var.k8s_node_instance_types
  node_security_group_ids = local.has_k8s ? split(",", var.k8s_security_group_ids) : [module.network.private_security_group_id]
  node_subnet_ids         = local.has_k8s ? split(",", var.k8s_subnet_ids) : module.network.private_subnet_ids
  public_key              = var.public_key_path == "" ? "" : file(pathexpand(var.public_key_path))
  vpc_id                  = module.network.vpc_id
  write_kubeconfig        = var.write_kubeconfig
}

# Storage
module "storage" {
  source = "./modules/storage"
  enable = !local.has_shared_storage

  name               = var.name
  security_group_ids = local.has_k8s ? split(",", var.k8s_security_group_ids) : [module.network.private_security_group_id]
  subnet_ids         = local.has_k8s ? split(",", var.k8s_subnet_ids) : module.network.private_subnet_ids
}

data "aws_eks_cluster" "cluster" {
  count = local.has_k8s ? 0 : 1
  name  = module.kubernetes.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = local.has_k8s ? 0 : 1
  name  = module.kubernetes.cluster_id
}
provider "helm" {
  alias = "gradient"
  debug = true
  kubernetes {
    host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, tolist([])), 0)
    cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, tolist([])), 0))
    token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, tolist([])), 0)
  }
}
provider "kubernetes" {
  alias = "gradient"

  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, tolist([])), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, tolist([])), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, tolist([])), 0)
}

// Gradient
module "gradient_processing" {
  source  = "../modules/gradient-processing"
  enabled = module.kubernetes.cluster_status == "" ? false : true

  amqp_hostname                     = var.amqp_hostname
  amqp_port                         = var.amqp_port
  amqp_protocol                     = var.amqp_protocol
  aws_region                        = var.aws_region
  artifacts_access_key_id           = var.artifacts_access_key_id
  artifacts_object_storage_endpoint = var.artifacts_object_storage_endpoint
  artifacts_path                    = var.artifacts_path
  artifacts_secret_access_key       = var.artifacts_secret_access_key
  chart                             = var.gradient_processing_chart
  cluster_apikey                    = var.cluster_apikey
  cluster_authorization_token       = var.cluster_authorization_token
  cluster_autoscaler_enabled        = true
  cluster_handle                    = var.cluster_handle
  dispatcher_host                   = var.dispatcher_host
  cluster_api_host                  = var.cluster_api_host
  domain                            = var.domain
  helm_repo_username                = var.helm_repo_username
  helm_repo_password                = var.helm_repo_password
  helm_repo_url                     = var.helm_repo_url
  letsencrypt_dns_name              = var.letsencrypt_dns_name
  letsencrypt_dns_settings          = var.letsencrypt_dns_settings
  logs_host                         = var.logs_host
  paperspace_base_url               = var.api_host
  paperspace_api_next_url           = var.paperspace_api_next_url

  gradient_processing_version = var.gradient_processing_version
  name                        = var.name
  sentry_dsn                  = var.sentry_dsn
  local_storage_type          = "AWSEBS"
  shared_storage_path         = var.shared_storage_path
  shared_storage_server       = local.has_shared_storage ? var.shared_storage_server : module.storage.shared_storage_dns_name
  shared_storage_type         = local.shared_storage_type
  tls_cert                    = var.tls_cert
  tls_key                     = var.tls_key
  cert_manager_enabled        = var.cert_manager_enabled
  image_cache_enabled         = var.image_cache_enabled
  image_cache_list            = var.image_cache_list
  service_resources           = local.service_resource_defaults
}

output "elb_hostname" {
  value = module.gradient_processing.traefik_service.status.0.load_balancer.0.ingress.0.hostname
}

module "node_problem_detector" {
  source = "../modules/node-problem-detector"
}

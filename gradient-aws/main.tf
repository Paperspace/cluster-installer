provider "aws" {
  region = var.aws_region
}

locals {
    has_k8s = var.k8s_endpoint == "" ? false : true
    has_shared_storage = var.shared_storage_server == "" ? false : true
}

module "network" {
    source = "./modules/network"
    enable = !local.has_k8s

    availability_zone_count = var.availability_zone_count
    cidr = var.cidr
    name = var.name
    private_subnet_tags = {
        "kubernetes.io/cluster/${var.name}" = "shared"
    }
    public_subnet_tags = {
        "kubernetes.io/cluster/${var.name}" = "shared"
        "kubernetes.io/role/elb" = 1
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
    k8s_version = var.k8s_version
    kubeconfig_path = var.kubeconfig_path
    iam_accounts = var.iam_accounts
    iam_roles = var.iam_roles
    iam_users = var.iam_users
    node_asg_max_sizes = var.k8s_node_asg_max_sizes
    node_asg_min_sizes = var.k8s_node_asg_min_sizes
    node_instance_types = var.k8s_node_instance_types
    node_security_group_ids = local.has_k8s ? split(",", var.k8s_security_group_ids) : [module.network.private_security_group_id]
    node_subnet_ids = local.has_k8s ? split(",", var.k8s_subnet_ids) : module.network.private_subnet_ids
    public_key = var.public_key_path == "" ? "" : file(pathexpand(var.public_key_path))
    vpc_id = module.network.vpc_id
}

# Storage
module "storage" {
  source = "./modules/storage"
	enable = !local.has_shared_storage

	name = var.name
    security_group_ids = local.has_k8s ? split(",", var.k8s_security_group_ids) : [module.network.private_security_group_id]
	subnet_ids = local.has_k8s ? split(",", var.k8s_subnet_ids) : module.network.private_subnet_ids
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
        host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
        cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
        token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
        load_config_file       = false
    }
}
provider "kubernetes" {
    alias = "gradient"

    host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
    cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
    token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
    load_config_file       = false
}

// Gradient
module "gradient_processing" {
	source = "../modules/gradient-processing"
    enabled = module.kubernetes.cluster_status == "" ? false : true
    providers = {
        helm = helm.gradient
        kubernetes = kubernetes.gradient
    }

    amqp_hostname = var.amqp_hostname
    amqp_port = var.amqp_port
    amqp_protocol = var.amqp_protocol
    aws_region = var.aws_region
    artifacts_access_key_id = var.artifacts_access_key_id
    artifacts_object_storage_endpoint = var.artifacts_object_storage_endpoint
    artifacts_path = var.artifacts_path
    artifacts_secret_access_key = var.artifacts_secret_access_key
    cluster_apikey = var.cluster_apikey
    cluster_autoscaler_enabled = true
    cluster_handle = var.cluster_handle
    domain = var.domain
    logs_host = var.logs_host

    gradient_processing_version = var.gradient_processing_version
    name = var.name
    sentry_dsn = var.sentry_dsn
    shared_storage_path = var.shared_storage_path
    shared_storage_server = local.has_shared_storage ? var.shared_storage_server : module.storage.shared_storage_dns_name
    shared_storage_type = var.shared_storage_type
    tls_cert = var.tls_cert
    tls_key = var.tls_key
}

output "elb_hostname" {
    value = module.gradient_processing.traefik_service.load_balancer_ingress[0].hostname
}
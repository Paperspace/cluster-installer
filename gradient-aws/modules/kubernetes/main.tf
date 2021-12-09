data "aws_ami" "eks_cpu" {
  most_recent = true
  name_regex  = "^amazon-eks-node-${var.k8s_version}.*"
  owners      = ["602401143452"]
}

data "aws_ami" "eks_gpu" {
  most_recent = true
  name_regex  = "^amazon-eks-gpu-node-${var.k8s_version}.*"
  owners      = ["602401143452"]
}

locals {
  ami_lookup = { "cpu" : data.aws_ami.eks_cpu.id, "gpu" : data.aws_ami.eks_gpu.id }

  gpu_instance_type_set = toset([
    var.aws_ec2_gpu_instance_p3_16xlarge,
    var.aws_ec2_gpu_instance_p3_2xlarge,
    var.aws_ec2_gpu_instance_p2_xlarge
  ])

  cpu_instance_type_set = toset([
    var.aws_ec2_cpu_instance_c5_xlarge,
    var.aws_ec2_cpu_instance_c5_xlarge
  ])

  ec2_instance_type_set = flatten([local.gpu_instance_type_set, local.cpu_instance_type_set])

  kube_worker_group = flatten([
    for gpu_instance_type in local.ec2_instance_type_set : [
      for worker_node_definition in gpu_instance_type.instance_type_metadata : {

        name = "${worker_node_definition.instance_type_name}-${data.aws_subnet.nodes[0].availability_zone}"
        # For subnets please see https://github.com/Paperspace/gradient-installer/issues/241 
        subnets                       = [var.node_subnet_ids[0]]
        additional_security_group_ids = var.node_security_group_ids
        additional_userdata           = var.additional_userdata

        ami_id           = local.ami_lookup[worker_node_definition.node_pool_type]
        asg_force_delete = true
        # ToDo, overrides for asg_desired_capacity?
        asg_desired_capacity = worker_node_definition.default_node_asg_capacities["desired"]
        asg_max_size         = lookup(var.node_asg_max_sizes, worker_node_definition.instance_type_name, worker_node_definition.default_node_asg_capacities["max"])
        asg_min_size         = lookup(var.node_asg_min_sizes, worker_node_definition.instance_type_name, worker_node_definition.default_node_asg_capacities["min"])
        instance_type        = gpu_instance_type.aws_ec2_instance_type
        root_volume_type     = worker_node_definition.root_storage_volume_type
        # ToDo, overrides for root_volume_size?
        root_volume_size = worker_node_definition.root_volume_size
        key_name         = var.public_key == "" ? "" : aws_key_pair.main[0].id
        kubelet_extra_args = "--node-labels=${join(",",
          concat([
            "paperspace.com/pool-name=${worker_node_definition.instance_type_name}",
            "paperspace.com/pool-type=${worker_node_definition.node_pool_type}",
            "paperspace.com/gradient-worker=${tostring(length(regexall("^services", worker_node_definition.instance_type_name)) > 0)}",
          ], worker_node_definition.kubelet_extra_args)
        )}"

        tags = [
          {
            key                 = "k8s.io/cluster-autoscaler/enabled",
            value               = "true",
            propagate_at_launch = "true",
          },
          {
            key                 = "k8s.io/cluster-autoscaler/node-template/label/paperspace.com/pool-name"
            value               = worker_node_definition.instance_type_name
            propagate_at_launch = "true",
          },
          {
            key                 = "k8s.io/cluster-autoscaler/${var.name}",
            value               = "true",
            propagate_at_launch = "true",
          },
        ]
  }]])
}

data "aws_subnet" "nodes" {
  count = length(var.node_subnet_ids)
  id    = var.node_subnet_ids[count.index]
}

data "aws_eks_cluster" "cluster" {
  count = var.enable ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.enable ? 1 : 0
  name  = module.eks.cluster_id
}

resource "aws_key_pair" "main" {
  count      = var.public_key == "" ? 0 : 1
  key_name   = var.name
  public_key = var.public_key
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "15.2.0"

  config_output_path = pathexpand(var.kubeconfig_path)
  create_eks         = var.enable
  cluster_name       = var.name
  cluster_version    = var.k8s_version
  map_accounts       = var.iam_accounts
  map_roles          = var.iam_roles
  map_users          = var.iam_users
  subnets            = var.node_subnet_ids
  vpc_id             = var.vpc_id

  wait_for_cluster_cmd = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
  worker_groups        = local.kube_worker_group
  write_kubeconfig     = var.write_kubeconfig
}

resource "null_resource" "cluster_status" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
    environment = {
      ENDPOINT = element(concat(data.aws_eks_cluster.cluster[*].endpoint, tolist([])), 0)
    }
  }
}

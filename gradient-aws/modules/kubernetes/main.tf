data "aws_ami" "eks_cpu" {
    most_recent      = true
    name_regex       = "^amazon-eks-node-${var.k8s_version}.*"
    owners = ["602401143452"]
}

data "aws_ami" "eks_gpu" {
    most_recent      = true
    name_regex       = "^amazon-eks-gpu-node-${var.k8s_version}.*"
    owners = ["602401143452"]
}

locals {
    asg_max_size_default = 600
    cpu_ami_id = data.aws_ami.eks_cpu.id
    root_volume_size_default = 50

    node_ami_ids = {
        "services-small"=local.cpu_ami_id,
        "services-medium"=local.cpu_ami_id,
        "services-large"=local.cpu_ami_id,

        "experiment-cpu-small"=local.cpu_ami_id,
        "experiment-cpu-medium"=local.cpu_ami_id,

        "model-deployment-cpu-small"=local.cpu_ami_id,
        "model-deployment-cpu-medium"=local.cpu_ami_id,

        "notebook-cpu-small"=local.cpu_ami_id,
        "notebook-cpu-medium"=local.cpu_ami_id,

        "tensorboard-cpu-small"=local.cpu_ami_id,
        "tensorboard-cpu-medium"=local.cpu_ami_id,
    }

    node_instance_types = merge({
        # Make sure services-small persists
        # servies med/large delete
        "services-small"="c5.xlarge",
        "services-medium"="c5.xlarge",
        "services-large"="c5.2xlarge",

        "experiment-cpu-small"="c5.xlarge",
        "experiment-cpu-medium"="c5.4xlarge",
        "experiment-gpu-small"="p2.xlarge",
        "experiment-gpu-medium"="p3.2xlarge",
        "experiment-gpu-large"="p3.16xlarge",

        "model-deployment-cpu-small"="c5.xlarge",
        "model-deployment-cpu-medium"="c5.4xlarge",
        "model-deployment-gpu-small"="p2.xlarge",
        "model-deployment-gpu-medium"="p3.2xlarge",
        "model-deployment-gpu-large"="p3.16xlarge",

        "notebook-cpu-small"="c5.xlarge",
        "notebook-cpu-medium"="c5.4xlarge",
        "notebook-gpu-small"="p2.xlarge",
        "notebook-gpu-medium"="p3.2xlarge",
        "notebook-gpu-large"="p3.16xlarge",

        "tensorboard-cpu-small"="c5.xlarge",
        "tensorboard-cpu-medium"="c5.4xlarge",
        "tensorboard-gpu-small"="p2.xlarge",
        "tensorboard-gpu-medium"="p3.2xlarge",
        "tensorboard-gpu-large"="p3.16xlarge",
    }, var.node_instance_types)

    node_asg_desired_sizes = {
        "services-small"=0,
        "services-medium"=0,
        "services-large"=0,

        "experiment-cpu-small"=0,
        "experiment-cpu-medium"=0,
        "experiment-gpu-small"=0,
        "experiment-gpu-medium"=0,
        "experiment-gpu-large"=0

        "model-deployment-cpu-small"=0,
        "model-deployment-cpu-medium"=0,
        "model-deployment-gpu-small"=0,
        "model-deployment-gpu-medium"=0,
        "model-deployment-gpu-large"=0

        "notebook-cpu-small"=0,
        "notebook-cpu-medium"=0,
        "notebook-gpu-small"=0,
        "notebook-gpu-medium"=0,
        "notebook-gpu-large"=0,

        "tensorboard-cpu-small"=0,
        "tensorboard-cpu-medium"=0,
        "tensorboard-gpu-small"=0,
        "tensorboard-gpu-medium"=0,
        "tensorboard-gpu-large"=0,
    }

    node_asg_min_sizes = merge({
        "services-small"=1,
        "services-medium"=0,
        "services-large"=0,

        "experiment-cpu-small"=1,
        "experiment-cpu-medium"=0,
        "experiment-gpu-small"=0,
        "experiment-gpu-medium"=0,
        "experiment-gpu-large"=0

        "model-deployment-cpu-small"=1,
        "model-deployment-cpu-medium"=0,
        "model-deployment-gpu-small"=0,
        "model-deployment-gpu-medium"=0,
        "model-deployment-gpu-large"=0

        "notebook-cpu-small"=1,
        "notebook-cpu-medium"=0,
        "notebook-gpu-small"=0,
        "notebook-gpu-medium"=0,
        "notebook-gpu-large"=0,

        "tensorboard-cpu-small"=1,
        "tensorboard-cpu-medium"=0,
        "tensorboard-gpu-small"=0,
        "tensorboard-gpu-medium"=0,
        "tensorboard-gpu-large"=0,
    }, var.node_asg_min_sizes)

    node_asg_max_sizes = merge({
        "services-small"=local.asg_max_size_default,
        "services-medium"=local.asg_max_size_default,
        "services-large"=local.asg_max_size_default,

        "experiment-cpu-small"=local.asg_max_size_default,
        "experiment-cpu-medium"=local.asg_max_size_default,
        "experiment-gpu-small"=local.asg_max_size_default,
        "experiment-gpu-medium"=local.asg_max_size_default,
        "experiment-gpu-large"=local.asg_max_size_default,

        "model-deployment-cpu-small"=local.asg_max_size_default,
        "model-deployment-cpu-medium"=local.asg_max_size_default,
        "model-deployment-gpu-small"=local.asg_max_size_default,
        "model-deployment-gpu-medium"=local.asg_max_size_default,
        "model-deployment-gpu-large"=local.asg_max_size_default,

        "notebook-cpu-small"=local.asg_max_size_default,
        "notebook-cpu-medium"=local.asg_max_size_default,
        "notebook-gpu-small"=local.asg_max_size_default,
        "notebook-gpu-medium"=local.asg_max_size_default,
        "notebook-gpu-large"=local.asg_max_size_default,

        "tensorboard-cpu-small"=local.asg_max_size_default,
        "tensorboard-cpu-medium"=local.asg_max_size_default,
        "tensorboard-gpu-small"=local.asg_max_size_default,
        "tensorboard-gpu-medium"=local.asg_max_size_default,
        "tensorboard-gpu-large"=local.asg_max_size_default,
    }, var.node_asg_max_sizes)

    node_types = [
        "services-small",

        "experiment-cpu-small",
        "experiment-cpu-medium",

        "model-deployment-cpu-small",
        "model-deployment-cpu-medium",

        "notebook-cpu-small",
        "notebook-cpu-medium",

        "tensorboard-cpu-small",
        "tensorboard-cpu-medium"
    ]

    node_pool_types = {
        "services-small"="cpu",
        "services-medium"="cpu",
        "services-large"="cpu",
        "experiment-cpu-small"="cpu",
        "experiment-cpu-medium"="cpu",
        "model-deployment-cpu-small"="cpu",
        "model-deployment-cpu-medium"="cpu",
        "notebook-cpu-small"="cpu",
        "notebook-cpu-medium"="cpu",
        "tensorboard-cpu-small"="cpu",
        "tensorboard-cpu-medium"="cpu",
    }

    kubelet_extra_args = {
        "services-small"=[],

        "experiment-cpu-small"=[],
        "experiment-cpu-medium"=[],

        "model-deployment-cpu-small"=[],
        "model-deployment-cpu-medium"=[],

        "notebook-cpu-small"=[],
        "notebook-cpu-medium"=[],

        "tensorboard-cpu-small"=[],
        "tensorboard-cpu-medium"=[],
    }

    node_volume_sizes = merge({
        "services-small"=local.root_volume_size_default,

        "experiment-cpu-small"=local.root_volume_size_default,
        "experiment-cpu-medium"=local.root_volume_size_default,

        "model-deployment-cpu-small"=local.root_volume_size_default,
        "model-deployment-cpu-medium"=local.root_volume_size_default,

        "notebook-cpu-small"=local.root_volume_size_default,
        "notebook-cpu-medium"=local.root_volume_size_default,

        "tensorboard-cpu-small"=local.root_volume_size_default,
        "tensorboard-cpu-medium"=local.root_volume_size_default,
    }, var.node_asg_max_sizes)

    # ToDo, why are we using the asg max size variable to override the root volume sizes?

    worker_groups = [for node_type in local.node_types : {
        // Can remove if we deprecate EBS
        name = "${node_type}-${data.aws_subnet.nodes[0].availability_zone}"
        subnets = [var.node_subnet_ids[0]]
        additional_security_group_ids = var.node_security_group_ids
        additional_userdata = var.additional_userdata
        #
        ami_id = local.node_ami_ids[node_type]
        ami_id = local.cpu_ami_id 
        asg_force_delete = true
        asg_desired_capacity = local.node_asg_desired_sizes[node_type]
        asg_max_size = local.node_asg_max_sizes[node_type]
        asg_min_size = local.node_asg_min_sizes[node_type]
        instance_type = local.node_instance_types[node_type]
        root_volume_type = "gp2"
        key_name = var.public_key == "" ? "" : aws_key_pair.main[0].id
        kubelet_extra_args = "--node-labels=${join(",",
            concat([
                "paperspace.com/pool-name=${node_type}",
                "paperspace.com/pool-type=${local.node_pool_types[node_type]}",
                "paperspace.com/gradient-worker=${tostring(length(regexall("^services", node_type)) > 0)}",
            ], local.kubelet_extra_args[node_type])
        )}"

        tags = [
            {
                key                 = "k8s.io/cluster-autoscaler/enabled",
                value               = "true",
                propagate_at_launch = "true",
            },
            {
                key = "k8s.io/cluster-autoscaler/node-template/label/paperspace.com/pool-name"
                value = node_type
                propagate_at_launch = "true",
            },
            {
                key                 = "k8s.io/cluster-autoscaler/${var.name}",
                value               = "true",
                propagate_at_launch = "true",
            },
        ]
    }]
}

locals {
    
    # Within each worker node definition there lives a "node_pool_type" that corresponds to this
    # lookup map, enabling us to dynamically select the correct AMI based on worker definition
    ami_lookup = { "cpu" : data.aws_ami.eks_cpu.id, "gpu" : data.aws_ami.eks_gpu.id }
    
    gpu_instance_type_set = toset([
        var.aws_ec2_gpu_instance_p3_16xlarge, 
        var.aws_ec2_gpu_instance_p3_2xlarge,
        var.aws_ec2_gpu_instance_p2_xlarge
    ])


    gpu_worker_groups = flatten([
        for gpu_instance_type in local.gpu_instance_type_set : [
            for worker_node_definition in gpu_instance_type.instance_type_metadata : {
            
            name = "${worker_node_definition.instance_type_name}-${data.aws_subnet.nodes[0].availability_zone}"
            subnets = [var.node_subnet_ids[0]]
            additional_security_group_ids = var.node_security_group_ids
            additional_userdata = var.additional_userdata

            ami_id = local.ami_lookup[worker_node_definition.node_pool_type]
            asg_force_delete = true
            # ToDo, do we want to allow customers to pass in the desired capacity as well?
            asg_desired_capacity = worker_node_definition.default_node_asg_capacities["desired"]
            asg_max_size = lookup(var.node_asg_max_sizes, worker_node_definition.instance_type_name, worker_node_definition.default_node_asg_capacities["max"])
            asg_min_size = lookup(var.node_asg_min_sizes, worker_node_definition.instance_type_name, worker_node_definition.default_node_asg_capacities["min"])
            instance_type = gpu_instance_type.aws_ec2_instance_type
            root_volume_type = worker_node_definition.root_storage_volume_type
            key_name = var.public_key == "" ? "" : aws_key_pair.main[0].id
            kubelet_extra_args = "--node-labels=${join(",",
                concat([
                    "paperspace.com/pool-name=${worker_node_definition.instance_type_name}",
                    "paperspace.com/pool-type=${worker_node_definition.node_pool_type}",
                    "paperspace.com/gradient-worker=${tostring(length(regexall("^services", worker_node_definition.instance_type_name)) > 0)}",
                ],   worker_node_definition.kubelet_extra_args)
            )}"

            tags = [
                {
                    key                 = "k8s.io/cluster-autoscaler/enabled",
                    value               = "true",
                    propagate_at_launch = "true",
                },
                {
                    key = "k8s.io/cluster-autoscaler/node-template/label/paperspace.com/pool-name"
                    value = worker_node_definition.instance_type_name
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
    id = var.node_subnet_ids[count.index]
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
    count = var.public_key == "" ? 0 : 1
    key_name   = var.name
    public_key = var.public_key
}

module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    version = "15.2.0"

    config_output_path = pathexpand(var.kubeconfig_path)
    create_eks = var.enable
    cluster_name    = var.name
    cluster_version = var.k8s_version
    map_accounts = var.iam_accounts
    map_roles = var.iam_roles
    map_users = var.iam_users
    subnets         = var.node_subnet_ids
    vpc_id          = var.vpc_id

    wait_for_cluster_cmd = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
    worker_groups = concat(local.worker_groups, local.gpu_worker_groups)
    write_kubeconfig = var.write_kubeconfig
}

resource "null_resource" "cluster_status" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command     = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
    environment = {
      ENDPOINT = element(concat(data.aws_eks_cluster.cluster[*].endpoint,tolist([])), 0)
    }
  }
}

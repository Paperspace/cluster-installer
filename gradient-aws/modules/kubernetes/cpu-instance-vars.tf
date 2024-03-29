# CPU EC2 Instance Types
# Within this variables file each variable points to a specific EC2 Instance Type
# From there for kube we need to map each of our internal offerings
# worker_group metadata (https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/workers_launch_template.tf#L3)
# instance_type_metadata == our mapping for worker_group variables, please see the link above for an exhaustive list (select the correct release)

variable "aws_ec2_cpu_instance_c5_xlarge" {
  default = {
    aws_ec2_instance_type : "c5.xlarge",
    paperspace_type : "cpu",
    instance_type_metadata = [
      # Services Small
      {
        instance_type_name : "services-small"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 1
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
      # Experiment CPU Small
      {
        instance_type_name : "experiment-cpu-small"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 1
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
      # Model Deployment CPU Small
      {
        instance_type_name : "model-deployment-cpu-small"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 1
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
      # Notebook CPU Small
      {
        instance_type_name : "notebook-cpu-small"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 1
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
      # Tensorboard CPU Small
      {
        instance_type_name : "tensorboard-cpu-small"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 1
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
    ],
  }
}

variable "aws_ec2_cpu_instance_c5_4xlarge" {
  default = {
    aws_ec2_instance_type : "c5.4xlarge",
    paperspace_type : "cpu",
    instance_type_metadata : [
      # Experiment CPU Medium
      {
        instance_type_name : "experiment-cpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
      # Model Deployment CPU Medium
      {
        instance_type_name : "model-deployment-cpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
      # Notebook CPU Medium
      {
        instance_type_name : "notebook-cpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
      # Tensorboard CPU Medium
      {
        instance_type_name : "tensorboard-cpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 20
        }
        node_pool_type : "cpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : []
      },
    ],
  }
}

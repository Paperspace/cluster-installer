# Within this variables file each variable points to a specific EC2 Instace Type
# From there for kube we need to map each of our internal offerings
# worker_group metadata (https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/workers_launch_template.tf#L3)
# instance_type_metadata == our mapping for worker_group variables, please see the link above for an exhaustive list (select the correct release)

variable "aws_ec2_gpu_instance_p3_16xlarge" {
  default = {
    aws_ec2_instance_type : "p3.16xlarge",
    paperspace_type : "gpu",
    instance_type_metadata : {
      # Experiment GPU Large
      "experiment-gpu-large" : {
        instance_type_name : "experiment-gpu-large"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]
      },
      # Model Deployment GPU Large
      "model-deployment-gpu-large" : {
        instance_type_name : "model-deployment-gpu-large"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]

      },
      # Notebook GPU Large
      "notebook-gpu-large" : {
        instance_type_name : "notebook-gpu-large"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]
      },
      # Model Deployment GPU Large
      "model-deployment-gpu-large" : {
        instance_type_name : "model-deployment-gpu-large"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]
      },
      # Tensorboard GPU Large
      "tensorboard-gpu-large" : {
        instance_type_name : "tensorboard-gpu-large"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]
      }
    }
  }
}

variable "aws_ec2_gpu_instance_p3_2xlarge" {
  default = {
    aws_ec2_instance_type : "p3.2xlarge",
    paperspace_type : "gpu",
    instance_type_metadata : {
      # Experiment GPU Medium
      "experiment-gpu-medium" : {
        instance_type_name : "experiment-gpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]
      },
      # Model Deployment GPU Medium
      "model-deployment-gpu-medium" : {
        instance_type_name : "model-deployment-gpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]

      },
      # Notebook GPU Medium
      "notebook-gpu-medium" : {
        instance_type_name : "notebook-gpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]
      },
      # Model Deployment GPU Medium
      "model-deployment-gpu-medium" : {
        instance_type_name : "model-deployment-gpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]
      },
      # Tensorboard GPU Medium
      "tensorboard-gpu-medium" : {
        instance_type_name : "tensorboard-gpu-medium"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-v100"]
      }
    }
  }
}

variable "aws_ec2_gpu_instance_p2_xlarge" {
  default = {
    aws_ec2_instance_type : "p2.xlarge",
    paperspace_type : "gpu",
    instance_type_metadata : {
      # Experiment GPU Small
      "experiment-gpu-small" : {
        instance_type_name : "experiment-gpu-small",

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-k80",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-k80"]
      },
      # Model Deployment GPU Small
      "model-deployment-gpu-small" : {
        instance_type_name : "model-deployment-gpu-small"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-k80",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-k80"]

      },
      # Notebook GPU Small
      "notebook-gpu-small" : {
        instance_type_name : "notebook-gpu-small"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-k80",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-k80"]
      },
      # Tensorboard GPU Small
      "tensorboard-gpu-small" : {
        instance_type_name : "tensorboard-gpu-small"

        default_node_asg_capacities : {
          "desired" : 0
          "min" : 0
          "max" : 600
        }
        node_pool_type : "gpu"
        root_storage_volume_type : "gp2"

        root_volume_size : 50
        kubelet_extra_args : [
          "cloud.google.com/gke-accelerator=nvidia-tesla-k80",
        "k8s.amazonaws.com/accelerator=nvidia-tesla-k80"]

      }
    }
  }
}
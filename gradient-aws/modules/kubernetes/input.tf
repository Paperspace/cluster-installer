variable "name" {
  description = "Name"
}

variable "enable" {
  type        = bool
  description = "If module should be enabled"
}

variable "additional_userdata" {
  description = "Append user data"
  default     = ""
}

variable "iam_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
}

variable "iam_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

variable "iam_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}

variable "kubeconfig_path" {
  description = "Kubeconfig output path"
}

variable "node_asg_max_sizes" {
  description = "Node auto scaling group max sizes"
}

variable "node_asg_min_sizes" {
  description = "Node auto scaling group min sizes"
}

# Allows you to override our default instance type associations
# For example within var.aws_ec2_gpu_instance_p3_16xlarge, the instance_type_metadata.instance_type_name 
# for experiment-gpu-medium is p3.2xlarge, and if you want to override it you would provide
# var.node_instance_types = { "experiment-gpu-medium" = "some other ec2 instance type" }

variable "node_instance_types" {
  description = "Node instance type"
  type        = map(string)
}

variable "node_security_group_ids" {
  description = "Node security group ids"
}

variable "node_subnet_ids" {
  description = "Node subnet ids"
}

variable "k8s_version" {
  description = "Kubernetes version"
}

variable "public_key" {
  description = "Login public key name"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "write_kubeconfig" {
  description = "Write kubeconfig to a file"
}
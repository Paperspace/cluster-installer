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

# node_instance_types (Node Instance Types)
# These instance types correspond to AWS EC2 Instance Types (i.e. virtual machines)
# AWS EC2 Instance Type Reference: (https://aws.amazon.com/ec2/instance-types/)
# EC2 Instance Type Terraform Reference: (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type)
# Internally, these instance types are mapped to our provisioning resources 
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
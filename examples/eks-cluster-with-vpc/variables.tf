variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
variable "managed_node_instance_type" {
  description = "Instance type for the cluster managed node groups"
  type        = string
  default     = "t3.xlarge"
}
variable "managed_node_min_size" {
  description = "Minumum number of instances in the node group"
  type        = number
  default     = 2
}
variable "eks_version" {
  type        = string
  description = "EKS Cluster version"
  default     = "1.24"
}

### fluentbit_opensearch vars
variable "create_iam_service_linked_role" {
  description = "Whether to create the AWSServiceRoleForAmazonElasticsearchService role used by the OpenSearch service"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
  default     = ""
}

variable "vpc_cidr_block" {
  description = "VPC cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "VPC cidr"
  type        = list(any)
}

variable "opensearch_dashboard_user" {
  description = "OpenSearch dashboard user"
  type        = string
}

variable "opensearch_dashboard_pw" {
  description = "OpenSearch dashboard user password"
  type        = string
  sensitive   = true
}

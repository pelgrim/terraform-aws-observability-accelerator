variable "create_iam_service_linked_role" {
  description = "Whether to create the AWSServiceRoleForAmazonElasticsearchService role used by the OpenSearch service"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "eks_cluster_id" {
  description = "EKS cluster id"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC cidr"
  type        = string
}

variable "private_subnets" {
  description = "VPC cidr"
  type        = list
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

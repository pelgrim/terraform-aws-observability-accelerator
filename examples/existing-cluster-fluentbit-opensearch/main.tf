provider "aws" {
  region = var.aws_region
}

module "fluentbit_opensearch" {
  source                         = "../../modules/eks-monitoring/patterns/fluentbit_opensearch"
  eks_cluster_id                 = var.cluster_name
  vpc_cidr_block                 = var.vpc_cidr_block
  private_subnets                 = var.private_subnets
  opensearch_dashboard_user      = var.opensearch_dashboard_user
  opensearch_dashboard_pw        = var.opensearch_dashboard_pw
  create_iam_service_linked_role = var.create_iam_service_linked_role
  vpc_id                         = var.vpc_id
  aws_region = var.aws_region
}
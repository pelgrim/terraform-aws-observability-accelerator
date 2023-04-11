provider "aws" {
  region = var.aws_region
}

locals {
  name        = "aws-observability-accelerator"
  description = "Amazon Managed Grafana workspace for ${local.name}"

  tags = {
    GithubRepo = "terraform-aws-observability-accelerator"
    GithubOrg  = "aws-observability"
  }
  vpc_configuration = { subnet_ids = var.private_subnets }
  
  security_group_rules = {
    outbound = {
      type              = "egress"
      from_port         = 0
      to_port           = 65535
      protocol          = "all"
      cidr_blocks  = ["0.0.0.0/0"]
    }
    inbound = {
      type              = "ingress"
      from_port         = 0
      to_port           = 65535
      protocol          = "all"
      cidr_blocks  = ["0.0.0.0/0"]
    }
  }
}

module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "1.8.0"

  name                      = local.name
  associate_license         = false
  description               = local.description
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  notification_destinations = ["SNS"]
  stack_set_name            = local.name

  configuration = jsonencode({
    unifiedAlerting = {
      enabled = true
    }
  })
  
  vpc_configuration = length(var.private_subnets) > 0 ? local.vpc_configuration : {}
  security_group_rules = length(var.private_subnets) > 0 ? local.security_group_rules : {}

  # Workspace IAM role
  create_iam_role                = true
  iam_role_name                  = local.name
  use_iam_role_name_prefix       = true
  iam_role_description           = local.description
  iam_role_path                  = "/grafana/"
  iam_role_force_detach_policies = true
  iam_role_max_session_duration  = 7200
  iam_role_tags                  = local.tags

  tags = local.tags
}

data "aws_vpc" "this" {
  count = var.vpc_id == "" ? 0 : 1
  id = var.vpc_id
}

resource "aws_vpc_endpoint" "grafana_cloudwatch_metrics" {
  count = var.vpc_id == "" ? 0 : 1
  vpc_id       = data.aws_vpc.this[0].id
  service_name = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    module.managed_grafana.security_group_id,
  ]
  subnet_ids          = var.private_subnets
  private_dns_enabled = true
  tags = local.tags
}

resource "aws_vpc_endpoint" "grafana_cloudwatch_logs" {
  count = var.vpc_id == "" ? 0 : 1
  vpc_id       = data.aws_vpc.this[0].id
  service_name = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    module.managed_grafana.security_group_id,
  ]
  subnet_ids          = var.private_subnets
  private_dns_enabled = true
  tags = local.tags
}

resource "aws_vpc_endpoint" "grafana_xray" {
  count = var.vpc_id == "" ? 0 : 1
  vpc_id       = data.aws_vpc.this[0].id
  service_name = "com.amazonaws.${var.aws_region}.xray"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    module.managed_grafana.security_group_id,
  ]
  subnet_ids          = var.private_subnets
  private_dns_enabled = true
  tags = local.tags
}

resource "aws_vpc_endpoint" "grafana_amp" {
  count = var.vpc_id == "" ? 0 : 1
  vpc_id       = data.aws_vpc.this[0].id
  service_name = "com.amazonaws.${var.aws_region}.aps"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    module.managed_grafana.security_group_id,
  ]
  subnet_ids          = var.private_subnets
  private_dns_enabled = true
  tags = local.tags
}

resource "aws_vpc_endpoint" "grafana_ampws" {
  count = var.vpc_id == "" ? 0 : 1
  vpc_id       = data.aws_vpc.this[0].id
  service_name = "com.amazonaws.${var.aws_region}.aps-workspaces"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    module.managed_grafana.security_group_id,
  ]
  subnet_ids          = var.private_subnets
  private_dns_enabled = true
  tags = local.tags
}

provider "grafana" {
  url  = "https://${module.managed_grafana.workspace_endpoint}"
  auth = module.managed_grafana.workspace_api_keys.admin.key
}

# New Grafana Workspace

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
  
  vpc_configuration = {
    subnet_ids = var.private_subnets
  }
  
  workspace_api_keys = {
    admin = {
      key_name        = "admin"
      key_role        = "ADMIN"
      seconds_to_live = 3600
    }
  }


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

locals {
  region          = var.aws_region
  name            = "aws-observability-accelerator-os"
  description = "Amazon Managed Grafana workspace for ${local.name}"

  tags = {
    GithubRepo = "terraform-aws-observability-accelerator"
    GithubOrg  = "aws-observability"
  }
}

resource "grafana_folder" "this" {
  title = "OpenSearch monitoring dashboards"
}

resource "grafana_data_source" "opensearch" {
  type = "grafana-opensearch-datasource"
  name = local.name
  url  = "https://${module.fluentbit_opensearch.opensearch_url}"
  is_default = false
  json_data_encoded = jsonencode({
    database                   = "fluent-bit"
    default_region             = var.aws_region
    flavor                     = "opensearch"
    logMessageField            = "log"
    maxConcurrentShardRequests = 5
    pplEnabled                 = true
    sigV4Auth                  = true
    sigV4AuthType              = "ec2_iam_role"
    sigV4Region                = var.aws_region
    timeField                  = "@timestamp"
    version                    = "1.0.0"
  })
}

resource "grafana_dashboard" "opensearch" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/opensearch.json")
}

provider "aws" {
  region = var.aws_region
}

provider "grafana" {
  url  = local.amg_ws_endpoint
  auth = var.grafana_api_key
}

data "aws_grafana_workspace" "this" {
  count        = var.managed_grafana_workspace_id == "" ? 0 : 1
  workspace_id = var.managed_grafana_workspace_id
}

locals {
  region          = var.aws_region
  amg_ws_endpoint = "https://${data.aws_grafana_workspace.this[0].endpoint}"
  name            = "aws-observability-accelerator-opensearch"
}

resource "grafana_folder" "this" {
  title = "OpenSearch monitoring dashboards"
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
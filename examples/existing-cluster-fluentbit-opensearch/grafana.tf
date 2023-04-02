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
  count       = var.managed_grafana_workspace_id == "" ? 0 : 1
  title = "OpenSearch monitoring dashboards"
}

resource "grafana_data_source" "opensearch" {
  count       = var.managed_grafana_workspace_id == "" ? 0 : 1
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
  count       = var.managed_grafana_workspace_id == "" ? 0 : 1
  folder      = grafana_folder.this[0].id
  config_json = file("${path.module}/dashboards/opensearch.json")
}

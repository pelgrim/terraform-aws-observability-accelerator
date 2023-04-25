provider "grafana" {
  url  = "https://${data.aws_grafana_workspace.this.endpoint}"
  auth = var.grafana_api_key
}

data "aws_grafana_workspace" "this" {
  workspace_id = var.managed_grafana_workspace_id
}

resource "grafana_folder" "this" {
  title = "OpenSearch monitoring dashboards"
}

resource "grafana_data_source" "opensearch" {
  type = "grafana-opensearch-datasource"
  name = "observability-accelerator-opensearch"
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

# data "aws_eks_cluster" "example" {
#   name = var.eks_cluster_id
# }

# output "endpoint" {
#   endpoint = data.aws_eks_cluster.example.endpoint
# }

data "aws_caller_identity" "current" {}


data "aws_region" "current" {}

data "aws_iam_policy_document" "fluentbit_opensearch_access" {
  # Identity Based Policy specifies a list of IAM permissions
  # that principal has against OpenSearch service API
  # ref: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/ac.html#ac-types-identity
  statement {
    sid       = "OpenSearchAccess"
    effect    = "Allow"
    resources = ["${aws_elasticsearch_domain.opensearch.arn}/*"]
    actions   = ["es:ESHttp*"]
  }
}

data "aws_iam_policy_document" "opensearch_access_policy" {
  # This is the resource-based policy that allows to set access permissions on OpenSearch level
  # To be working properly the client must support IAM (SDK, fluent-bit with sigv4, etc.) Browsers don't do IAM.
  # ref: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/ac.html#ac-types-resource
  statement {
    sid       = "WriteDomainLevelAccessToOpenSearch"
    effect    = "Allow"
    resources = ["*"]
    actions = [                                                  
      "es:ESHttpPost",
      "es:ESHttpPut"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid    = "AdminDomainLevelAccessToOpenSearch"
    effect = "Allow"
    resources = [
      "${aws_elasticsearch_domain.opensearch.arn}/*",
    ]
    actions = ["es:*"]
    principals {
      type        = "*"
      identifiers = ["*"] # must be set to wildcard when clients can't sign sigv4 or pass IAM to OpenSearch (aka browsers)
    }
  }
}

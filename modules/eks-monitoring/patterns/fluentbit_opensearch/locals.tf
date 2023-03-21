
locals {
      eks_oidc_provider = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  eks_cluster_version = data.aws_eks_cluster.this.version
  tags = {
    Source = "github.com/aws-observability/terraform-aws-observability-accelerator"
  }
}


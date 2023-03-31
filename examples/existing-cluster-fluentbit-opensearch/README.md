# OpenSearch Observability Pattern

This example demonstrates how to use the AWS Observability Accelerator Terraform
modules to monitor EKS infrastructure with OpenSearch and Amazon Managed Grafana.
The current example deploys Fluent Bit in Amazon EKS with its requirements and
make use of an existing Amazon Managed Grafana workspace.

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)


## Setup

This example uses a local terraform state. If you need states to be saved remotely,
on Amazon S3 for example, visit the [terraform remote states](https://www.terraform.io/language/state/remote) documentation

1. Clone the repo using the command below

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
```

2. Initialize terraform

```console
cd examples/existing-cluster-fluentbit-opensearch
terraform init
```

3. Amazon EKS Cluster

To run this example, you need to provide your EKS cluster name.
If you don't have a cluster ready, visit [this example](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/v4.13.1/examples/eks-cluster-with-new-vpc)
first to create a new one.

Add your cluster name for `eks_cluster_id="..."` to the `terraform.tfvars` or use an environment variable `export TF_VAR_eks_cluster_id=xxx`.
Add your cluster VPC id for `vpc_id="..."` to the `terraform.tfvars` or use an environment variable `export TF_VAR_vpc_id=xxx`.
Add your cluster VPC private subnets for `private_subnets=["<SUBNET_ID_1>","<SUBNET_ID_2>","<SUBNET_ID_3>"]` to the `terraform.tfvars` or use an environment variable `export TF_VAR_private_subnets='["<SUBNET_ID_1>","<SUBNET_ID_2>","<SUBNET_ID_3>"]'`.

4. Amazon Managed Grafana workspace

To run this example you need an Amazon Managed Grafana workspace. If you have an existing workspace, create an environment variable `export TF_VAR_managed_grafana_workspace_id=g-xxx`.
To create a new one, visit our Amazon Managed Grafana [documentation](https://docs.aws.amazon.com/grafana/latest/userguide/getting-started-with-AMG.html).
Make sure to provide the workspace with Amazon Managed Service for Prometheus read permissions.

> In the URL `https://g-xyz.grafana-workspace.eu-central-1.amazonaws.com`, the workspace ID would be `g-xyz`

5. <a name="apikey"></a> Grafana API Key

Amazon Managed Service for Grafana provides a control plane API for generating Grafana API keys. We will provide to Terraform
a short lived API key to run the `apply` or `destroy` command.
Ensure you have necessary IAM permissions (`CreateWorkspaceApiKey, DeleteWorkspaceApiKey`)

```sh
export TF_VAR_grafana_api_key=`aws grafana create-workspace-api-key --key-name "observability-accelerator-$(date +%s)" --key-role ADMIN --seconds-to-live 1200 --workspace-id $TF_VAR_managed_grafana_workspace_id --query key --output text`
```

## Deploy

```sh
terraform apply -var-file=terraform.tfvars
```

or if you had setup environment variables, run

```sh
terraform apply
```

## Additional configuration

For the purpose of the example, we have provided default values for some of the variables.

1. AWS Region

Specify the AWS Region where the resources will be deployed. Edit the `terraform.tfvars` file and modify `aws_region="..."`. You can also use environement variables `export TF_VAR_aws_region=xxx`.

## Visualization

1. OpenSearch datasource on Grafana

After the deployment, run the following commands to grant access for EKS and Grafana into OpenSearch.

```bash
payload='{
  "backend_roles": [
    "<GRAFANA_IAM_ROLE>",
    "<FLUENTBIT_IAM_ROLE>"
  ],
  "hosts": [],
  "users": [
    "<MASTER_USERNAME>",
    "<GRAFANA_IAM_ROLE>",
    "<FLUENTBIT_IAM_ROLE>"
  ]
}'

rolesmapping_url='https://<OPENSEARCH_ENDPOINT>/_plugins/_security/api/rolesmapping'

kubectl run -i curl --image=curlimages/curl --restart=Never --rm=true \
  -- -s -XPUT -u '<MASTER_USERNAME>:<MASTER_PASSWORD>' \
     -H "Content-Type: application/json" \
     --data "$payload" "${rolesmapping_url}/all_access"

kubectl run -i curl --image=curlimages/curl --restart=Never --rm=true \
  -- -s -XPUT -u '<MASTER_USERNAME>:<MASTER_PASSWORD>' \
     -H "Content-Type: application/json" \
     --data "$payload" "${rolesmapping_url}/security_manager"
```

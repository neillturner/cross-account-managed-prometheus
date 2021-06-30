# role assumed by prometheus forwarder in EKS to do remote ingestion 
# assume doing oidc authentication and eks cluster created with standard terraform module   
module "iam_assumable_role_prometheus_remote_ingest" {
  count                         = terraform.workspace == "dev" || terraform.workspace == "prod" ? 1 : 0
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.8.0"
  create_role                   = true
  role_name                     = "prometheus_remote_ingest"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.prometheus_remote_ingest.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:prometheus:prometheus"]
}

data "aws_iam_policy_document" "prometheus_remote_ingest" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.account_id["management"]}:role/prometheus_central_ingest"]
  }
}

resource "aws_iam_policy" "prometheus_remote_ingest" {
  name        = "prometheus_remote_ingest"
  description = "Managed Prometheus remote ingest policy for cluster"
  policy      = data.aws_iam_policy_document.prometheus_remote_ingest.json
}

data "aws_iam_policy_document" "prometheus_central_ingest" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [
                     "arn:aws:iam::${var.account_id["dev"]}:role/prometheus_remote_ingest",
                     "arn:aws:iam::${var.account_id["prod"]}:role/prometheus_remote_ingest",
                    ]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "prometheus_central_ingest" {
  name                 = "prometheus_central_ingest"
  assume_role_policy   = data.aws_iam_policy_document.prometheus_central_ingest.json
}

resource "aws_iam_role_policy_attachment" "prometheus_central_ingest" {
  role       = aws_iam_role.prometheus_central_ingest.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}



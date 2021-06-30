resource "aws_prometheus_workspace" "analytical_platform_dev" {
  count = terraform.workspace == "management" ? 1 : 0
  alias = "analytical-platform-dev"
}

resource "aws_prometheus_workspace" "analytical_platform_prod" {
  count = terraform.workspace == "management" ? 1 : 0
  alias = "analytical-platform-prod"
}


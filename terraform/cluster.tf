module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "17.0.1"
  cluster_name                    = local.cluster_name
  cluster_version                 = local.account.cluster_version
  subnets                         = module.vpc.private_subnets
  tags                            = local.tags
  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_id                          = module.vpc.vpc_id
  enable_irsa                     = true
  cluster_endpoint_private_access = true

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  node_groups_defaults = {
    ami_type         = "AL2_x86_64" # Amazon Linux 2
    disk_size        = 250
    desired_capacity = 1
    max_capacity     = 10
    min_capacity     = 1
    instance_types    = ["r5.2xlarge"]
  }

  node_groups = {   
    managed_nodes = {
    }
  }
}  

resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}


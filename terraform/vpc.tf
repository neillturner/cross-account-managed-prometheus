module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name                 = "${terraform.workspace}-vpc"
  cidr                 = local.account.cidr
  azs                  = ["eu-west-1a","eu-west-1b","eu-west-1c"]
  private_subnets      = local.account.private_subnets
  public_subnets       = local.account.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
}

# allow access from EKS cluster to VPC endpoint for managed prometheus
# assuming vpc and eks created with standard terraform modules   
resource "aws_security_group" "aps" {
  name        = "aps"
  description = "allow EKS cluster to access VPC endpoint for managed prometheus"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [module.eks.cluster_primary_security_group_id]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# vpc endpoint for private access for remote ingestion to managed prometheus 
# assuming vpc created with standard terraform module  
resource "aws_vpc_endpoint" "aps" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.aps-workspaces"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.aps.id]
}
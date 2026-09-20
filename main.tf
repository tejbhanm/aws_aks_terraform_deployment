module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-cost-optimized-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["ap-south-1a", "ap-south-1b"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  # Disabled to eliminate ~$32/month NAT Gateway cost
  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tag subnets so AWS Load Balancers know where to deploy
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "dev-cost-optimized-eks"
  cluster_version = "1.30"

  # Public access enabled to manage cluster without VPN/bastion
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    spot_node = {
      # t3.micro is free-tier eligible; use t3.small if system pods crash
      instance_types = ["t3.micro", "t3.small"]
      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      # Required for nodes in public subnets without a NAT Gateway
      subnet_ids               = module.vpc.public_subnets
      associate_public_ip_address = true
    }
  }
}
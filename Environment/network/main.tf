#################################################
# VPC MODULE
#################################################

module "vpc" {

  source = "../../Modules/VPC"
  

  #################################################
  # ENVIRONMENT
  #################################################

  environment = var.environment

  #################################################
  # REGION
  #################################################

  aws_region = var.aws_region

  #################################################
  # NETWORK
  #################################################

  vpc_cidr = var.vpc_cidr

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets

  availability_zones = var.availability_zones
}
module "enterprise_network" {

  source = "../../infrastructure"

  aws_region = var.aws_region

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  instance_type = var.instance_type

  root_volume_size = var.root_volume_size

  enable_detailed_monitoring = var.enable_detailed_monitoring

}
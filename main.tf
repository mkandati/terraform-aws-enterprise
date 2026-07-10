module "vpc" {

  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  project_name         = var.project_name
  common_tags          = local.common_tags
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
}

module "subnet" {

  source               = "./modules/subnet"
  vpc_id               = module.vpc.vpc_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_name         = var.project_name
  environment          = var.environment
  common_tags          = local.common_tags
}

module "internet_gateway" {

  source       = "./modules/internet-gateway"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

module "public_route_table" {

  source              = "./modules/public-route-table"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  public_subnet_ids   = module.subnet.public_subnet_ids
  project_name        = var.project_name
  environment         = var.environment
  common_tags         = local.common_tags

}

module "nat_gateway" {

  source           = "./modules/nat-gateway"
  public_subnet_id = module.subnet.public_subnet_ids[0]
  project_name     = var.project_name
  environment      = var.environment
  common_tags      = local.common_tags

}

module "private_route_table" {

  source             = "./modules/private-route-table"
  vpc_id             = module.vpc.vpc_id
  nat_gateway_id     = module.nat_gateway.nat_gateway_id
  private_subnet_ids = module.subnet.private_subnet_ids
  project_name       = var.project_name
  environment        = var.environment
  common_tags        = local.common_tags

}

module "ec2_security_group" {

  source                     = "./modules/security-group"
  vpc_id                     = module.vpc.vpc_id
  security_group_name        = "web-sg"
  security_group_description = "Web Server Security Group"

  ingress_rules = [

    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ]

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

}

module "iam" {

  source              = "./modules/iam"
  role_name           = "ec2-role"
  managed_policy_arns = var.managed_policy_arns
  project_name        = var.project_name
  environment         = var.environment
  common_tags         = local.common_tags

}

module "ec2" {

  source = "./modules/ec2"

  subnet_id            = module.subnet.private_subnet_ids[0]
  security_group_id    = module.ec2_security_group.security_group_id
  iam_instance_profile = module.iam.instance_profile_name

  ami_id                     = var.ami_id
  instance_type              = var.instance_type
  root_volume_size           = var.root_volume_size
  enable_detailed_monitoring = var.enable_detailed_monitoring

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

module "alb_security_group" {

  source                     = "./modules/security-group"
  security_group_name        = "alb-sg"
  security_group_description = "Security Group for Application Load Balancer"
  vpc_id                     = module.vpc.vpc_id

  ingress_rules = [

    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ]

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags

}

module "alb" {

  source              = "./modules/alb"
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.subnet.public_subnet_ids
  security_group_id   = module.alb_security_group.security_group_id
  internal            = false
  deletion_protection = false
  idle_timeout        = 60
  common_tags         = local.common_tags

}

module "target_group" {

  source                = "./modules/target-group"
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  port                  = 80
  protocol              = "HTTP"
  target_type           = "instance"
  health_check_path     = "/"
  health_check_protocol = "HTTP"
  health_check_matcher  = "200"
  common_tags           = local.common_tags
}


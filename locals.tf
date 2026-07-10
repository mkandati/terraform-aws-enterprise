locals {

  common_tags = {

    Project     = "Enterprise-Network"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Cloud-Team"

  }

}
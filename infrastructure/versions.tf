terraform {

  required_version = ">= 1.10.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }

  backend "s3" {

    bucket         = "enterprise-network-prod-terraform-state-c62bd2"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "enterprise-network-prod-terraform-lock"
    encrypt        = true

  }

}
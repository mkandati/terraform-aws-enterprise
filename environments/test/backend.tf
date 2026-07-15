terraform {

  backend "s3" {
    bucket          = "enterprise-network-prod-terraform-state-c62bd2"
    key             = "test/terraform.tfstate"
    region          = "ap-south-1"
    dynamodb_table  = "enterprise-network-prod-terraform-lock"
    encrypt         = true
  }

}
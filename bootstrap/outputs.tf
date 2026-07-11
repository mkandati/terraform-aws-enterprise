############################################
# Terraform State Bucket Name
############################################

output "terraform_state_bucket_name" {

  description = "Terraform remote state S3 bucket name"
  value       = aws_s3_bucket.terraform_state.bucket

}

############################################
# DynamoDB Lock Table Name
############################################

output "terraform_lock_table_name" {

  description = "Terraform state lock DynamoDB table"
  value       = aws_dynamodb_table.terraform_lock.name

}

############################################
# AWS Region
############################################

output "aws_region" {

  description = "AWS Region"
  value       = var.aws_region

}
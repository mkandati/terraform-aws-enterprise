############################################
# Random ID for Unique S3 Bucket Name
############################################

resource "random_id" "suffix" {
  byte_length = 3
}

############################################
# S3 Bucket for Terraform Remote State
############################################

resource "aws_s3_bucket" "terraform_state" {

  bucket        = "${var.project_name}-${var.environment}-terraform-state-${random_id.suffix.hex}"
  force_destroy = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-terraform-state"
    }
  )

}

############################################
# S3 Bucket Versioning
############################################

resource "aws_s3_bucket_versioning" "terraform_state" {

  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# Server Side Encryption
############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {

  bucket = aws_s3_bucket.terraform_state.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"

    }
  }

  depends_on = [
    aws_s3_bucket.terraform_state
  ]
}

############################################
# Block Public Access
############################################

resource "aws_s3_bucket_public_access_block" "terraform_state" {

  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.terraform_state
  ]
}

############################################
# Ownership Controls
############################################

resource "aws_s3_bucket_ownership_controls" "terraform_state" {

  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [
    aws_s3_bucket.terraform_state
  ]
}

############################################
# DynamoDB Table for Terraform State Locking
############################################

resource "aws_dynamodb_table" "terraform_lock" {

  name = "${var.project_name}-${var.environment}-terraform-lock"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-terraform-lock"
    }
  )

}
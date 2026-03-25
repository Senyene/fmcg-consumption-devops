# --- TERRAFORM CONFIGURATION FOR S3 WEBSITE ---

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "id" {
  byte_length = 4
}

resource "aws_s3_bucket" "dashboard_bucket" {
  bucket = "fmcg-consumption-dashboard-${random_id.id.hex}"
}

# Unlock public access at the bucket level
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.dashboard_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Set ownership controls to allow ACLs (necessary for public-read ACL)
resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.dashboard_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Grant public read access using an ACL (no bucket policy)
resource "aws_s3_bucket_acl" "public_read_acl" {
  bucket = aws_s3_bucket.dashboard_bucket.id
  acl    = "public-read"

  depends_on = [
    aws_s3_bucket_public_access_block.public_access,
    aws_s3_bucket_ownership_controls.owner
  ]
}

# Configure as a static website
resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.dashboard_bucket.id
  index_document {
    suffix = "index.html"
  }
}

output "website_url" {
  description = "The public URL of the FMCG Dashboard"
  value       = aws_s3_bucket_website_configuration.config.website_endpoint
}

output "bucket_name" {
  description = "The exact name of the generated S3 bucket"
  value       = aws_s3_bucket.dashboard_bucket.id
}

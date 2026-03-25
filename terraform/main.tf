# --- TERRAFORM CONFIGURATION FOR S3 WEBSITE ---

# The Provider block tells Terraform which cloud service we are using.
# We are using AWS in the 'us-east-1' region (North Virginia).
provider "aws" {
  region = "us-east-1" 
}

# This creates a 'random_id' so that your bucket name is unique globally.
# S3 bucket names must be unique across all of AWS, not just your account.
resource "random_id" "id" {
  byte_length = 4
}

# This is the main S3 Bucket resource. Think of it as a folder in the cloud.
# We use the random ID from above to ensure the name doesn't clash with others.
resource "aws_s3_bucket" "dashboard_bucket" {
  bucket = "fmcg-consumption-dashboard-${random_id.id.hex}" 
}

# By default, AWS buckets are private (locked). 
# This block 'unlocks' the bucket so it can be seen by the public internet.
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.dashboard_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# This tells AWS: "Treat this bucket like a website, not just a storage folder."
# It looks for 'index.html' whenever someone visits the URL.
resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.dashboard_bucket.id
  index_document {
    suffix = "index.html"
  }
}

# This 'Output' prints the final website address to your screen 
# once the Robot (GitHub) finishes building it.
output "website_url" {
  description = "The public URL of the FMCG Dashboard"
  value       = aws_s3_bucket_website_configuration.config.website_endpoint
}

# NEW: Directly output the exact bucket name so GitHub Actions doesn't have to parse URLs.
output "bucket_name" {
  description = "The exact name of the generated S3 bucket"
  value       = aws_s3_bucket.dashboard_bucket.id
}

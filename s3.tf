# Create S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name
}

# Bucket ownership controls to disable ACLs (BucketOwnerPreferred)
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"  # disables ACLs, bucket owner owns all objects
  }
}

# Disable block public access settings at bucket level to allow public policies
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Upload website files WITHOUT ACLs (ACLs not supported when ownership controls disable ACLs)
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "style.css"
  source       = "style.css"
  content_type = "text/css"
}

resource "aws_s3_object" "script" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "script.js"
  source       = "script.js"
  content_type = "text/javascript"
}

# Add a bucket policy to allow public read access to objects
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.mybucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowPublicRead"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = ["${aws_s3_bucket.mybucket.arn}/*"]
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.example]
}

# S3 website configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  # Depends on policy to be created before website config
  depends_on = [aws_s3_bucket_policy.public_read_policy]
}

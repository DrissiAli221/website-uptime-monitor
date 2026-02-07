resource "aws_s3_bucket" "frontend" {
  bucket = "uptime-monitor-dashboard-ali-2025"
}

# disable block public access 
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# bucket policy (read access)
resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Action    = "s3:GetObject"
      Principal = "*",
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

# website hosting 
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

# upload the file
resource "aws_s3_object" "html" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${path.module}/frontend/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/frontend/index.html")
}

resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "app.js"
  source       = "${path.module}/frontend/app.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/frontend/app.js")
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.hosting.website_endpoint
}

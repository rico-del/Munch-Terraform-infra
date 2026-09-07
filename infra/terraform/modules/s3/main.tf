resource "aws_s3_bucket" "media" {
  bucket        = "${var.name_prefix}-media-${var.account_id}"
  force_destroy = false

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-media"
    Purpose     = "PortfolioMediaStorage"
    Environment = var.environment
  })
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "media" {
  bucket     = aws_s3_bucket.media.id
  depends_on = [aws_s3_bucket_versioning.media]

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {
      prefix = "portfolio_images/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

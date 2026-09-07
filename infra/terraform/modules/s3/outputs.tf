output "bucket_id" {
  value       = aws_s3_bucket.media.id
  description = "S3 bucket ID."
}

output "bucket_name" {
  value       = aws_s3_bucket.media.bucket
  description = "S3 bucket name."
}

output "bucket_arn" {
  value       = aws_s3_bucket.media.arn
  description = "S3 bucket ARN."
}

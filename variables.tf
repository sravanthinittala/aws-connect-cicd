variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 Bucket Name"
  default     = "connect-iac"
}
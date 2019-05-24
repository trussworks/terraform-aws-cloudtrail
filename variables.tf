variable "log_retention_days" {
  description = "Number of days to keep AWS logs around in specific log group."
  default     = 90
  type        = "string"
}

variable "s3_bucket_name" {
  description = "The name of the AWS S3 bucket."
  type        = "string"
}

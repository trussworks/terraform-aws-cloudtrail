variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group that receives CloudTrail events."
  default     = "cloudtrail-events"
  type        = string
}

variable "enabled" {
  description = "Enables logging for the trail. Defaults to true. Setting this to false will pause logging."
  default     = true
  type        = bool
}

variable "s3_bucket_name" {
  description = "The name of the AWS S3 bucket."
  type        = string
}

variable "org_trail" {
  description = "Whether or not this is an organization trail. Only valid in master account."
  default     = "false"
  type        = string
}

variable "encrypt_cloudtrail" {
  description = "Whether or not to use a custom KMS key to encrypt CloudTrail logs."
  default     = "false"
  type        = string
}

variable "key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be 7-30 days.  Default 30 days."
  default     = 30
  type        = string
}

variable "trail_name" {
  description = "Name for the Cloudtrail"
  default     = "cloudtrail"
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix for CloudTrail logs"
  default     = "cloudtrail"
  type        = string
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to keep the CloudTrail logs in the CloudWatch log group."
  default     = 90
  type        = string
}

variable "cloudwatch_log_group_kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt the CloudWatch log group storing CloudTrail logs.  If blank, then logs are unencrypted."
  type        = string
  default     = ""
}

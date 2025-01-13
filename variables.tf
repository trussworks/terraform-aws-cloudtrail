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

variable "log_retention_days" {
  description = "Number of days to keep AWS logs around in specific log group."
  default     = 90
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the AWS S3 bucket."
  type        = string
}

variable "s3_bucket_account_id" {
  description = "(optional) The AWS account ID which owns the S3 bucket. Only include if the S3 bucket is in a different account than the CloudTrail."
  default     = null
  type        = string
}

variable "org_trail" {
  description = "Whether or not this is an organization trail. Only valid in master account."
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

variable "iam_role_name" {
  description = "Name for the CloudTrail IAM role"
  default     = "cloudtrail-cloudwatch-logs-role"
  type        = string
}

variable "iam_policy_name" {
  description = "Name for the CloudTrail IAM policy"
  default     = "cloudtrail-cloudwatch-logs-policy"
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix for CloudTrail logs"
  default     = "cloudtrail"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notification of log file delivery."
  default     = ""
  type        = string
}

variable "tags" {
  description = "A mapping of tags to CloudTrail resources."
  default     = {}
  type        = map(string)
}

variable "api_call_rate_insight" {
  description = "A measurement of write-only management API calls that occur per minute against a baseline API call volume."
  default     = false
  type        = bool
}

variable "api_error_rate_insight" {
  description = "A measurement of management API calls that result in error codes. The error is shown if the API call is unsuccessful."
  default     = false
  type        = bool
}

variable "advanced_event_selectors" {
  description = "A list of advanced event selectors for the trail."
  default     = []
  type = list(object({
    name = string
    field_selectors = list(object({
      field           = string
      equals          = optional(list(string))
      starts_with     = optional(list(string))
      ends_with       = optional(list(string))
      not_equals      = optional(list(string))
      not_starts_with = optional(list(string))
      not_ends_with   = optional(list(string))
    }))
  }))
}

module "aws_cloudtrail" {
  source = "../../"

  trail_name = var.trail_name

  cloudwatch_log_group_name = var.cloudwatch_log_group_name

  s3_bucket_name = module.logs.aws_logs_bucket
  s3_key_prefix  = var.s3_key_prefix
}

module "logs" {
  source  = "trussworks/logs/aws"
  version = "~> 10"

  s3_bucket_name = var.logs_bucket

  cloudtrail_logs_prefix = var.s3_key_prefix
  allow_cloudtrail       = true

  force_destroy = true
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = module.aws_cloudtrail.cloudtrail_arn
}

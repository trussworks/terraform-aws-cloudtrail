output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_home_region" {
  description = "CloudTrail Home Region"
  value       = aws_cloudtrail.main.home_region
}

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = aws_cloudtrail.main.id
}

output "kms_key_arn" {
  description = "KMS Key ARN"
  value       = aws_kms_key.cloudtrail.arn
}

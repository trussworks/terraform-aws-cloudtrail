# Terraform AWS CloudTrail

This module creates AWS CloudTrail and configures it so that logs go to cloudwatch.

## Usage

```hcl
module "aws_cloudtrail" {
    source             = "trussworks/cloudtrail/aws"
    s3_bucket_name     = "my-company-cloudtrail-logs"
    log_retention_days = 90
}
```

## Upgrade Instructions for v2 -> v3

Starting in v3, encryption is not optional and will be on for both logs
delivered to S3 and Cloudwatch Logs. The KMS key resource created this
module will be used to encrypt both S3 and Cloudwatch-based logs.

Because of this change, remove the `encrypt_cloudtrail` parameter from
previous invocations of the module prior to upgrading the version.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.cloudtrail_cloudwatch_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudtrail_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_kms_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api_call_rate_insight | A measurement of write-only management API calls that occur per minute against a baseline API call volume. | `bool` | `false` | no |
| api_error_rate_insight | A measurement of management API calls that result in error codes. The error is shown if the API call is unsuccessful. | `bool` | `false` | no |
| cloudwatch_log_group_name | The name of the CloudWatch Log Group that receives CloudTrail events. | `string` | `"cloudtrail-events"` | no |
| enabled | Enables logging for the trail. Defaults to true. Setting this to false will pause logging. | `bool` | `true` | no |
| iam_policy_name | Name for the CloudTrail IAM policy | `string` | `"cloudtrail-cloudwatch-logs-policy"` | no |
| iam_role_name | Name for the CloudTrail IAM role | `string` | `"cloudtrail-cloudwatch-logs-role"` | no |
| key_deletion_window_in_days | Duration in days after which the key is deleted after destruction of the resource, must be 7-30 days.  Default 30 days. | `string` | `30` | no |
| log_retention_days | Number of days to keep AWS logs around in specific log group. | `string` | `90` | no |
| org_trail | Whether or not this is an organization trail. Only valid in master account. | `string` | `"false"` | no |
| s3_bucket_name | The name of the AWS S3 bucket. | `string` | n/a | yes |
| s3_key_prefix | S3 key prefix for CloudTrail logs | `string` | `"cloudtrail"` | no |
| sns_topic_arn | ARN of the SNS topic for notification of log file delivery. | `string` | `""` | no |
| tags | A mapping of tags to CloudTrail resources. | `map(string)` | `{}` | no |
| trail_name | Name for the Cloudtrail | `string` | `"cloudtrail"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail_arn | CloudTrail ARN |
| cloudtrail_home_region | CloudTrail Home Region |
| cloudtrail_id | CloudTrail ID |
<!-- END_TF_DOCS -->

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
```

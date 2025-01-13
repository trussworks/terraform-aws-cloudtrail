# simple

<!-- BEGIN_TF_DOCS -->

## Modules

| Name           | Source              | Version |
| -------------- | ------------------- | ------- |
| aws_cloudtrail | ../../              | n/a     |
| logs           | trussworks/logs/aws | ~> 12   |

## Inputs

| Name                      | Description | Type     | Default | Required |
| ------------------------- | ----------- | -------- | ------- | :------: |
| cloudwatch_log_group_name | n/a         | `string` | n/a     |   yes    |
| logs_bucket               | n/a         | `string` | n/a     |   yes    |
| s3_key_prefix             | n/a         | `string` | n/a     |   yes    |
| trail_name                | n/a         | `string` | n/a     |   yes    |

## Outputs

| Name           | Description    |
| -------------- | -------------- |
| cloudtrail_arn | CloudTrail ARN |

<!-- END_TF_DOCS -->

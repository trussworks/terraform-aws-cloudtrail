<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cloudwatch\_log\_group\_name | The name of the CloudWatch Log Group that receives CloudTrail events. | string | `"cloudtrail-events"` | no |
| log\_retention\_days | Number of days to keep AWS logs around in specific log group. | string | `"90"` | no |
| org\_trail | Whether or not this is an organization trail. Only valid in master account. | string | `"false"` | no |
| s3\_bucket\_name | The name of the AWS S3 bucket. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail\_arn | CloudTrail ARN |
| cloudtrail\_home\_region | CloudTrail Home Region |
| cloudtrail\_id | CloudTrail ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

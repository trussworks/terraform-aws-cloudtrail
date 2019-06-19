<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| log\_retention\_days | Number of days to keep AWS logs around in specific log group. | string | `"90"` | no |
| s3\_bucket\_name | The name of the AWS S3 bucket. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail\_arn | CloudTrail ARN |
| cloudtrail\_home\_region | CloudTrail Home Region |
| cloudtrail\_id | CloudTrail ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

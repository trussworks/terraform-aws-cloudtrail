
# Terraform AWS CloudTrail

This module creates AWS CloudTrail and configures it so that logs go to cloudwatch.

## Terraform Versions

Terraform 0.12. Pin module version to `~> 3.X`. Submit pull-requests to `master` branch.

Terraform 0.11. Pin module version to `~> 1.X`. Submit pull-requests to `terraform011` branch.

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
delivered to S3 and Cloudwatch Logs. However, because of this change, the
KMS key resource changes in Terraform, which means you *must* move this
resource before upgrading if you had encryption on before, or else your
previous KMS key will be *deleted*. In order to fix this, you need to move
the resource using a command like so:

```console
$ terraform state mv module.my_cloudtrail.aws_kms_key.cloudtrail[0] module.my_cloudtrail.aws_key_key.cloudtrail
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudwatch\_log\_group\_name | The name of the CloudWatch Log Group that receives CloudTrail events. | `string` | `"cloudtrail-events"` | no |
| enabled | Enables logging for the trail. Defaults to true. Setting this to false will pause logging. | `bool` | `true` | no |
| key\_deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource, must be 7-30 days.  Default 30 days. | `string` | `30` | no |
| log\_retention\_days | Number of days to keep AWS logs around in specific log group. | `string` | `90` | no |
| org\_trail | Whether or not this is an organization trail. Only valid in master account. | `string` | `"false"` | no |
| s3\_bucket\_name | The name of the AWS S3 bucket. | `string` | n/a | yes |
| s3\_key\_prefix | S3 key prefix for CloudTrail logs | `string` | `"cloudtrail"` | no |
| trail\_name | Name for the Cloudtrail | `string` | `"cloudtrail"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail\_arn | CloudTrail ARN |
| cloudtrail\_home\_region | CloudTrail Home Region |
| cloudtrail\_id | CloudTrail ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
```

### Testing

[Terratest](https://github.com/gruntwork-io/terratest) is being used for
automated testing with this module. Tests in the `test` folder can be run
locally by running the following command:

```text
make test
```

Or with aws-vault:

```text
AWS_VAULT_KEYCHAIN_NAME=<NAME> aws-vault exec <PROFILE> -- make test
```

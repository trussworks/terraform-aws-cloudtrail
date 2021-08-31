
# Terraform AWS CloudTrail

This module creates AWS CloudTrail and configures it so that logs go to cloudwatch.

## Terraform Versions

Terraform 0.13 and newer. Pin module version to `~> 4.X`. Submit pull-requests to `master` branch.

Terraform 0.12. Pin module version to `~> 3.X`. Submit pull-requests to `terraform12` branch.

## Usage

```hcl
module "aws_cloudtrail" {
    source             = "trussworks/cloudtrail/aws"
    s3_bucket_name     = "my-company-cloudtrail-logs"
    log_retention_days = 90
}
```

This generates a KMS key for enccryption of the cloudtrail logs.  KMS permissions can be appended to by use of the custom_kms_key_access
```hcl
  custom_kms_key_access = [
    {
      sid = "AllowSomeOtherDecryption"
      effect = "Allow"
      principals = [ 
        {
          type = "AWS"
          identifiers = [ "12345678901"]
        } 
      ]
      actions = [ "kms:Decrypt*", ]
    }
  ]
```
to grant additional permissions on the KMS key for external log parsers or similar.

## Upgrade Instructions for v2 -> v3

Starting in v3, encryption is not optional and will be on for both logs
delivered to S3 and Cloudwatch Logs. The KMS key resource created this
module will be used to encrypt both S3 and Cloudwatch-based logs.

Because of this change, remove the `encrypt_cloudtrail` parameter from
previous invocations of the module prior to upgrading the version.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

No modules.

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
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | The name of the CloudWatch Log Group that receives CloudTrail events. | `string` | `"cloudtrail-events"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enables logging for the trail. Defaults to true. Setting this to false will pause logging. | `bool` | `true` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name for the CloudTrail IAM role | `string` | `"cloudtrail-cloudwatch-logs-role"` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | Duration in days after which the key is deleted after destruction of the resource, must be 7-30 days.  Default 30 days. | `string` | `30` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to keep AWS logs around in specific log group. | `string` | `90` | no |
| <a name="input_org_trail"></a> [org\_trail](#input\_org\_trail) | Whether or not this is an organization trail. Only valid in master account. | `string` | `"false"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the AWS S3 bucket. | `string` | n/a | yes |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | S3 key prefix for CloudTrail logs | `string` | `"cloudtrail"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to CloudTrail resources. | `map(string)` | <pre>{<br>  "Automation": "Terraform"<br>}</pre> | no |
| <a name="input_trail_name"></a> [trail\_name](#input\_trail\_name) | Name for the Cloudtrail | `string` | `"cloudtrail"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | CloudTrail ARN |
| <a name="output_cloudtrail_home_region"></a> [cloudtrail\_home\_region](#output\_cloudtrail\_home\_region) | CloudTrail Home Region |
| <a name="output_cloudtrail_id"></a> [cloudtrail\_id](#output\_cloudtrail\_id) | CloudTrail ID |
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

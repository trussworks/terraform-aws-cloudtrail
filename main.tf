/**
 *
 * # Terraform AWS CloudTrail
 *
 * This module creates AWS CloudTrail and configures it so that logs go to cloudwatch.
 *
 * ## Terraform Versions
 *
 * Terraform 0.12. Pin module version to `~> 2.0`. Submit pull-requests to `master` branch.
 *
 * Terraform 0.11. Pin module version to `~> 1.0`. Submit pull-requests to `terraform011` branch.
 *
 * ## Usage
 *
 * ```hcl
 * module "aws_cloudtrail" {
 *     source             = "trussworks/cloudtrail/aws"
 *     s3_bucket_name     = "my-company-cloudtrail-logs"
 *     log_retention_days = 90
 * }
 * ```
 */

# The AWS region currently being used.
data "aws_region" "current" {}

# The AWS account id
data "aws_caller_identity" "current" {}

#
# CloudTrail - CloudWatch
#
# This section is used for allowing CloudTrail to send logs to CloudWatch.
#

# This policy allows the CloudTrail service for any account to assume this role.
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# This role is used by CloudTrail to send logs to CloudWatch.
resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name               = "cloudtrail-cloudwatch-logs-role"
  assume_role_policy = "${data.aws_iam_policy_document.cloudtrail_assume_role.json}"
}

# This CloudWatch Group is used for storing CloudTrail logs.
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "${var.cloudwatch_log_group_name}"
  retention_in_days = "${var.log_retention_days}"

  tags = {
    Automation = "Terraform"
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudwatch_log_group_name}:*"]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  name   = "cloudtrail-cloudwatch-logs-policy"
  policy = "${data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json}"
}

resource "aws_iam_policy_attachment" "main" {
  name       = "cloudtrail-cloudwatch-logs-policy-attachment"
  policy_arn = "${aws_iam_policy.cloudtrail_cloudwatch_logs.arn}"
  roles      = ["${aws_iam_role.cloudtrail_cloudwatch_role.name}"]
}

#
# KMS
#

# This policy is a translation of the default created by AWS when you
# manually enable CloudTrail; you can see it here:
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/default-cmk-policy.html
data "aws_iam_policy_document" "cloudtrail_kms_policy_doc" {
  statement {
    sid     = "Enable IAM User Permissions"
    effect  = "Allow"
    actions = ["kms:*"]

    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = ["*"]
  }

  statement {
    sid     = "Allow CloudTrail to encrypt logs"
    effect  = "Allow"
    actions = ["kms:GenerateDataKey*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid     = "Allow CloudTrail to describe key"
    effect  = "Allow"
    actions = ["kms:DescribeKey"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid     = "Allow alias creation during setup"
    effect  = "Allow"
    actions = ["kms:CreateAlias"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${data.aws_region.current.name}.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Enable cross account log decryption"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }

    resources = ["*"]
  }
}

resource "aws_kms_key" "cloudtrail" {
  count                   = "${var.encrypt_cloudtrail ? 1 : 0}"
  description             = "A KMS key used to encrypt CloudTrail log files stored in S3."
  deletion_window_in_days = "${var.key_deletion_window_in_days}"
  enable_key_rotation     = "true"
  policy                  = "${data.aws_iam_policy_document.cloudtrail_kms_policy_doc.json}"

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_kms_alias" "cloudtrail" {
  count         = "${var.encrypt_cloudtrail ? 1 : 0}"
  name          = "alias/cloudtrail"
  target_key_id = "${aws_kms_key.cloudtrail[0].key_id}"
}

#
# CloudTrail
#

resource "aws_cloudtrail" "main" {
  name = "cloudtrail"

  # Send logs to CloudWatch Logs
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}"
  cloud_watch_logs_role_arn  = "${aws_iam_role.cloudtrail_cloudwatch_role.arn}"

  # Send logs to S3
  s3_key_prefix  = "cloudtrail"
  s3_bucket_name = "${var.s3_bucket_name}"

  # Note that organization trails can *only* be created in organization
  # master accounts; this will fail if run in a non-master account.
  is_organization_trail = "${var.org_trail}"

  # use a single s3 bucket for all aws regions
  is_multi_region_trail = true

  # enable log file validation to detect tampering
  enable_log_file_validation = true

  kms_key_id = "${var.encrypt_cloudtrail ? aws_kms_key.cloudtrail[0].arn : null}"

  tags = {
    Automation = "Terraform"
  }

  depends_on = [
    "aws_kms_key.cloudtrail",
    "aws_kms_alias.cloudtrail",
  ]
}

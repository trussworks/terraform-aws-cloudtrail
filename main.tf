# The AWS region currently being used.
data "aws_region" "current" {}

# The AWS account id
data "aws_caller_identity" "current" {}

# The AWS partition (commercial or govcloud)
data "aws_partition" "current" {}

locals {
  s3_bucket_account_id = var.s3_bucket_account_id != null ? var.s3_bucket_account_id : data.aws_caller_identity.current.account_id
}

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
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

# This CloudWatch Group is used for storing CloudTrail logs.
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.cloudtrail.arn
  tags              = var.tags
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudwatch_log_group_name}:*"]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  name   = var.iam_policy_name
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
}

resource "aws_iam_policy_attachment" "main" {
  name       = "${var.iam_policy_name}-attachment"
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs.arn
  roles      = [aws_iam_role.cloudtrail_cloudwatch_role.name]
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

      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
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
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
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
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
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
      values   = [data.aws_caller_identity.current.account_id]
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
      values   = [local.s3_bucket_account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Allow logs KMS access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Cloudtrail to decrypt and generate key for sns access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt*",
      "kms:GenerateDataKey*",
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "cloudtrail" {
  description             = "A KMS key used to encrypt CloudTrail log files stored in S3."
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = "true"
  policy                  = data.aws_iam_policy_document.cloudtrail_kms_policy_doc.json
  tags                    = var.tags
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.trail_name}"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

#
# CloudTrail
#

resource "aws_cloudtrail" "main" {
  name = var.trail_name

  # Send logs to CloudWatch Logs
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch_role.arn

  # Send logs to S3
  s3_key_prefix  = var.s3_key_prefix
  s3_bucket_name = var.s3_bucket_name

  # Note that organization trails can *only* be created in organization
  # master accounts; this will fail if run in a non-master account.
  is_organization_trail = var.org_trail

  # use a single s3 bucket for all aws regions
  is_multi_region_trail = true

  # enable log file validation to detect tampering
  enable_log_file_validation = true

  kms_key_id = aws_kms_key.cloudtrail.arn

  # Enables logging for the trail. Defaults to true. Setting this to false will pause logging.
  enable_logging = var.enabled

  # Enables SNS log notification
  sns_topic_name = var.sns_topic_arn

  # Enable Insights
  dynamic "insight_selector" {
    for_each = compact([
      var.api_call_rate_insight ? "ApiCallRateInsight" : null,
      var.api_error_rate_insight ? "ApiErrorRateInsight" : null,
    ])
    content {
      insight_type = insight_selector.value
    }
  }

  dynamic "advanced_event_selector" {
    for_each = var.advanced_event_selectors
    content {
      name = advanced_event_selector.value.name

      dynamic "field_selector" {
        for_each = advanced_event_selector.value.field_selectors
        content {
          field           = field_selector.value.field
          equals          = field_selector.value.equals
          starts_with     = field_selector.value.starts_with
          ends_with       = field_selector.value.ends_with
          not_equals      = field_selector.value.not_equals
          not_starts_with = field_selector.value.not_starts_with
          not_ends_with   = field_selector.value.not_ends_with
        }
      }
    }
  }

  tags = var.tags

  depends_on = [
    aws_kms_key.cloudtrail,
    aws_kms_alias.cloudtrail,
  ]
}

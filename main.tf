/**
 *
 * # Terraform AWS CloudTrail
 *
 * This module creates AWS CloudTrail and configures it so that logs go to cloudwatch.
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

#
# CloudTrail - CloudWatch
#
# This section is used for allowing CloudTrail to send logs to CloudWatch.
#

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
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
  name              = "cloudtrail-events"
  retention_in_days = "${var.log_retention_days}"
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:cloudtrail-events:*"]
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
# CloudTrail
#

resource "aws_cloudtrail" "main" {
  depends_on = [
    "module.logs",
  ]

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}"
  cloud_watch_logs_role_arn  = "${aws_iam_role.cloudtrail_cloudwatch_role.arn}"

  name           = "cloudtrail"
  s3_key_prefix  = "cloudtrail"
  s3_bucket_name = "${var.s3_bucket_name}"

  # use a single s3 bucket for all aws regions
  is_multi_region_trail = true

  # enable log file validation to detect tampering
  enable_log_file_validation = true
}

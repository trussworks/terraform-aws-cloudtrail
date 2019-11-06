# Referencing module.logs.aws_logs_bucket directly in the cloudtrail module
# will fail with an InsufficientS3BucketPolicyException. Using the data
# source as a workaround to ensure the S3 bucket policy has propagated before
# the cloudtrail module references it.
module "aws_cloudtrail" {
  source         = "../../"
  s3_bucket_name = data.aws_s3_bucket.new_logs_bucket.id
}

module "logs" {
  source         = "trussworks/logs/aws"
  version        = "~> 4"
  s3_bucket_name = var.logs_bucket
  region         = var.region
}

data "aws_s3_bucket" "new_logs_bucket" {
  bucket = module.logs.aws_logs_bucket
}

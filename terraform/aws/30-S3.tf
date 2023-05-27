resource "aws_s3_bucket" "bucket" {
    for_each = { for bucket in local.aws.buckets : bucket => bucket }

    bucket = each.value
}
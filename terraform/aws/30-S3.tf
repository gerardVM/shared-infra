resource "aws_s3_bucket" "bucket" {
    for_each = { for bucket in try(local.aws.buckets, {}) : bucket => bucket }

    bucket = each.value
}
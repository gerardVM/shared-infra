resource "aws_kms_key" "shared_key" {
  for_each = { for key in try(local.aws.kms-keys, {}) : key.name => key }

  description             = each.value.description
  deletion_window_in_days = each.value.deletion_window
  key_usage               = each.value.key_usage
}

output "kms-keys" {
  value = aws_kms_key.shared_key
}
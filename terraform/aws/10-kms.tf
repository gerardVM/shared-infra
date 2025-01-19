resource "aws_kms_key" "shared_key" {
  for_each = { for key in try(local.aws.kms-keys, {}) : key.name => key }

  description             = each.value.description
  deletion_window_in_days = each.value.deletion_window
  key_usage               = each.value.key_usage
}

resource "aws_kms_key_policy" "shared_key" {
  for_each = { for key in try(local.aws.kms-keys, {}) : key.name => key if can(key.allowed) }

  key_id = aws_kms_key.shared_key[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = each.key
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.id}:root"
        }
        Action    = [
          "kms:*"
        ]
        Resource  = "*"
      },
      {
        Sid       = "Enable some roles to use the key"
        Effect    = "Allow"
        Principal = {
          AWS = flatten([ for k, v in try(each.value.allowed, {}) : [
                            for role in v : [
                              "arn:aws:iam::${local.account_0_aws.accounts[k].id}:role/${role}"
                            ]
                          ]])
        }
        Action    = [
          "kms:*"
        ]
        Resource  = "*"
      }
    ]
})
}
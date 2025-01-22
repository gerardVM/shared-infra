resource "aws_kms_key" "shared_key" {
  for_each = { for key in try(local.aws.kms-keys, {}) : key.name => key }

  description             = each.value.description
  deletion_window_in_days = each.value.deletion_window
  key_usage               = each.value.key_usage
  enable_key_rotation     = try(each.value.enable_key_rotation, false)
}

resource "aws_kms_key_policy" "shared_key" {
  for_each = { for key in try(local.aws.kms-keys, {}) : key.name => key if can(key.extra_policy) }

  key_id = aws_kms_key.shared_key[each.key].id
  policy = data.aws_iam_policy_document.shared_key[each.key].json
}

data "aws_iam_policy_document" "shared_key" {
  for_each = { for key in try(local.aws.kms-keys, {}) : key.name => key if can(key.extra_policy) }

  policy_id = each.key
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = { for statement in try(each.value.extra_policy, []) : statement.id => statement }

    content {
      sid       = try(statement.value.id, "")
      effect    = try(statement.value.effect, "Allow")
      principals {
        type        = try(statement.value.principals.type, "AWS")
        identifiers = try(statement.value.principals.identifiers, [])
      }
      actions   = try(statement.value.actions, ["kms:*"])
      resources = ["*"]
      condition {
        test     = try(statement.value.condition.test, null)
        variable = try(statement.value.condition.variable, "")
        values   = try(statement.value.condition.values, [])
      }
    }
  }
}

###############################################################################
# IAM User
###############################################################################

resource "aws_iam_user" "this" {
  for_each = try(local.aws.iam.machines, {})

  name = each.key
  path = "/machine/"
}

################################################################################
# IAM Policy
################################################################################

resource "aws_iam_policy" "this" {
  for_each = try(local.aws.iam.machines, {})

  name        = "${each.key}-policy"
  description = "Policy for ${each.key} machine"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in toset(each.value) : {
        Effect   = "Allow"
        Action   = statement.actions
        Resource = statement.resources
      }
    ]
  })
}

###############################################################################
# IAM User Policy Attachment
###############################################################################

resource "aws_iam_user_policy_attachment" "this" {
  for_each = try(local.aws.iam.machines, {})

  user       = aws_iam_user.this[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}
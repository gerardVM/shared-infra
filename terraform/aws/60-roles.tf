locals {
    role_policies = flatten([
        for role, role_data in try(local.aws.iam.roles, []) : [
            for policy in try(role_data.policies, []) : {
                role = role
                policy = policy
            }
        ]
    ])

    role_allowed = flatten([
        for role, role_data in try(local.aws.iam.roles, []) : [
            for allowed in try(role_data.allowed, []) : {
                role = role
                allowed = allowed
            }
        ]
    ])
}

data "aws_iam_roles" "allowed_roles" {
  for_each = { for role in local.role_allowed : "${role.role}-${role.allowed}" => role }
  
  name_regex = ".*${each.value.allowed}.*"
}

resource "aws_iam_role" "roles" {
  for_each = local.aws.iam.roles

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        for allowed in each.value.allowed : {
            Action   = "sts:AssumeRole"
            Effect   = "Allow"
            Principals = {
                type = "AWS"
                identifiers = [ data.aws_iam_roles.allowed_roles["${each.key}-${allowed}"].arns ]
            }
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy" {
  for_each = { for association in local.role_policies : "${association.role}-${association.policy}" => association }

  role       = aws_iam_role.roles[each.value.role].name
  policy_arn = "arn:aws:iam::aws:policy/${each.value.policy}"
}
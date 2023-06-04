locals {
    oidc_policies = flatten([
        for role, role_data in try(local.aws.oidc.roles, []) : [
            for policy in try(role_data.policies, []) : {
                role = role
                policy = policy
            }
        ]
    ])
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    effect = "Allow"
    actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_openid_connect_provider" "oidc" {
  count = can(local.aws.oidc) ? 1 : 0

  url             = local.aws.oidc.url
  client_id_list  = local.aws.oidc.client_id_list
  thumbprint_list = local.aws.oidc.thumbprint_list
}

resource "aws_iam_role" "oidc" {
  for_each = local.aws.oidc.roles

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        for index, repository in each.value.repositories : {
            Effect    = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.oidc[0].arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
            StringEquals = {
                "${aws_iam_openid_connect_provider.oidc[0].url}:aud" = aws_iam_openid_connect_provider.oidc[0].client_id_list
                }
            StringLike = {
                "${aws_iam_openid_connect_provider.oidc[0].url}:sub" = "repo:${repository}:*"
                }
            }
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "oidc" {
  for_each = { for association in local.oidc_policies : "${association.role}-${association.policy}" => association }

  role       = aws_iam_role.oidc[each.value.role].name
  policy_arn = "arn:aws:iam::aws:policy/${each.value.policy}"
}

resource "aws_iam_role_policy" "kms" {
  for_each = local.aws.oidc.roles

  name   = "${each.key}-kms"
  role   = aws_iam_role.oidc[each.key].name
  policy = data.aws_iam_policy_document.kms_policy.json
}
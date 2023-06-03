resource "aws_iam_openid_connect_provider" "github_actions" {
  url = local.aws.oidc.url

  client_id_list = local.aws.oidc.client_id_list

  thumbprint_list = local.aws.oidc.thumbprint_list
}
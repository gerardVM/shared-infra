module "iam_sso" {
  providers = { aws = aws.us-east-1 }
  
  source = "github.com/gerardvm/terraform-aws-iam-identity-center?ref=2.1.0"

  alias_to_id_map       = { for account in local.aws.accounts : account.name => account.id }
  managed_policies_map  = local.aws.iam.sso.managed_policies_map
  users_data            = local.aws.iam.sso.users
  groups_data           = local.aws.iam.sso.groups

}

resource "aws_s3_bucket" "sso_config" {
  bucket = "sso-${data.aws_caller_identity.current.account_id}"

  provider = aws.us-east-1
}

resource "aws_s3_object" "me" {
  bucket  = aws_s3_bucket.sso_config.id
  key     = "config"
  content = templatefile("./templates/config.tftpl", {
    sso_start_url  = local.aws.iam.sso.config.sso_start_url
    sso_account_id = data.aws_caller_identity.current.account_id
    sso_region     = "us-east-1"
    sso_role_name  = local.aws.iam.sso.config.sso_role_name
  })
  content_type = "text/plain"
  
  provider = aws.us-east-1
}
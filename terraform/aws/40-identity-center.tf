module "iam_sso" {
  providers = { aws = aws.us-east-1 }
  
  source = "github.com/gerardvm/terraform-aws-iam-identity-center?ref=2.0.0"

  alias_to_id_map       = local.aws.sso.alias_to_id_map
  managed_policies_map  = local.aws.sso.managed_policies_map
  custom_policies_map   = local.aws.sso.custom_policies_map
  boundary_policies_map = local.aws.sso.boundary_policies_map
  administrators_group  = local.aws.sso.administrators_group
  cli_roles_map         = local.aws.sso.cli_roles_map
  users_data            = local.aws.sso.users
  groups_data           = local.aws.sso.groups

}
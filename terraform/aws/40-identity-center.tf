module "iam_sso" {
  providers = { aws = aws.us-east-1 }
  
  source = "github.com/gerardvm/terraform-aws-iam-identity-center?ref=2.1.0"
  # source = "../modules/iam_sso"

  alias_to_id_map       = local.aws.iam.sso.alias_to_id_map
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

# data "aws_ssoadmin_instances" "instances" {}

# data "aws_identitystore_groups" "groups" {
  # for_each          = local.groups
  # identity_store_id = tolist(data.aws_ssoadmin_instances.instances.identity_store_ids)[0]
  # identity_store_id = local.identity_store_id

  # alternate_identifier {
  #   unique_attribute {
  #     attribute_path  = "DisplayName"
  #     attribute_value = each.key
  #   }
  # }
# }

locals {
  groups           = yamldecode(file("${path.root}/../../config.yaml")).aws.iam.sso.groups
  existing_groups  = { for group in data.aws_identitystore_groups.groups.groups : group.display_name => group }
  # identity_store_id = "ssoins-722377fb75a868a0"
  # identity_store_id = "gerardvm"
  identity_store_id = "d-9067f2f77f"
  group_id = "d4f84458-e0f1-7051-9483-c66df444e586"
  # identity_store_id = tolist(data.aws_ssoadmin_instances.instances.identity_store_ids)[0]
  # groups = yamldecode(file("./example_groups.yaml"))
}

import {
  # for_each = local.groups

  to = module.iam_sso.aws_identitystore_group.groups[each.key]
  # id = "${local.identity_store_id}/${data.aws_identitystore_group.groups[each.key].id}"
  # id = "${local.identity_store_id}/${local.existing_groups[each.key].group_id}"
  id = "${local.identity_store_id}/${local.group_id}"
}

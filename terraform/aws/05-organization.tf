resource "aws_organizations_organization" "org" {
  count = min(1, length(try(local.aws.aws_service_access_principals, [])))

  aws_service_access_principals = local.aws.aws_service_access_principals

  feature_set = "ALL"
}
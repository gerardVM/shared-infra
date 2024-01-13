resource "aws_organizations_organization" "org" {
  aws_service_access_principals = local.aws.aws_service_access_principals

  feature_set = "ALL"
}
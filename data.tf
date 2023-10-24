# Use this data source to get ARNs and Identity Store IDs of Single Sign-On (SSO) Instances
# IAM Identity Center > Settings > Details section
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances
data "aws_ssoadmin_instances" "sso" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_permission_set
data "aws_ssoadmin_permission_set" "power_user_access" {
  instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  name         = "PowerUserAccess"
}

# output "arn" {
#   value = data.aws_ssoadmin_permission_set.power_user_access.arn
# }

data "aws_region" "this" {
}

data "aws_caller_identity" "this" {
}
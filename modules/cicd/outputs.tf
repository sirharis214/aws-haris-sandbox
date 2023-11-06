output "cicd_codebuild_role_arn" {
  value = module.codebuild.cicd_codebuild_role_arn
}

# output "external_id" {
#   sensitive = true
#   value = jsondecode(data.aws_secretsmanager_secret_version.external_id.secret_string)["external_id"]
# }

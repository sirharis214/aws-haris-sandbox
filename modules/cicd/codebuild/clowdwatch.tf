resource "aws_cloudwatch_log_group" "this" {
  for_each          = local.codebuilds
  name              = "/aws/codebuild/${local.name}-${each.value}"
  retention_in_days = 7 # days
  tags              = local.tags
}

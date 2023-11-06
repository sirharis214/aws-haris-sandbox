resource "aws_codebuild_project" "this" {
  for_each       = local.codebuilds
  name           = "${local.name}-${each.key}"
  description    = "Run terraform ${each.key} on the Github repo:${local.name} branch:dev"
  build_timeout  = 10 # minutes
  service_role   = aws_iam_role.cicd.arn
  encryption_key = var.kms_key_arn

  artifacts {
    # artifacts will be stored: bucket-name/path/name/HERE
    type     = "S3"
    location = var.artifacts_bucket.name
    path     = local.name # repo name
    name     = each.key   # plan/apply
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VERSION"
      value = "1.5.6"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.name}-${each.key}"
    }
  }

  # source when creating tf plan CodeBuild project
  dynamic "source" {
    for_each = each.key == "plan" ? [1] : []

    content {
      type            = "GITHUB"
      location        = "https://github.com/sirharis214/${local.name}.git"
      git_clone_depth = 1
      buildspec       = data.local_file.plan.content

      git_submodules_config {
        fetch_submodules = false
      }
    }

  }

  # source when creating tf apply CodeBuild project
  dynamic "source" {
    for_each = each.key == "apply" ? [1] : []

    content {
      type      = "S3"
      location  = "${var.artifacts_bucket.name}/${local.name}/plan/"
      buildspec = data.local_file.apply.content
    }
  }

  tags = local.tags
}

/** WEBHOOK **/

/**  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook#bitbucket-and-github
CodeBuild service automatically creates the GitHub repository webhook using its granted OAuth permissions. 
This behavior cannot be controlled by Terraform.
The AWS account that Terraform uses to create this resource must have authorized 
CodeBuild to access Bitbucket/GitHub's OAuth API in each applicable region. 
This is a manual step that must be done before creating webhooks with this resource.
**/

resource "aws_codebuild_webhook" "plan" {
  project_name = "${local.name}-plan"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH" # "PUSH, PULL_REQUEST_MERGED"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "dev"
    }
  }
}

# iam_state_management | Role: StateManagement

This role allows any user, role or service from the current AWS account to assume this role. The purpose of the role is to grant the entity access to the S3 bucket that has the terraform state files.

We will specifically utilize the policy thats defining the permissions to the bucket and pass it as an additional permission policy to the IAM role for CodeBuild.

# cicd_iam.tf | Role: cicd-codebuild-

This role is assigned to the CodeBuild Project and defining its permissions. It includes the above StateManagement's permission policy so CodeBuild Project has access to the S3 Bucket with all the state files. It also has its own permissions defined.

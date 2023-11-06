# aws-haris-sandbox

# IAM Identity Center
We are utilizing [AWS IAM Identity Center](https://aws.amazon.com/iam/identity-center/) to manage access to our AWS account.

## Groups

* Admin
* PowerUser

## Users

* haris-admin
* haris-poweruser

AWS IAM Identity Center uses a centralized aws management account to securely create and manage user access across AWS accounts. We enabled AWS Organization which automatically set the current account as the management account. Next we enabled AWS IAM Identity Center and created 2 Groups, `Admin` and `PowerUser`. Then we created 2 user's and added them to their respected groups. The next step was to create a [Permission Set](https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html) for each group. Lastly we add the groups to the AWS account via AWS IAM Identity Center portal.

Using the provided URL, https://d-906780a037.awsapps.com/start Once the user's reset their passwords and auth into AWS, they get prompted with a list of AWS accounts they have access to. Upon selecting an AWS account, they get a list of roles they can assume based on groups they are assigned under. 

## IAM Identity Center Setup

For an indept tutorial on how to create AWS IAM Identity Center resources, see [iam_identity_center.md](docs/iam_identity_center.md)

## AWS CLI Auth

To authenticate aws cli for AWS IAM Identity Center user's we will be using `aws sso`. This will auth us into AWS for aws cli use and terraform use. See [aws_sso_config.md](docs/aws_sso_config.md) for configuration process.

* Authenticate (configuration steps have already been followed)
    - `aws sso login`
    - Web browser will open to login to AWS
    - Update `.aws/config`'s `sso_role_name` value under `[default]` with the name of the permission set
        - name of the permission set depends on the group the user belongs to

> Utilize the script [aws_sso_login.sh](docs/aws_sso_login.sh) which updates the sso_role_name and opens your web browser to auth into AWS.

* Log out
    - `aws sso logout`

## IAM Information

We manually created IAM Identity Center groups, users, permission sets. When creating infrastructure using terraform, we will mostly auth in as a user under PowerUser group. There are some roadblocks, sometimes we will need to create resources like IAM Roles which only user's under Admin group have permission to create. 

This would require us to:
* run command: `aws sso login`
    - auth in as a admin-user
* update `.aws/config`'s `sso_role_name` to `AdministratorAccess`
* create IAM Role in terraform (or other resources only admins can create)
* run command: `aws sso logout`
* run command: `aws sso login` again
    - auth in as a power-user 
* update `.aws/config`'s `sso_role_name` to `PowerUserAccess`

Now when you try to create the remainder of the resources as a power-user, you will run into some errors. These errors are related to the permission restrictions that power-user's have, they can't `read` the state of certain resources that only admin's can read.

To solve this, we must create a custom IAM policy with these `read` permissions. Then we can attach this custom policy to the IAM Identity Center's `PowerUserAccess` permission set.

> The custom IAM policy permission's will be updated as needed to ensure we follow the principle of least privilege.

## required permission to run terraform plan

```hcl
# The SSO Instance
data "aws_ssoadmin_instances" "sso" {}

# SSO's PowerUserAccess permission set
data "aws_ssoadmin_permission_set" "power_user_access" {
  instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  name         = "PowerUserAccess"
}

# custom IAM policy
resource "aws_iam_policy" "power_user_access" {
  name        = "PowerUserAccess"
  policy      = data.aws_iam_policy_document.power_user_access.json
  description = "Additional permissions required to run terraform plan"

  tags = local.tags
}

# custom IAM policy's permissions
data "aws_iam_policy_document" "power_user_access" {
  statement {
    sid       = "RunTfPlan"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
    ]
  }
}

# attaching custom IAM policy to SSO's PowerUserAccess permission set 
resource "aws_ssoadmin_customer_managed_policy_attachment" "power_user_access" {
  instance_arn       = data.aws_ssoadmin_permission_set.power_user_access.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.power_user_access.arn
  customer_managed_policy_reference {
    name = aws_iam_policy.power_user_access.name
  }
}

```

# CI/CD

![overview](/docs/images/cicd/aws-haris-sandbox-cicd.drawio.png)

* [Code source](#code-source)
* [Code artifacts](#code-artifacts)
* [Infrastructure](#infrastructure)
* [Webhook](#webhook)
* [Config provider for cicd repo & modules]()

We are currently using AWS CodeBuild Projects for our CI/CD.

# Disclaimer :warning:

This CI/CD is not ment to be a practical and ideal CI/CD setup. I have purposely broken this into 2 seperate GitHub repo's and 2 seperate AWS CodeBuild Projects, with one of them requiring to be triggered manually. The purpose of this CI/CD was to learn and document how AWS CodeBuild is used to pull code from GitHub and run terraform plan/apply on that code in AWS to create the infrastructure.

The ideal CI/CD would be wrap these 2 CodeBuild projects within a AWS Codepipline and integrate notifications and manual terraform-plan validation which would automatically trigger the CodeBuild apply project. 

The ideal setup would also be have ci/cd apply the webhook to the current repo instead of a secondary repo [aws-haris-sandbox-cicd](https://github.com/sirharis214/aws-haris-sandbox-cicd). 

# Pre-reqs

* Manually create a secret in AWS Secrets Manager 
    - Secret Name: `CodeBuild.AwsHarisSandbox.TerraformManagement`
        - key-value 1: `external_id` = `any-unique-string`
        - key-value 2: `role_arn`    = `ARN of the role used to create infra via ci/cd`
    - After infrastructure is created, we must update the permissions to this Secret
        - grant IAM Role `cicd-codebuild-xxx` to access this secret

> role_arn value is the role ARN of `aws-haris-sandbox-cicd-terraform-management`, it will have to be added after creating the infrastructure which creates this role.

Example Resource Permission for Secret:
```hcl
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "arn:aws:iam::594924424566:role/cicd-codebuild-xxx"
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "arn:aws:secretsmanager:us-east-1:594924424566:secret:CodeBuild.AwsHarisSandbox.TerraformManagement-TcTxxq"
  } ]
}
```

* Webhook 
    - If this is the first time creating a CodeBuild webhook from this AWS account/region to your GitHub, you must perform a one time manual process from the AWS console to grant CodeBuild OAuth permission to the GitHub account.
    - see [Webhook](#webhook) section for more details

## Code Source

When configuring the provider for the repo that will be used as the source for ci/cd, add a `assume_role` config and set the role_arn and external_id values as variables shown below. 

When CodeBuild pulls this repo into it's environment it also adds 2 environmental variables which have the values for these variables. CodeBuild gets the values from AWS Secrets Manager and due to the environmental variables naming convention, terraform automatically picks up the values and assigns it to these variables.[^1]

Configuring provider:
```hcl
provider "aws" {
  # Update with your desired region
  region = "us-east-1"
  assume_role {
    role_arn     = var.ROLE_ARN
    external_id  = var.EXTERNAL_ID
    # repo-branch ; module-workspace
    session_name = "aws-haris-sandbox-cicd-dev"
  }
}
```

Variable values get set during CodeBuild plan - build spec's environment configuration. 
This is why we must update the permission of AWS Secret Manager secret to grant the role `cicd-codebuild-xxx` access to the secret, it is the role CodeBuild uses to create the environment which also access's AWS Secret Manager. 

```hcl
version: 0.2
env:
  secrets-manager:
    TF_VAR_EXTERNAL_ID: "CodeBuild.AwsHarisSandbox.TerraformManagement:external_id"
    TF_VAR_ROLE_ARN: "CodeBuild.AwsHarisSandbox.TerraformManagement:role_arn"
...

```

## Code Artifacts

During CodeBuild Plan, we export all the artifacts into artifact's S3 bucket. This also includes the plan output file (`plan.out`) that CodeBuild Apply can use to run `terraform apply`. 

* The artifacts for CodeBuild Plan are stored under: `Bucket/<CICD_REPO_NAME>/plan`

During CodeBuild Apply, the source is configured to be the one mentioned above, this way CodeBuild Apply has access to the plan output file.

* The artifacts for CodeBuild Apply are stored under: `Bucket/<CICD_REPO_NAME>/apply`

## Infrastructure

CI/CD has 2 phases of infrastructure creation. 

* First phase creates the resources that a CodeBuild project depends on.
    - Artifacts S3 Bucket
    - IAM Role assumed by provider config in ci/cd repo
        - permissions to create any resource in AWS account
        - permission to be assumed by CodeBuild's role `cicd-codebuild-xxx` (created in next phase)
* Second phase create the actual CodeBuild project resource and other resources
    - CodeBuild project resource
    - CodeBuild webhook
    - IAM Role that CodeBuild resource assumes to create CodeBuild project and access resources to configure its environment
        - access AWS Secret Manager
        - access Artifacts S3 bucket
        - permission to assume the role from phase-1 (`aws-haris-sandbox-terraform-management`)
        - permission to manage the remote statefile S3 bucket
        - permission to create CW log-groups

## Webhook 

When working with GitHub source for a CodeBuild webhook, the CodeBuild service will automatically create (on aws_codebuild_webhook resource creation) and delete (on aws_codebuild_webhook resource deletion) the GitHub repository webhook using its granted OAuth permissions.[^2]

This requires that CodeBuild be granted OAuth permission to GitHub account via a manual process in AWS Console per-region, this must be done before creating webhook with terraform resource.

## CodeBuild: Authorize OAuth to GitHub

Once you create the CodeBuild project using the resource `aws_codebuild_project` in terraform, navigate to the AWS console where this CodeBuild project was created. Here are the manual steps you must follow to grant CodeBuild OAuth permission to your GitHub inorder for CodeBuild to create the Webhook.
> This needs to be done manually once per-region. Next time you want to create a webhook for another CodeBuild project via terraform aws_codebuild_webhook resource, this manual step will not be required.

1. Go to the `Build details` tab of the CodeBuild project
2. Under `Source`, click **Edit**
3. Under `Repository` 
    - Select **Connect using OAuth** 
    - Click **Connect to GitHub**
4. A Github Window will pop-up prompting you to authorize CodeBuild-*REGION_NAME* to access GitHub Account
    - Click **Authorize aws-codesuite**
5. You will be brought back to AWS Console to confirm connection of CodeBuild to GitHub Account
    - Click **Confirm**

Now we can use terraform to create the webhook for this CodeBuild project using the resource `aws_codebuild_webhook`.

<img src="./docs/images/cicd/edit_source.png" height=70% width=80%>
<img src="./docs/images/cicd/oauth_codebuild_to_github.png" height=70% width=40%>
<img src="./docs/images/cicd/confirm_oauth_codebuild_to_github.png" height=30% width=70%>

## Confirm CodeBuild OAuth to GitHub

### GitHub Console

In the GitHub console, we can confirm CodeBuild has access to the GitHub account.

1. Navigate to Developer Settings > Applications > Authorized OAuth Apps

<img src="./docs/images/cicd/confirm_auth_github_console.png" height=60% width=80%>

### AWS-CLI

`aws codebuild list-source-credentials --region us-east-1`

<img src="./docs/images/cicd/confirm_auth_aws_cli.png" height=40% width=60%>

## CICD Usage
### Configure Terraform & AWS provider for CICD repo

The GitHub repository [aws-haris-sandbox-cicd](https://github.com/sirharis214/aws-haris-sandbox-cicd) is linked to the CodeBuild Plan project via a webhook. Any merge to the `dev` branch will automatically trigger the CodeBuild Plan project. We will create various other GitHub repo's which will be terraform modules that create resources in AWS. In the CICD repo we will call those other GitHub repo's to create instances of those modules, to create resources in our aws account via ci/cd. More on this in the cicd repo's documentation [here](https://github.com/sirharis214/aws-haris-sandbox-cicd#introduction). The terraform configurations for those modules is shown in the section below.

The following is the terraform and aws provider configuration that you should follow in the repo:

aws-haris-sandbox-cicd's **main.tf** content:
```hcl
terraform {
  # Terraform core should be pinned to a minor version
  required_version = "= 1.5.6"
  required_providers {
    # Providers should be pinned to a major version
    # The provider source should always be specified
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.14.0"
    }
  }
  backend "s3" {
    region = "us-east-1"
    bucket = "aws-haris-sandbox20230828153749772900000001"
    key    = "terraform/aws-haris-sandbox-cicd/terraform.tfstate"
  }
}

provider "aws" {
  # Update with your desired region
  region = "us-east-1"
  assume_role {
    role_arn     = var.ROLE_ARN
    external_id  = var.EXTERNAL_ID
    session_name = "aws-haris-sandbox-cicd-dev" # repo-branch ; module-workspace
  }
}
```

### Configure Terraform for modules

In the CICD repo mentioned above, we will call various other github repo which are terraform modules. The following is the terraform configuration you should follow for those modules. See [secure-s3-bucket](https://github.com/sirharis214/secure-s3-bucket) as an example.

The provider config will come from the cicd repo itself but you still need to provide the providers source and version that your module uses. 

Module's **versions.tf** content:
```hcl
terraform {
  # Terraform core should be pinned to a minor version
  required_version = "= 1.5.6"
  required_providers {
    # Providers should be pinned to a major version
    # The provider source should always be specified
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.14.0"
    }
  }
}
```

# References

[^1]: [Terraform Environment variables can be used to set variables](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name)
[^2]: [Terraform aws_codebuild_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook#bitbucket-and-github)

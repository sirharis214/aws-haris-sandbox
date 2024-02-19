# IAM Identity Center
We are utilizing [AWS IAM Identity Center](https://aws.amazon.com/iam/identity-center/) to manage access to our AWS account.

## Groups

* Admin
* PowerUser

## Users

* haris-admin
* haris-poweruser

AWS IAM Identity Center uses a centralized aws management account to securely create and manage user access across AWS accounts. We enabled AWS Organization which automatically set the current account as the management account. Next we enabled AWS IAM Identity Center and created 2 Groups, `Admin` and `PowerUser`. Then we created 2 user's and added them to their respected groups. The next step was to create a [Permission Set](https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html) for each group. Lastly we add the groups to the AWS account via AWS IAM Identity Center portal.

Using the provided URL, `https://d-906780a037.awsapps.com/start` Once the user's reset their passwords and auth into AWS, they get prompted with a list of AWS accounts they have access to. Upon selecting an AWS account, they get a list of roles they can assume based on groups they are assigned under. 

## IAM Identity Center Setup

For an indept tutorial on how to create AWS IAM Identity Center resources, see [iam_identity_center.md](../aws/iam_identity_center.md)

## AWS CLI Auth

To authenticate aws cli for AWS IAM Identity Center user's we will be using `aws sso`. This will auth us into AWS for aws cli use and terraform use. See [aws_sso_config.md](../aws/aws_sso_config.md) for configuration process.

* Authenticate (configuration steps have already been followed)
    - `aws sso login`
    - Web browser will open to login to AWS
    - Update `.aws/config`'s `sso_role_name` value under `[default]` with the name of the permission set
        - name of the permission set depends on the group the user belongs to

> Utilize the script [aws_sso_login.sh](../aws/aws_sso_login.sh) which updates the sso_role_name and opens your web browser to auth into AWS.

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

# required permission to run terraform plan

See [additional_permissions_tf_plan](./docs/additional_permissions_tf_plan.md)

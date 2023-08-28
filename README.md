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

To authenticate aws cli for AWS IAM Identity Center user's (aws command liine or terraform use), see [aws_config_sso.md](docs/aws_config_sso.md)
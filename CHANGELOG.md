# v0.1.0
* pre-req cicd infrastructure created
    - manually created secret in AWS Secret Manager `CodeBuild.AwsHarisSandbox.TerraformManagement`
    - manually created a dummy CodeBuild project with GitHub source 
        - performed the one time manual OAuth to GitHub account and then deleted CodeBuild Project
* base cicd infrastructure created
    - artifacts S3 bucket
    - iam role: `aws-haris-sandbox-cicd-terraform-management`
    - call to create a instance of codebuild module
* codebuild module's infra created
    - codebuild projects for plan and apply
    - codebuild plan's webhook to cicd GitHub repo
    - CloudWatch log-groups for codebuild projects
    - iam role: `cicd-codebuild-xxx`

# v0.0.1
* start of changelog
* AWS IAM Identity Center (Successor to AWS Single Sign-On)
    - 2 User Groups [Admin, PowerUser]
    - custom IAM Policy to enable power user's to run `terraform plan`
* custom VPC
    - 2 public and 2 private subnets
    - Internet gateway for public subnets
    - NAT gateway for private subnets (costs associated for ec2's in private subnet)
    - route-table-public: public subnets to internet-gateway
    - route-table-private: private subnets to NAT gateway
* custom Security Group
    - Ingress SSH from my Macbook
    - Egress Allow All
* Removing idel NAT Gateway and EIP to avoid a daily cost of $1.08
    - also removed private route-table's route for public internet going to NAT 
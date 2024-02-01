# Terraform

# Download terraform
1. Go to Hashi Corp Terraform's [Download](https://developer.hashicorp.com/terraform/install?ajs_aid=471a3910-0768-4d3c-adc3-1f6663e53cf7&product_intent=terraform) page to download.
2. After download, unzip and install the tool. 
3. Now make sure that the terraform binary is available on your PATH. This process will differ depending on your operating system.
    - MacOS/Linux: `echo $PATH`
        - if needed, move to a location under PATH by running this command: `mv ~/Downloads/terraform /usr/local/bin/`
    - Windows see [this](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows) stackoverflow article which contains instructions for setting the PATH on Windows through the user interface.
4. Verify that the installation worked by opening a new terminal session and listing Terraform's available subcommands.
    - `terraform -help`

> :heavy_exclamation_mark: Check the badges in README.md to see which version of terraform the team is currently using.

# How Terraform Works
To understand the concept of terraform and how it functions under the hood takes a little while. The best method is to do some light reading and research and play with terraform BUT be patient. I promise it takes time but one day it just randomly clicks in your head and it starts to make sense.
 
AWS follows an API first approach, so almost 99% of what you can do in the AWS console can be done through their aws api or CDK/SDK.
 
In our case, we want to create aws resources, sure we can create them through AWS console but we could create those same resources via AWS api. Creating 1 resource or 2 or even 10 via AWS api is possible, time consuming but possible. Managing these resources after they are created would be a whole seprate task which takes up time. 

Now creating a well planned and well configured architecture would most likely require alot more than 10 resources, not to mention all their complex options and configurations, this would be very complicated to do through aws api, let alone managing those resources and remembering what config they have without logging into AWS console to check manually.
 
Thats where terraform comes in. 

terraform allows you to define the AWS resources you want to create and all the configurations and options for it in a "code" like structure, once you run terraform, it figures out which aws api calls need to be made and in which order to make them to actually create those resources in your AWS account and then it makes those api calls for you.
 
Not only that, terraform also stores a "statefile" for itself so it remembers which resources it created and all the configuration options for each resource. 
 
So if you ever make a change to your terraform code, the next time you run terraform, it first makes api calls to aws to check if the resources in the statefile match the same config as whats in AWS, if theres a difference at all, it marks that resource to be updated, **the statefile is the source of truth**. 
 
If you create a EC2 instance using terraform with 8 gigs of storage, but later in the AWS console you update the storage to 10 gigs. The next time you run terraform, it will see that the statefile says the EC2 instance should have 8 gigs but in AWS it has 10, terraform will reduce the storage back down to 8 gigs as the statefile is the source of truth. This is why its important to manage resources only through terraform once you create them via terraform.
 
Best thing about statefiles is that you don't have to remember all the resources you created, terraform already keeps that "inventory" through the statefile, so if you create 50 resources for one project, you can also delete all 50 of those resources by a simple command `terraform destory`. Imagine trying to delete any 50 resources in AWS console, nightmare.
 
Under the hood, terraform makes these API calls to your AWS account by using your AWS creds stored in aws cli config.

> See [aws/README](../aws/) on how to download and config aws cli-v2 and [aws/aws_sso_config](../aws/aws_sso_config.md) on how to use aws sso to auth into an AWS account for aws-cli

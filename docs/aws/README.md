# AWS Account 
Below you'll find details on the AWS account that we use.

# Account details

| Account Number |    Account Name   |
|:--------------:|:-----------------:|
|  594924424566  | aws-haris-sandbox |


# Downloading aws-cli-v2

Visit the official [AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) documentation for a full in depth process of downloading and configuring AWS CLI V2. Bellow is a brief version to get you started.

> :heavy_exclamation_mark: Check the README.md badges to see which version of aws cli-v2 the team is currently using.

## Windows

1. Download and run the AWS CLI [MSI installer](https://awscli.amazonaws.com/AWSCLIV2.msi) for Windows (64-bit)
    - Alternatively, you can run the msiexec command to run the MSI installer.
    - `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi`
2. To confirm the installation, open the Start menu, search for cmd to open a command prompt window, and at the command prompt use the following command
    - `aws --version`

### Troubleshoot windows
See [Troubleshoot AWS CLI errors](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-troubleshooting.html) for troubleshooting process.

## MacOS

1. Download the MacOS package by clicking [this](https://awscli.amazonaws.com/AWSCLIV2.pkg) link
2. Install aws-cli in this location: `/usr/local/aws-cli`
    - The installer automatically creates a symlink at /usr/local/bin/aws that links to the main program in the installation folder you chose.
3. Confirm the installation by typing the following commands in your terminal: `which aws` & `aws --version`

### Troubleshoot macOS
Run the following commands to create a symlink file in your $PATH that points to the **aws** and **aws_completer** programs.

* `sudo ln -s /folder/installed/aws-cli/aws /usr/local/bin/aws`
* `sudo ln -s /folder/installed/aws-cli/aws_completer /usr/local/bin/aws_completer`

# Configure aws-cli-v2

AWS cli stores your configuration and credential information in a profile (a collection of settings) in the credentials and config files. Your short-term credentials are provided after you authenticate with aws sso. However, you still need to configure the default aws creds file so aws sso can update the fields it needs to for when you auth into an AWS account. Below are the steps you should perform after freshly installing AWS CLI-V2.

Type the following command from your terminal/cmd/powershell to begin configuring the base aws cred file: `aws configure`

* At the prompt, entering the following values:

```shell
AWS Access Key ID [None]: <ENTER>     # Leave blank by hitting Enter Key
AWS Secret Access Key [None]: <ENTER> # Leave blank by hitting Enter Key
Default region name [None]: us-east-1
Default output format [None]: json
```

Now you can use [aws_sso_login.sh](./aws_sso_login.sh) to auth into the AWS account, depending on the Role you chose to auth in as, the script will update the default profile's sso_role_name value. Be sure to authenticate into AWS from browser as the same Role you chose in terminal. 

> See [this](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html) doc for more info on AWS SSO and AWS Identity Provider with AWS CLI

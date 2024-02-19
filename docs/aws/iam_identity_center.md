# AWS IAM Identity Center

AWS IAM Identity Center uses a centralized aws management account to securely create and manage user access across AWS accounts. We enabled AWS Organization which automatically set the current account as the management account. Next we enabled AWS IAM Identity Center and created 2 Groups, `Admin` and `PowerUser`. Then we created 2 user's and added them to their respected groups. The next step was to create a [Permission Set](https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html) for each group. Lastly we add the groups to the AWS account via AWS IAM Identity Center portal.

## PowerUser

We already created the admin resources, here are the steps we followed to create the power-user resources.

### Group

<img src="../images/1_create_group.png" height=30% width=70%>

<img src="../images/2_group_info.png" height=40% width=50%>

### User

<img src="../images/3_add_user.png" height=30% width=70%>

<img src="../images/4_user_info.png" height=40% width=50%>

<img src="../images/5_user_group.png" height=30% width=50%>

<img src="../images/6_review_user_info.png" height=30% width=50%>

<img src="../images/7_onetime_user_password.png" height=40% width=50%>

### Permission Set

<img src="../images/8_create_permission_set.png" height=30% width=70%>

<img src="../images/9_managed_permission_set.png" height=50% width=40%>

<img src="../images/10_access_duration.png" height=50% width=40%>

<img src="../images/11_review_create_permission_set.png" height=50% width=50%>

### Adding Group to Account 

<img src="../images/12_add_poweruser_to_account.png" height=40% width=70%>

<img src="../images/13_add_group_to_account.png" height=40% width=70%>

<img src="../images/14_poweruser_group_to_account.png" height=40% width=50%>

<img src="../images/15_permission_set_to_account.png" height=50% width=50%>

<img src="../images/16_review_create_poweruser_access_to_account.png" height=40% width=50%>

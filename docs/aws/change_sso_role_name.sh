#!/bin/bash

# Similarl to aws_sso_login.sh 
# this script updates the role name but does not open the web browser for you to auth into AWS. 

config_file="$HOME/.aws/config"
temp_file="/tmp/aws_config_temp"

# Prompt the user for role choice
echo "Select an option:"
echo "1. AdministratorAccess"
echo "2. PowerUserAccess"
read -p "Enter the option number: " choice

case $choice in
    1)
        new_role_name="AdministratorAccess"
        ;;
    2)
        new_role_name="PowerUserAccess"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

# Read the config file line by line and modify the desired line
while IFS= read -r line; do
    if [[ $line == "sso_role_name"* ]]; then
        echo "sso_role_name = $new_role_name"
    else
        echo "$line"
    fi
done < "$config_file" > "$temp_file"

# Replace the original config file with the modified content
mv "$temp_file" "$config_file"

echo "sso_role_name updated to $new_role_name"

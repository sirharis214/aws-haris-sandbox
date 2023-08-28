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

provider "aws" {
  # Update with your desired region
  region  = local.default_region
  profile = "PowerUserAccess-594924424566"
}

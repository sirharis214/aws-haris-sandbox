variable "project_tags" {
  type        = map(string)
  description = "Incoming project tags to be merged with local.module_tags"
  default = {
    maintainer = "haris-poweruser"
  }
}

variable "vpc_config" {
  type = object({
    cidr_block = string,
    subnets = object({
      public_1 = object({
        cidr_block              = string,
        availability_zone       = string,
        map_public_ip_on_launch = bool
      })
      public_2 = object({
        cidr_block              = string,
        availability_zone       = string,
        map_public_ip_on_launch = bool
      })
      private_1 = object({
        cidr_block        = string,
        availability_zone = string
      })
      private_2 = object({
        cidr_block        = string,
        availability_zone = string
      })
    })
  })
  default = {
    cidr_block = "10.0.0.0/16",
    subnets = {
      public_1 = {
        cidr_block              = "10.0.1.0/24",
        availability_zone       = "us-east-1a",
        map_public_ip_on_launch = true
      }
      public_2 = {
        cidr_block              = "10.0.2.0/24",
        availability_zone       = "us-east-1b",
        map_public_ip_on_launch = true
      }
      private_1 = {
        cidr_block        = "10.0.3.0/24",
        availability_zone = "us-east-1a"
      }
      private_2 = {
        cidr_block        = "10.0.4.0/24",
        availability_zone = "us-east-1b"
      }
    }
  }
}

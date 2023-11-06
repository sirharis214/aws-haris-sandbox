resource "aws_vpc" "main" {
  cidr_block = var.vpc_config.cidr_block

  tags = merge(local.tags, { Name = "main-vpc" })
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_config.subnets.public_1.cidr_block
  availability_zone       = var.vpc_config.subnets.public_1.availability_zone
  map_public_ip_on_launch = var.vpc_config.subnets.public_1.map_public_ip_on_launch

  tags = merge(local.tags, { Name = "main-public-subnet-1" })
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_config.subnets.public_2.cidr_block
  availability_zone       = var.vpc_config.subnets.public_2.availability_zone
  map_public_ip_on_launch = var.vpc_config.subnets.public_2.map_public_ip_on_launch

  tags = merge(local.tags, { Name = "main-public-subnet-2" })
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_config.subnets.private_1.cidr_block
  availability_zone = var.vpc_config.subnets.private_1.availability_zone

  tags = merge(local.tags, { Name = "main-private-subnet-1" })
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_config.subnets.private_2.cidr_block
  availability_zone = var.vpc_config.subnets.private_2.availability_zone

  tags = merge(local.tags, { Name = "main-private-subnet-2" })
}

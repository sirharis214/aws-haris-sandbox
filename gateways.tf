# VPC access to internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { Name = "main-internet-gateway" })
}

/***********   BILLING ISSUE     ***********/
# NAT Gateway is costing us $1.08 a day for being idel.
# Currently in our project, we are not utilizing private subnets,
# let alone private subnets that need access to public internet.
# For that reason, we will remove NAT Gateway and EIP for the time being.
# PS: till will require an update on the private route-table as well.

# A public NAT gateway enables instances in private subnets to 
# connect to the internet but prevents them from receiving unsolicited 
# inbound connections from the internet.
/*
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main_nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.main,
  ]

  tags = merge(local.tags, { Name = "main-nat-gateway" })
}

resource "aws_eip" "main_nat_eip" {
  tags = merge(local.tags, { Name = "main-nat-eip" })
}
*/

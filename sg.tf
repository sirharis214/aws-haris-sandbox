resource "aws_security_group" "main" {
  name        = "main-sg"
  description = "Allow SSH inbound from my Macbook"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from MacOS"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "73.248.103.165/32", # my public IP
    ]
  }

  egress {
    description      = "ALLOW ALL outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, { Name = "main-sg" })
}

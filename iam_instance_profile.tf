# IAM role that an EC2 instance profile can assume
resource "aws_iam_role" "ec2_assume_role" {
  name               = "main-ec2-assume-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_policy.json

  tags = local.tags
}

# policy that grants an entity (EC2) permission to assume the role.
data "aws_iam_policy_document" "ec2_assume_policy" {
  statement {
    sid     = "MainEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# AWS Managed policy to auth into EC2 via Session Manager
data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# attaching managed policy to role
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.ec2_assume_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

# create EC2 instance profile that assumes the above role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "main-ec2-profile"
  role = aws_iam_role.ec2_assume_role.name
}

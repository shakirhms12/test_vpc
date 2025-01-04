provider "aws" {
  region     = "us-east-1" 
  access_key = var.access_key
  secret_key = var.secret_key
}

# 👀 1️⃣ Define a local strategy for incremental updates
locals {
  resource_addition_strategy = {
    preserve_existing   = true
    incremental_update  = true
    minimal_disruption  = true
  }
}

# 2️⃣ Create an S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-example-bucket-12345"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}

# 3️⃣ Create an IAM Role for EC2 to Access S3
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# 4️⃣ Create an IAM Policy to Allow S3 Access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "Allow EC2 to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:*"]
      Resource = [
        aws_s3_bucket.my_bucket.arn,
        "${aws_s3_bucket.my_bucket.arn}/*"
      ]
    }]
  })
}

# 5️⃣ Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# 6️⃣ Create an IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# 7️⃣ Reference an existing EC2 instance to avoid destruction
data "aws_instance" "existing_instance" {
  instance_id = var.existing_instance_id
}

# 8️⃣ Attach the IAM instance profile to the existing EC2 instance
resource "aws_instance" "ec2_example_01" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet_aws.id
  security_groups = [aws_security_group.security_group.id]
  key_name      = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = var.instance_name
  }

  # Root block device
  # root_block_device {
  #   volume_type           = "gp2"            # General Purpose SSD (covered under free tier)
  #   volume_size           = 10               # Size in GB (within free tier limits)
  #   delete_on_termination = true             # Delete the volume on instance termination
  # }

  # Additional EBS data disk (optional)
  ebs_block_device {
    device_name           = "/dev/sdh"
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [
      tags,
      iam_instance_profile
    ]
  }
}


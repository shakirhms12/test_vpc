provider "aws" {
  region     = "us-east-1" 
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_instance" "ec2_example_01" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet_aws.id
  security_groups = [aws_security_group.security_group.id]
  key_name      = var.key_name

  tags = {
    Name = var.tags
  }

  # Additional EBS data disk (optional)
  # ebs_block_device {
  #   device_name           = "/dev/sdh"
  #   volume_type           = "gp2"
  #   volume_size           = 10
  #   delete_on_termination = true
  # }

  lifecycle {
    ignore_changes = [
      tags,
      vpc_security_group_ids,
      security_groups, 
      user_data, user_data_base64,
      root_block_device,
      iam_instance_profile
    ]
  }
}


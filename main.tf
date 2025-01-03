provider "aws" {
  region     = "us-east-1" 
  access_key = var.access_key
  secret_key = var.secret_key
}


resource "aws_instance" "ec2_example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnet_aws.id
  key_name = var.key_name

  tags = {
    Name = var.instance_name
  }

    # Root block device
  root_block_device {
    volume_type           = "gp2"            # General Purpose SSD (covered under free tier)
    volume_size           = 10                # Size in GB (within free tier limits)
    delete_on_termination = true             # Delete the volume on instance termination
  }

  # Additional EBS data disk (optional)
  # ebs_block_device {
  #   device_name           = "/dev/sdh"       # Device name for the additional volume
  #   volume_type           = "gp2"            # General Purpose SSD (covered under free tier)
  #   volume_size           = 10               # Size in GB (within free tier limits for a total of 28 GB)
  #   delete_on_termination = true             # Delete the volume on instance termination
  # }

  lifecycle {
    ignore_changes = [ tags ]
  }
}
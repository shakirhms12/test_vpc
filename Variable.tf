variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default = "ami-0c915868b91bfe560"
}

variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  default     = "my-ec2-instance"
}

variable "cidr_vpc" {
  description = "CIDR Block value"
  default = "10.0.0.0/16"
}

variable "cidr_subnet" {
  description = "CIDR Block value"
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "key_name" {
  default = "my_aws_key"
}
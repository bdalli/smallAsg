
# env vars
variable "env_name" {}
variable "aws_region" {}

variable "aws_az_count" {}

variable "aws_az" {
  type = "list"
}
# network addresses 
variable "vpc_cidr" {}
variable "public_subnet_cidr" {
  type = "list"
}
variable "public_subnets" {

}

variable "app_subnet_cidr" {
  type = "list"
}

# ec2 vars
variable "ami" {}

variable "bastion_key" {
  default = "bees_an_keys"
}
variable "bastion_count" {

  default = 1
}

variable "acc_id" {}

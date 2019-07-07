# dev_env vpc and asg variables with values

variable "env_name" {
  description = "Environment Name"
  default     = "dev-env"
}

variable "aws_az" {
  description = "List of az"
  type        = "string"
  default     = "eu-west-1a,eu-west-1b,eu-west-1c"
}
variable "aws_az_count" {
  default = 2
}

variable "bastion_count" {
  default = 1

}

variable "bastion_key" {
  default = "bees_an_keys"
}

variable "aws_region" {
  description = "Region for the VPC"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = "string"
  description = "CIDR for the public subnet"
  default     = "10.0.1.0/24,10.0.2.0/24,10.0.3.0/24"
}

variable "app_subnet_cidr" {
  type        = "string"
  description = "CIDR for the private subnet"
  default     = "10.0.4.0/24,10.0.5.0/24,10.0.6.0/24"
}

variable "ami" {
  description = "AMI for EC2"
  default     = "ami-81b463f6"
}

variable "key_path" {
  description = "SSH Public Key path"
  default     = ""
}

variable "acc_data" {
  description = "Account id"
  default     = "125102723833"

}




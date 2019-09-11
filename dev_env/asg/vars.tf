variable "aws_region" {
  description = "Region for the VPC"
  default     = "eu-west-1"
}

variable "ami" {
  description = "AMI for EC2"
  default     = "ami-81b463f6"
}

variable "env_name" {
  description = "Environment Name"
  default     = "dev-env"
}

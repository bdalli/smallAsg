terraform {
  required_version = ">= 0.8"
  backend "s3" {
    key = "remote_backend/vpc.tfstate"
  }
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "tf_demo"
  region                  = var.aws_region
  version                 = "~> 2.18"
}

# Resource for vpc remote state

module "vpc" {
  source = "../../modules/mod-vpc"

  # env vars

  env_name     = var.env_name
  aws_region   = var.aws_region
  aws_az_count = var.aws_az_count
  aws_az       = split(",", var.aws_az)

  # network addresses
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = split(",", var.public_subnet_cidr)
  app_subnet_cidr    = split(",", var.app_subnet_cidr)
  public_subnets     = var.public_subnet_cidr
  app_subnets        = var.app_subnet_cidr

  # ec2 vars
  ami           = var.ami
  instance_ami  = var.instance_ami
  bastion_key   = var.bastion_key
  bastion_count = var.aws_az_count
  instance_key  = var.instance_key
}


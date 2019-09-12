terraform {
  required_version = ">= 0.8"
  backend "s3" {


    key = "remote_backend/asg.tfstate"


  }
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "tf_demo"
  region                  = "${var.aws_region}"
  version                 = "~> 2.18"
}

module asg {
  source = "../../modules/mod-asg"

  # env vars
  env_name = "${var.env_name}"
  # ec2 vars
  ami = "${var.ami}"

}

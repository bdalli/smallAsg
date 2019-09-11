terraform {
  required_version = ">= 0.8"

}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "tf_demo"
  region                  = "${var.aws_region}"
  version                 = "~> 2.18"
}


resource "aws_s3_bucket" "dev-env-remote-state" {
  bucket = "${var.dev-env-remote-state}"
  acl    = "private"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

terraform {
  required_version = ">= 0.8"

  backend "s3" {
    key = "global_backend/s3.tfstate"
  }
}



provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "tf_demo"
  region                  = "${var.aws_region}"
  version                 = "~> 2.18"
}

# bucket for dev-env remote state
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

# bucket for global remote state

resource "aws_s3_bucket" "global-remote-state" {
  bucket = "${var.global-remote-state}"
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

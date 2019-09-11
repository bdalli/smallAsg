terraform {
  required_version = ">= 0.8"

}


provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "tf_demo"
  region                  = "${var.aws_region}"
  version                 = "~> 2.18"
}


# Create backend user/policy for terraform state dev-env
resource "aws_iam_user" "tf_remote" {
  name = "tf_s3_backend"

}

resource "aws_iam_user_policy" "tf_remote_policy" {
  name = "tf_remote_policy"
  user = "${aws_iam_user.tf_remote.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    { 
      
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::dev-env-remote-state"
    },
    {
      
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::dev-env-remote-state/*"
    }
  ]
}
EOF
}


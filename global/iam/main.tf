terraform {
  required_version = ">= 0.8"

  backend "s3" {
    key = "global_backend/iam.tfstate"
  }
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
      "Resource": ["arn:aws:s3:::dev-env-remote-state", "arn:aws:s3:::global-tf-remote-state"]
    },
    {
      
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": ["arn:aws:s3:::dev-env-remote-state/*", "arn:aws:s3:::global-tf-remote-state/*"]
    }
  ]
}
EOF
}
# iam for packer create user and role for policy attachment.

resource "aws_iam_user" "packer_user" {
  name = "packer_user"
}

resource "aws_iam_role" "ec2_packer_role" {
  name = "ec2_packer_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



resource "aws_iam_policy" "packer-policy" {
  name        = "packer_policy"
  description = ""
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Action" : [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeypair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource" : "*"
  }]
}
EOF
}

resource "aws_iam_policy_attachment" "packer_policy_attach" {
  name = "packer_policy_attach"

  users      = ["${aws_iam_user.packer_user.name}"]
  roles      = ["${aws_iam_role.ec2_packer_role.name}"]
  policy_arn = "${aws_iam_policy.packer-policy.arn}"
}

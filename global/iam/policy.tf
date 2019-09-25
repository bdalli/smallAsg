data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    profile = "tf_s3_backend"
    bucket  = "global-tf-remote-state"
    key     = "global_backend/s3.tfstate"
    region  = "eu-west-1"


  }

}


resource "aws_iam_policy" "s3-yum-repo-access" {

  name        = "access_s3_yum_repo"
  description = "access_s3_yum_repo_policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    { 
      
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetObject" ],
      "Resource": ["${data.terraform_remote_state.iam.outputs.s3_dev_env_yum_repo_arn}"]
    },
    {
      
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": ["${data.terraform_remote_state.iam.outputs.s3_dev_env_yum_repo_arn}/*"]
    }
  ]
}
EOF
}


# # Data refs
data "aws_elb_service_account" "main" {}

# add role for ec2 to s3 access
resource "aws_iam_role" "smallAsg_ec2_role" {
  name = "smallAsg_ec2_role"

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

# data resource for elb to  s3 writes
data "aws_iam_policy_document" "s3_lb_write" {
  policy_id = "s3_lb_write"

  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::smallasg-access-logs/*"]

    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type        = "AWS"
    }
  }
}

# policy for ec2 to s3 -- permissions are a little open here 
resource "aws_iam_policy" "ec2_s3_access_policy" {
  name        = "read_s3_elb_logs"
  description = "Policy for ec2 s3 access, etc"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["*"]
    }
  ]
}
EOF
}

# ec2 policy attach to role 
resource "aws_iam_role_policy_attachment" "ec2_s3_access_attach" {
  role       = "${aws_iam_role.smallAsg_ec2_role.name}"
  policy_arn = "${aws_iam_policy.ec2_s3_access_policy.arn}"
}

# profile for use in launch config
resource "aws_iam_instance_profile" "ec2_s3_access" {
  name = "ec2_s3_access"
  role = "${aws_iam_role.smallAsg_ec2_role.name}"
}

# s3 bucket policy attach for elb access logs
resource "aws_s3_bucket_policy" "s3_lb_write" {
  bucket = "${aws_s3_bucket.elb_access_logs.id}"
  policy = "${data.aws_iam_policy_document.s3_lb_write.json}"
}

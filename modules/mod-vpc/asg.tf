# Data refs
data "aws_elb_service_account" "main" {}



# Create a s3 bucket for elb logs

resource "aws_s3_bucket" "elb_access_logs" {
  bucket = "smallasg-access-logs"
  acl    = "private"
  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }
    expiration {
      days = 7
    }
  }
}
# IAM policy for s3 and ec2 role.
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


data "aws_iam_policy_document" "s3_lb_write" {
  policy_id = "s3_lb_write"

  statement {
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::smallasg-access-logs/*"]

    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type = "AWS"
    }
  }
}
resource "aws_iam_policy" "ec2_read_s3_elb_logs" {
  name = "read_s3_elb_logs"
  description = "Allows read for elb access logs, etc"
  policy = <<EOF
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

resource "aws_iam_instance_profile" "ec2_s3_access" {
    name = "ec2_s3_access"
    role = "${aws_iam_role.smallAsg_ec2_role.name}"
}




resource "aws_s3_bucket_policy" "s3_lb_write" {
  bucket = "${aws_s3_bucket.elb_access_logs.id}"
  policy = "${data.aws_iam_policy_document.s3_lb_write.json}"
}



# asg launch config and autoscaling group

resource "aws_launch_configuration" "smallAsg_launch_config" {

  image_id      = "${var.ami}"
  instance_type = "t2.micro"

  security_groups             = ["${aws_security_group.sgWeb.id}"]
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.ec2_s3_access.name}"

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello I am part of a smallAsg" > index.html
    nohup busybox httpd -f -p 80 &
    EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "smallAsg_asg" {
  name = "smallAsg"

  launch_configuration = "${aws_launch_configuration.smallAsg_launch_config.id}"

  vpc_zone_identifier = "${aws_subnet.public-subnet.*.id}"
  #vpc_zone_identifier = "${data.aws_subnet.ids.all.ids}"

  load_balancers = ["${aws_elb.smallAsg_lb.name}"]
  health_check_type = "ELB"
  health_check_grace_period = "300"

  min_size = 2
  max_size = 3

  tag {

    key = "Name"
    value = "${var.env_name}-smallAsg-ec2"
    propagate_at_launch = true
  }
}

# smallAsg Load Balancer

resource "aws_elb" "smallAsg_lb" {
  name = "smallAsgELB"
  #count = "${var.aws_az_count}"
  #availability_zones = "${var.aws_az}"
  subnets = "${aws_subnet.public-subnet.*.id}"
  security_groups = ["${aws_security_group.smallAsgElbSg.id}"]

  access_logs {
    bucket = "${aws_s3_bucket.elb_access_logs.bucket}"
    bucket_prefix = "log"
    interval = 60
    enabled = true
  }

  listener {

    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"

  }
}

## Alarm setup for smallAsgElb
resource "aws_cloudwatch_metric_alarm" "asg_unhealthy_host_alert" {

  alarm_name = "smallAsg-${var.env_name}-unhealthy-host"
  alarm_description = "Health check validation failed for public ALB"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions = {
    LoadBalancer = "${aws_elb.smallAsg_lb.name}"
    TargetGroup = "${element(aws_autoscaling_group.smallAsg_asg.*.name, 0)}"
  }
  evaluation_periods = "1"
  metric_name = "UnHealthyHostCount"
  namespace = "AWS/ApplicationELB"
  period = "60"
  statistic = "Sum"
  threshold = "1"
  unit = "Percent"
  # alarm_actions 		      =  need to add a action here -- suggest email sns arn

  treat_missing_data = "notBreaching"
}

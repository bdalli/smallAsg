data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    profile = "tf_s3_backend"
    bucket  = "dev-env-remote-state"
    key     = "remote_backend/vpc.tfstate"
    region  = "eu-west-1"


  }

}

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


# asg launch config and autoscaling group

resource "aws_launch_configuration" "smallAsg_launch_config" {

  image_id      = "${var.ami}"
  instance_type = "t2.micro"

  security_groups             = ["${data.terraform_remote_state.vpc.outputs.sgWeb_security_group}"]
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.ec2_s3_access.name}"
  key_name                    = "${var.instance_key}"
  user_data                   = <<-EOF
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

  vpc_zone_identifier = "${data.terraform_remote_state.vpc.outputs.public_subnet_ids}"
  #vpc_zone_identifier = "${aws_subnet.public-subnet.*.id}"
  #vpc_zone_identifier = "${data.aws_subnet.ids.all.ids}"

  load_balancers            = ["${aws_elb.smallAsg_lb.name}"]
  health_check_type         = "ELB"
  health_check_grace_period = "300"

  min_size        = 2
  max_size        = 3
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]

  lifecycle {
    create_before_destroy = true
  }

  tag {

    key                 = "Name"
    value               = "${var.env_name}-smallAsg-ec2"
    propagate_at_launch = true
  }
}

# smallAsg Load Balancer

resource "aws_elb" "smallAsg_lb" {
  name = "smallAsgELB"
  #count = "${var.aws_az_count}"
  #availability_zones = "${var.aws_az}"
  subnets         = "${data.terraform_remote_state.vpc.outputs.public_subnet_ids}"
  security_groups = ["${data.terraform_remote_state.vpc.outputs.smallAsgElbSg}"]

  access_logs {
    bucket        = "${aws_s3_bucket.elb_access_logs.bucket}"
    bucket_prefix = "log"
    interval      = 60
    enabled       = true
  }

  listener {

    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"

  }
}

## Alarm setup for smallAsgElb
resource "aws_cloudwatch_metric_alarm" "asg_unhealthy_host_alert" {

  alarm_name          = "smallAsg-${var.env_name}-unhealthy-host"
  alarm_description   = "Health check validation failed for ELB to host"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions = {
    LoadBalancer = "${aws_elb.smallAsg_lb.name}"
    TargetGroup  = "${element(aws_autoscaling_group.smallAsg_asg.*.name, 0)}"
  }
  evaluation_periods = "1"
  metric_name        = "UnHealthyHostCount"
  namespace          = "AWS/ApplicationELB"
  period             = "60"
  statistic          = "Sum"
  threshold          = "1"
  unit               = "Percent"
  # alarm_actions 		      =  need to add a action here -- suggest email sns arn

  treat_missing_data = "notBreaching"
}
# scaling up alert .. illustrative only 
# better to manage using cloud watch events and lambda for alerting

resource "aws_cloudwatch_metric_alarm" "asg_scaling_up" {

  alarm_name = "smallAsg-${var.env_name}-asg_scaling_up"

  alarm_description   = "smallAsg has scaled beyond minimium value"
  comparison_operator = "GreaterThanThreshold"
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupMinSize"
  threshold           = 2
  period              = 60
  statistic           = "Average"
  dimensions = {

    AutoScalingGroupName = "${aws_autoscaling_group.smallAsg_asg.name}"
  }

  evaluation_periods = "3"
  treat_missing_data = "notBreaching"
  #alarm_actions = add a sns topic here 
}

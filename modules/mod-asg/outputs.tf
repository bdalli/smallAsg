output "elb_dns_name" {
  value = "${aws_elb.smallAsg_lb.dns_name}"
}

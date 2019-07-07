output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}
output "public_subnet_ids" {
  value = ["${aws_subnet.public-subnet.*.id}"]
}
output "bastion_security_group_id" {
  value = "${aws_security_group.bastionSg.id}"
}

output "sgWeb_security_group" {
  value = "${aws_security_group.sgWeb.id}"
}

output "elb_dns_name" {
  value = "${aws_elb.smallAsg_lb.dns_name}"
}

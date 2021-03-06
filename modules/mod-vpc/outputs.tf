output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public-subnet.*.id}"
}
output "app_subnet_ids" {
  value = "${aws_subnet.app-subnet.*.id}"
}


output "bastion_security_group_id" {
  value = "${aws_security_group.bastionSg.id}"
}

output "sgWeb_security_group" {
  value = "${aws_security_group.sgWeb.id}"
}

output "sgDevToolsId" {
  value = "${aws_security_group.sgDevTools.id}"
}
output "smallAsgElbSg" {
  value = "${aws_security_group.smallAsgElbSg.id}"
}

# output "elb_dns_name" {
#   value = "${aws_elb.smallAsg_lb.dns_name}"
# }

output "bastion_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "devTools_ec2_ip" {
  value = "${aws_instance.devtools-ec2.private_ip}"
}

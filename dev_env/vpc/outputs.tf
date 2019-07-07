output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr}"
}
output "public_subnet_ids" {
  value = "${module.vpc.public_subnet_ids}"
}

output "bastion_security_group_id" {
  value = "${module.vpc.bastion_security_group_id}"
}

output "sgWeb_security_group" {
  value = "${module.vpc.sgWeb_security_group}"
}

output "elb_dns_name" {
  value = "${module.vpc.elb_dns_name}"
}

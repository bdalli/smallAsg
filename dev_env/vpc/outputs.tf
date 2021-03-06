output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "app_subnet_ids" {
  value = module.vpc.app_subnet_ids
}

output "bastion_security_group_id" {
  value = module.vpc.bastion_security_group_id
}

output "sgWeb_security_group" {
  value = module.vpc.sgWeb_security_group
}

output "sgDevToolsId" {
  value = module.vpc.sgDevToolsId
}

# output "elb_dns_name" {
#   value = "${module.vpc.elb_dns_name}"
# }
output "bastion_ip" {
  value = module.vpc.bastion_ip
}

output "smallAsgElbSg" {
  value = module.vpc.smallAsgElbSg
}

output "devTools_ec2_ip" {
  value = module.vpc.devTools_ec2_ip
}


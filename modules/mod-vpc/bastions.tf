
# Define bastion server inside the public subnet
resource "aws_instance" "bastion" {
  #count                       = "${var.bastion_count}"
  ami                         = "${var.ami}"
  instance_type               = "t1.micro"
  key_name                    = "${var.bastion_key}"
  subnet_id                   = "${element(aws_subnet.public-subnet.*.id, 0)}"
  vpc_security_group_ids      = ["${aws_security_group.bastionSg.id}"]
  associate_public_ip_address = true

  source_dest_check = false


  tags = {
    Name = "${var.env_name}-bastion"
  }
}

# resource "aws_instance" "test-ec2" {
#   count                       = "${var.bastion_count}"
#   ami                         = "${var.ami}"
#   instance_type               = "t1.micro"
#   key_name                    = "${var.bastion_key}"
#   subnet_id                   = "${element(aws_subnet.public-subnet.*.id, count.index)}"
#   vpc_security_group_ids      = ["${aws_security_group.sgWeb.id}"]
#   associate_public_ip_address = false

#   source_dest_check = false


#   tags = {
#     Name = "${var.env_name}-test-ec2"
#   }
# }



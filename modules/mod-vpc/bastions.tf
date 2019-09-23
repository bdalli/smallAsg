
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    profile = "tf_s3_backend"
    bucket  = "global-tf-remote-state"
    key     = "global_backend/iam.tfstate"
    region  = "eu-west-1"

  }

}



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

resource "aws_instance" "devtools-ec2" {
  #count                       = "${var.bastion_count}"
  ami                         = "${var.ami}"
  instance_type               = "t1.micro"
  key_name                    = "${var.instance_key}"
  subnet_id                   = "${element(aws_subnet.app-subnet.*.id, 0)}"
  vpc_security_group_ids      = ["${aws_security_group.sgDevTools.id}"]
  associate_public_ip_address = false
  iam_instance_profile        = "${data.terraform_remote_state.iam.outputs.packer_profile_name}"



  source_dest_check = false


  tags = {
    Name = "${var.env_name}-packer"
  }
}



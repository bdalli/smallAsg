
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    profile = "tf_s3_backend"
    bucket  = "global-tf-remote-state"
    key     = "global_backend/iam.tfstate"
    region  = "eu-west-1"

  }

}

data "template_file" "py_env_setup" {
  template = "${file("../../template_data/py_env_setup.bash")}"
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
  ami                         = "${var.instance_ami}"
  instance_type               = "t1.micro"
  key_name                    = "${var.instance_key}"
  subnet_id                   = "${element(aws_subnet.app-subnet.*.id, 0)}"
  vpc_security_group_ids      = ["${aws_security_group.sgDevTools.id}"]
  associate_public_ip_address = false
  iam_instance_profile        = "${data.terraform_remote_state.iam.outputs.packer_profile_name}"
  user_data                   = "${data.template_file.py_env_setup.rendered}"


  source_dest_check = false


  tags = {
    Name = "${var.env_name}-tools"
  }
}

resource "aws_ebs_volume" "devtools" {
  availability_zone = aws_instance.devtools-ec2.availability_zone
  size              = 10

  tags = {
    Name = "devtools"
  }
}

resource "aws_volume_attachment" "devtools" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.devtools.id}"
  instance_id = "${aws_instance.devtools-ec2.id}"
}

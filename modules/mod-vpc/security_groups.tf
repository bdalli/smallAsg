# Define the security group for public subnet
resource "aws_security_group" "sgWeb" {
  name        = "${var.env_name}-pubSg"
  description = "Allow incoming HTTP connections & Bastion ssh access"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }



  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.env_name}-pubSg"
  }
}

resource "aws_security_group" "bastionSg" {
  name        = "${var.env_name}-bastionSg"
  description = "Bastion ssh inbound from Web and outbound to vpc"

  ingress {
    from_port   = 22
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.env_name}-bastionSg"
  }
}

resource "aws_security_group" "smallAsgElbSg" {
  name        = "${var.env_name}-smallAsgElb"
  description = "ELB incoming HTTP connections"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${var.vpc_cidr}"]

  }
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.env_name}-smallAsgElbSg"
  }
}

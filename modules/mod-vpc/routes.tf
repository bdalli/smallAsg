
# For public routing igw and routes

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.env_name}-igw"
  }
}


# Define the route table
resource "aws_route_table" "public-rt" {

  vpc_id = "${aws_vpc.vpc.id}"

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "${var.env_name}-publicRt"
  }
}




# Assign the public subnets to the route table
resource "aws_route_table_association" "public-rt-tbl-assc" {
  count          = "${var.aws_az_count}"
  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

# Private NatGateWay and route table 

resource "aws_eip" "nat" {
  vpc = true

}


resource "aws_nat_gateway" "app_nat_gw" {
  allocation_id = "${aws_eip.nat.id}"

  subnet_id = "${element(aws_subnet.public-subnet.*.id, 0)}"

  depends_on = ["aws_internet_gateway.gw"]

}


resource "aws_route_table" "app-rt" {

  vpc_id = "${aws_vpc.vpc.id}"

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.app_nat_gw.id}"
  }

  tags = {
    Name = "${var.env_name}-appRt"
  }
}

resource "aws_route_table_association" "app-rt-tbl-assc" {
  count          = "${var.aws_az_count}"
  subnet_id      = "${element(aws_subnet.app-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.app-rt.id}"
}

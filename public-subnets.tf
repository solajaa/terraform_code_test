locals {
    az_names    = "${data.aws_availability_zones.azs.names}"
    pub_sub_ids = "${aws_subnet.codetest_1.*.id}"
}

resource "aws_subnet" "codetest_1" {
    count   = length(local.az_names)
    vpc_id  = aws_vpc.policy_test.id
    cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index)}"
    availability_zone = "${local.az_names[count.index]}"
    map_public_ip_on_launch = true
    tags = {
        Name = "PublicSubnet-${count.index + 1}"
    }
}

resource "aws_route_table" "prt" {
  vpc_id = aws_vpc.policy_test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Adgear"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.policy_test.id

  tags = {
    Name = "AdgearIgw"
  }
}

resource "aws_route_table_association" "pub_sub_asociation" {
  count          = "${length(local.az_names)}"
  subnet_id      = "${local.pub_sub_ids[count.index]}"
  route_table_id = "${aws_route_table.prt.id}"
}
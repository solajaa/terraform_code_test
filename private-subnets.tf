locals {
    #az_names    = "${data.aws_availability_zones.azs.names}"
    pri_sub_ids = "${aws_subnet.codetest_2.*.id}"
}

resource "aws_subnet" "codetest_2" {
    count   = "${length(slice(local.az_names, 0, 4))}"
    vpc_id  = aws_vpc.policy_test.id
    cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index + length(local.az_names))}"
    availability_zone = "${local.az_names[count.index]}"
    map_public_ip_on_launch = true
    tags = {
        Name = "PrivateSubnet-${count.index + 1}"
    }
}

resource "aws_eip" "eip_nat" {
    vpc = true

    tags = {
        Name = "infosec"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.eip_nat.id
    subnet_id = "${local.pub_sub_ids[0]}"

    tags = {
        Name = "nat_test"
    }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.policy_test.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Adgear"
  }
}
resource "aws_route_table_association" "private_sub_asociation" {
  count          = "${length(local.az_names)}"
  subnet_id      = "${local.pri_sub_ids[1]}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_vpc" "policy_test" {
    cidr_block = "${var.vpc_cidr}"
    instance_tenancy = "default"

    tags= {
    name = "Code_Test"
    Enviroment = "${terraform.workspace}"
    owner_id = "infosec"
    }
}

resource "aws_vpc" "policy_test2" {
    cidr_block = "${var.vpc_cidr2}"
    instance_tenancy = "default"

    tags= {
    name = "Code_Test"
    Enviroment = "${terraform.workspace}"
    owner_id = "infosec"
    }
}

resource "aws_vpc_peering_connection" "adgear" {
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id   = aws_vpc.policy_test.id
  vpc_id        = aws_vpc.policy_test2.id
  peer_region   = "us-east-1"
}

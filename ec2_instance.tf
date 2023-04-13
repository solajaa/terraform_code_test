locals {
  env_tag = {
    Environment = "${terraform.workspace}"
  }

  web_tags = "${merge(var.web_tags, local.env_tag)}"
}
resource "aws_instance" "web" {
  count                  = "${var.ec2_count}"
  ami                    = "${var.ami}"
  #region                 = "${var.region}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${local.pub_sub_ids[count.index]}"
  tags                   = "${local.web_tags}"
  user_data              = "${file("scripts/apache.sh")}"
  iam_instance_profile   = "${aws_iam_instance_profile.s3_ec2_profile.name}"
  vpc_security_group_ids = ["${aws_security_group.prisma_test_sg.id}"]
  key_name               = "${aws_key_pair.web.key_name}"
}

resource "aws_key_pair" "web" {
  key_name   = "adgear-web"
  public_key = "${file("scripts/web.pub")}"
} 

resource "aws_instance" "ebsvolume" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"

  tags = {
    Name = "infosec"
  }
}

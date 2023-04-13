resource "aws_ebs_volume" "ebsvolume" {
  availability_zone = "us-east-1a"
  size              = 20

  tags = {
    Name = "infosec"
  }
}

resource "aws_ebs_encryption_by_default" "ebsvolume" {
  enabled = true
}

resource "aws_volume_attachment" "ebs_att" {
    count                  = "${var.ec2_count}"
    device_name = "/dev/sdh"
    volume_id   = aws_ebs_volume.ebsvolume.id
    instance_id = "${aws_instance.web.*.id[count.index]}"
    /*for_each = data.aws_instance.web.id
    id = each.value*/
}

resource "aws_ebs_snapshot" "snapshot" {
  volume_id = aws_ebs_volume.ebsvolume.id
  #data_encryption_key_id = ""

  tags = {
    Name = "infosec"
  }
}
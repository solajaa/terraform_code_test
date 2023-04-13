resource "aws_lb_target_group" "adgear" {
  name     = "adgear-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.policy_test.id}"
}

resource "aws_lb_target_group_attachment" "adgear" {
  count            = "${var.ec2_count}"
  target_group_arn = "${aws_lb_target_group.adgear.arn}"
  target_id        = "${aws_instance.web.*.id[count.index]}"
  port             = 80
}

resource "aws_lb" "adgear" {
  name               = "adgear-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.elb_sg.id}"]
  subnets            = "${local.pub_sub_ids}"
  access_logs {
    bucket  = "adgear-alb-access-logs"
    enabled = true
  }
  tags = {
    Environment = "${terraform.workspace}"
  }
}


resource "aws_lb_listener" "web_tg" {
  load_balancer_arn = "${aws_lb.adgear.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.adgear.arn}"
  }
}

data "template_file" "adgear" {
  template = "${file("scripts/iam/alb-s3-access-logs.json")}"
  vars = {
    access_logs_bucket = "adgear-alb-access-logs"
  }
}

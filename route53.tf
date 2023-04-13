data "aws_route53_zone" "alpha1pm" {
  name         = "alpha1pm.com"
  #vpc_id       =  aws_vpc.policy_test.id
  private_zone = false
}

resource "aws_route53_record" "alpha1pm" {
  zone_id = "${data.aws_route53_zone.alpha1pm.zone_id}"
  name    = "${data.aws_route53_zone.alpha1pm.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.adgear_elb.dns_name}"
    zone_id                = "${aws_elb.adgear_elb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = var.common_tags
}

resource "aws_route53_record" "root-a" {
  zone_id = data.aws_route53_zone.alpha1pm.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.root_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-a" {
  zone_id = data.aws_route53_zone.alpha1pm.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_s3_bucket" "my_bucket" {
  bucket               = "${var.app_s3}"
  acl    = "private"
  #region = "us-west-2"
  tags = {
    Name        = "infosec_test"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_s3_bucket" "alb_access_logs" {
  bucket = "adgear-alb-access-logs"
  policy = "${data.template_file.adgear.rendered}"
  acl    = "private"
  #region = "us-west-2"
  tags = {
    Name        = "Aalb-access-logs"
    Environment = "${terraform.workspace}"
  }
}

# S3 bucket for website.
resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${var.bucket_name}"
  acl    = "public-read"
  policy = templatefile("templates/s3-policy.json", { bucket = "www.${var.bucket_name}" })
  

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain_name}"]
    max_age_seconds = 3000
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = var.common_tags
}

# S3 bucket for redirecting non-www to www.
resource "aws_s3_bucket" "root_bucket" {
  bucket = var.bucket_name
  acl    = "public-read"
  policy = templatefile("templates/s3-policy.json", { bucket = var.bucket_name })

  website {
    redirect_all_requests_to = "https://www.${var.domain_name}"
  }

  tags = var.common_tags
}

resource "aws_s3_bucket_object" "object1" {
for_each = fileset("myfiles/", "*")
bucket = aws_s3_bucket.www_bucket.id
key = each.value
source = "myfiles/${each.value}"
etag = filemd5("myfiles/${each.value}")
}
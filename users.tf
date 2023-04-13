resource "aws_iam_user" "adgear_user" {
  count = "${length(var.username)}"
  name = "${element(var.username,count.index )}"
}

resource "aws_iam_virtual_mfa_device" "adgear" {
  virtual_mfa_device_name = "adgear"
}
/*
resource "aws_iam_user_mfa_device" "adgear" {
    username = aws_iam_user.adgear_user.name

    serial_number = aws_iam_virtual_mfa_device.adgear.arn

    tags = var.env_prefix 
}*/

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 2
  max_password_age               = 30
    
}

# give the iam user programatic access
resource "aws_iam_access_key" "iam_access_key" {
    count = "${length(var.username)}"
    user = "aws_iam_user.adgear_user${count.index + 1}"
}

# create the inline policy
data "aws_iam_policy_document" "s3_get_put_detele_policy_document" {
  statement {
    actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"

    ]

    resources = [
        "arn:aws:s3:::iam-key-rotation-tst/*",
        "arn:aws:s3:::reytsiacstate/*"
    ]
  }
}

# attach the policy to the user
resource "aws_iam_user_policy" "s3_get_put_detele_policy" {
    count = "${length(var.username)}"
    name    = "s3_get_put_detele_policy"
    user    = "aws_iam_user.adgear_user${count.index + 1}"
    policy  = data.aws_iam_policy_document.s3_get_put_detele_policy_document.json
}

resource "aws_kms_key" "adgear" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
}

resource "aws_kms_key_policy" "adgear" {
  key_id = aws_kms_key.adgear.id
  policy = jsonencode({
    Id = "example"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}
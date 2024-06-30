resource "aws_s3_bucket" "house_hunting" {
  bucket = local.domain_name
}

resource "aws_s3_bucket_website_configuration" "house_hunting" {
  bucket = aws_s3_bucket.house_hunting.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "house_hunting_access_block" {
  bucket = aws_s3_bucket.house_hunting.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "house_hunting" {
  bucket = aws_s3_bucket.house_hunting.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "house_hunting_policy" {
  bucket = aws_s3_bucket.house_hunting.id
  policy = data.aws_iam_policy_document.house_hunting_policy_document.json
}

data "aws_iam_policy_document" "house_hunting_policy_document" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["${aws_s3_bucket.house_hunting.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]
  }
}
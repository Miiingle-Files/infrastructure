provider "aws" {
  alias  = "global_service"
  region = "us-east-1"
}

resource "aws_cloudfront_distribution" "frontend_webapp_distribution" {
  provider   = aws.global_service
  depends_on = [aws_acm_certificate_validation.web_app_ssl_cert_validation]

  origin {
    domain_name = aws_s3_bucket.frontend_webapp.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.frontend_webapp.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  aliases = [aws_acm_certificate.web_app.domain_name]

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.frontend_webapp.bucket}"

    forwarded_values {
      query_string = "false"

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["PH"]
    }
  }

  default_root_object = "/index.html"
  enabled             = true

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.web_app.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
  }

}

resource "aws_s3_bucket" "frontend_webapp" {
  bucket = "files.net.miiingle.${var.env}.webapp"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = merge(local.common_tags, {
    Name = "${var.org}-${var.env}-webapp-cdn"
  })

}

resource "aws_s3_bucket_policy" "frontend_webapp_distribution_access_s3" {
  bucket = aws_s3_bucket.frontend_webapp.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "CloudFront access to the private bucket"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_webapp.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.frontend_webapp.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
  }
}


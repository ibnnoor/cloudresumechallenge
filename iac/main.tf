#Provider block
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.64.0"
    }
  }
  backend "s3" {
    bucket = "toyyib-remote-backend-bucket"
    key = "newstate"
    region = "eu-central-1"
  }
}

#Set the region
provider "aws" {
    region = "us-east-1"
}

#Create the se bucket
resource "aws_s3_bucket" "resume" {
  bucket = "resume.oliyidetoyyib.com"
  
}


resource "aws_s3_object" "resume" {
    bucket = aws_s3_bucket.resume.id
    for_each = fileset("/vagrant/cloudresume/frontend/","*")
    key = each.value
    source = "/vagrant/cloudresume/frontend/${each.value}"
    #content_type = "text/html"
    etag = filemd5("/vagrant/cloudresume/frontend/${each.value}")

}

resource "aws_s3_bucket_public_access_block" "resume" {
  bucket = aws_s3_bucket.resume.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false 
  restrict_public_buckets = false 
}

resource "aws_s3_bucket_policy" "resume" {
  bucket = aws_s3_bucket.resume.id
  policy = file("s3-policy.json")
  
}
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.resume.id

  index_document {
    suffix = "resume.html"
  }

  error_document {
    key = "error.html"
  }

}

#Get the s3 origin id
locals {
  s3_origin_id = "myS3Origin"
}

#resource "aws_cloudfront_origin_access_control" "resume" {
#  name                              = "resume"
#  description                       = "Example Policy"
#  origin_access_control_origin_type = "s3"
#  signing_behavior                  = "always"
#  signing_protocol                  = "sigv4"
#}

#Get the acm certificate issued to our domain name
data "aws_acm_certificate" "issued" {
  domain = "resume.oliyidetoyyib.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

#Get the route53 id 
data "aws_route53_zone" "selected" {
  name         = "oliyidetoyyib.com"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.resume.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "resume.html"

 # logging_config {
  #  include_cookies = false
  # bucket          = "mylogs.s3.amazonaws.com"
  # prefix          = "myprefix"
  #}

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method = "sni-only"
    acm_certificate_arn = data.aws_acm_certificate.issued.arn
    minimum_protocol_version = "TLSv1"
  }
}


#Create a record in route 53
resource "aws_route53_record" "site-domain" {
  zone_id = data.aws_route53_zone.selected.id
  name = var.domain_name
  type = "A"

  alias {
    name   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
  

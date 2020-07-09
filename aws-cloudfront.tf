# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = aws_s3_bucket.crossbarfx-web.website_endpoint
        origin_id   = "crossbarfx-web"

        // The origin must be http even if it's on S3 for redirects to work properly
        // so the website_endpoint is used and http-only as S3 doesn't support https for this
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols = ["TLSv1.2"]
        }
    }

    enabled                 = true
    default_root_object     = "index.html"
    aliases                 = [var.dns-domain-name, "www.${var.dns-domain-name}"]

    logging_config {
        include_cookies = false
        bucket          = aws_s3_bucket.crossbarfx-weblog.bucket_domain_name
        prefix          = "weblogs"
    }

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD", "OPTIONS"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "myS3Origin"

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

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    # viewer_certificate {
    #     acm_certificate_arn = "${aws_acm_certificate_validation.default.certificate_arn}"
    #     ssl_support_method = "sni-only"
    #     minimum_protocol_version = "TLSv1.1_2016"
    # }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
}

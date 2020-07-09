# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = aws_s3_bucket.crossbar-web.bucket_regional_domain_name
        origin_id   = aws_s3_bucket.crossbar-web.bucket

        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.crossbar-web.cloudfront_access_identity_path
        }
    }

    enabled                 = true
    default_root_object     = "index.html"
    aliases                 = [aws_s3_bucket.crossbar-web.bucket, var.dns-domain-name, "www.${var.dns-domain-name}"]

    logging_config {
        include_cookies = false
        bucket          = aws_s3_bucket.crossbar-weblog.bucket_domain_name
        prefix          = "weblogs"
    }

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD", "OPTIONS"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.crossbar-web.bucket

        forwarded_values {
            query_string = true

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
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2018"
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

    depends_on = [aws_s3_bucket.crossbar-web, aws_s3_bucket.crossbar-weblog]
}

# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

resource "aws_cloudfront_distribution" "crossbar-web" {
    origin {
        domain_name = aws_s3_bucket.crossbar-web.bucket_regional_domain_name
        origin_id   = aws_s3_bucket.crossbar-web.bucket

        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.crossbar-web.cloudfront_access_identity_path
        }
    }

    comment                 = var.dns-domain-name
    enabled                 = true
    is_ipv6_enabled         = true
    default_root_object     = "index.html"

    aliases                 = [var.dns-domain-name, "www.${var.dns-domain-name}"]
    # error creating CloudFront Distribution: InvalidViewerCertificate: The certificate that is attached to your distribution doesn't cover the alternate domain name (CNAME) that you're trying to add. For more details, see: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/CNAMEs.html#alternate-domain-names-requirements
    # aliases                 = [aws_s3_bucket.crossbar-web.bucket, var.dns-domain-name, "www.${var.dns-domain-name}"]

    logging_config {
        include_cookies = false
        bucket          = aws_s3_bucket.crossbar-weblog.bucket_domain_name
        prefix          = "web"
    }

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.crossbar-web.bucket

        forwarded_values {
            query_string = true

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
        compress               = true
    }

    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate_validation.crossbar_dns_cert1_validation.certificate_arn
        ssl_support_method = "sni-only"

        # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValues-security-policy
        minimum_protocol_version = "TLSv1.2_2019"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    depends_on = [aws_s3_bucket.crossbar-web, aws_s3_bucket.crossbar-weblog]

    tags = {
        Name = "Crossbar.io Cloud (${var.dns-domain-name})"
        env = var.env
    }
}

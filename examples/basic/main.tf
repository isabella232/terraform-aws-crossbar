module "crossbar" {
    source  = "crossbario/crossbar/aws"
    version = "1.7.0"

    # where to deploy to
    aws-region = var.region

    # path to file with public SSH key
    admin-pubkey = var.pubkey

    # domain name hosted by the cloud
    domain-name = "example.com"

    # S3 bucket names for various uses
    web-bucket = "example.com-web"
    weblog-bucket = "example.com-weblog"
    download-bucket = "example.com-download"
    backup-bucket = "example.com-backup"
}

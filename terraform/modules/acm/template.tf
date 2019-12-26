resource "aws_acm_certificate" "acm" {
  domain_name       = "${var.domain}" #A domain name for which the certificate should be issued
  validation_method = "DNS"

  tags = "${merge(var.default_tags, map("Name", "${var.domain}", ))}"

  lifecycle {
    create_before_destroy = true
  }
}
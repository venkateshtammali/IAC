resource "aws_acm_certificate" "acm" {
  domain_name       = "${var.domain}" #A domain name for which the certificate should be issued
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = "${var.default_tags}"
}
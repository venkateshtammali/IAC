variable "domains" {
  type = map
  default = {
    development = "1dev.apty.io",
    qa          = "qa.apty.io"
    staging     = "stage.apty.io"
    production  = "app.apty.io"
  }
}

resource "aws_route53_zone" "hosted-zone" {
  name = "${lookup(var.domains, var.env)}"
}

resource "aws_route53_record" "server1-record" {
  zone_id = "${aws_route53_zone.hosted-zone.zone_id}"
  name    = "${lookup(var.domains, var.env)}"
  type    = "A"
  ttl     = "60"
  records = ["104.236.247.8"] // will change later according to requirements
}
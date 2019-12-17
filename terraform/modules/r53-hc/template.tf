
# Create SNS from module
 module "sns" {
  source = "./../sns"

  display_name  = "${var.env}-sns"
  email_addresses= ["tvenkatesh4b6@gmail.com"]
}


resource "aws_route53_health_check" "r53_hc" {
  fqdn              = "${var.domain}"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  measure_latency   = "1"
  tags = {
    Name = "${var.env}-${var.domain}-hc"
  }
}

resource "aws_cloudwatch_metric_alarm" "route53-healthcheck-alm" {
  alarm_name                = "${var.env}-${var.domain}-alm"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "HealthCheckStatus"
  namespace                 = "AWS/Route53"
  period                    = "60" #in seconds
  statistic                 = "Minimum"
  threshold                 = "2"
  alarm_description         = "This metric monitors whether the server is down or not."
  alarm_actions             = ["${module.sns.arn}"]
  dimensions = {
    HealthCheckId           = "${aws_route53_health_check.r53_hc.id}"
  }
}


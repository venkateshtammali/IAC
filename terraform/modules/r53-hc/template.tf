
# Create SNS from module
 module "sns" {
  source = "./../sns"

  env    = "${var.env}"
  email_addresses= ["abc@gmail.com"]
}





resource "aws_sns_topic" "route53-healthcheck-sns" {
  name      = "route53-healthcheck"
}

resource "aws_route53_health_check" "r53_healthcheck" {
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

resource "aws_cloudwatch_metric_alarm" "route53-healthcheck-alarm" {
  alarm_name                = "${var.env}-${var.domain}-alarm"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "HealthCheckStatus"
  namespace                 = "AWS/Route53"
  period                    = "60" #in seconds
  statistic                 = "Minimum"
  threshold                 = "2"
  alarm_description         = "This metric monitors whether the server is down or not."
  alarm_actions             = ["${aws_sns_topic.route53-healthcheck-sns.arn}"]
  dimensions = {
    HealthCheckId           = "${aws_route53_health_check.r53_healthcheck.id}"
  }
}


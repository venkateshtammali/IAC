resource "aws_sns_topic" "alarm" {
  name = "topic-alarms"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}



resource "aws_sns_topic" "route53-healthcheck-sns" {
  name      = "route53-healthcheck"
}

resource "aws_route53_health_check" "r53_healthcheck" {
  fqdn              = "my.domain.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/SalesPortal/#!/"
  failure_threshold = "3"
  request_interval  = "30"
  measure_latency   = "1"
  tags = {
    Name = "${var.env}-r53-hc"
   }
}

resource "aws_cloudwatch_metric_alarm" "route53-healthcheck-alarm" {
  alarm_name                = "r53-alarm"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "HealthCheckStatus"
  namespace                 = "AWS/Route53"
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = "2"
  alarm_description         = "This metric monitor whether the server is down or not."
  alarm_actions             = ["${aws_sns_topic.route53-healthcheck-sns.arn}"]
  dimensions = {
    HealthCheckId           = "${aws_route53_health_check.r53_healthcheck.id}"
  }
}


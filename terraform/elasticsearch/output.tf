output "arn" {
  value = "${aws_elasticsearch_domain.es.arn}"
}

output "domain" {
  value = "${aws_elasticsearch_domain.es.domain_id}"
}

output "endpoint" {
  value = "${aws_elasticsearch_domain.es.endpoint}"
}

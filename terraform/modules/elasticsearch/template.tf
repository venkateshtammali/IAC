resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.env}-es"
  elasticsearch_version = "6.7"
  cluster_config {
    instance_type  = "t2.small.elasticsearch"
    instance_count = 1

    dedicated_master_enabled = "false"
  }
  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${var.env}-es",
    )
  )}"
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true" # double quotes are required here
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
}


resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.env}-es"
  elasticsearch_version = "6.7"
  cluster_config {
    instance_type  = "${var.worker_instance_type}"
    instance_count = "${var.worker_instance_count}"

    dedicated_master_enabled = "${var.dedicated_master_enabled}"
    dedicated_master_type    = "${var.master_instance_type}"
    dedicated_master_count   = "${var.master_instance_count}"
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true" # double quotes are required here
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
  tags = "${merge(var.default_tags, map("Name", "${var.env}-es", ))}"
}


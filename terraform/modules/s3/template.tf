data "aws_kms_alias" "s3_kms" {
  name = "alias/aws/s3"
}

resource "aws_s3_bucket" "s3" {
  bucket = "events-${var.env}-s3"
  acl    = "private"
  region = "${var.region}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "${data.aws_kms_alias.s3_kms.arn}"
      }
    }
  }
  tags = "${merge(var.default_tags, map("Name", "event-${var.env}-s3", ))}"
}



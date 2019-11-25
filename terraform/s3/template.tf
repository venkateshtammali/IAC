resource "aws_s3_bucket" "s3" {
  bucket = "events-${var.env}-s3"
  acl    = "private"
  region = "${var.region}"
}
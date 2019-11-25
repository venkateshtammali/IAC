provider "aws" {
  region = "us-east-1"
}
variable "TF_ENV" {
  type = "string"
  
}

resource "aws_s3_bucket" "bucket" {
  acl    = "private"
}
resource "aws_iam_role" "firehose_role" {
   name = "${var.TF_ENV}-fh"
   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal":{
      "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}      
EOF
}


resource "aws_iam_role_policy" "firehose_policy" {
  name  = "${var.TF_ENV}-fpl"
  role  = "${aws_iam_role.firehose_role.id}"

  policy = <<EOF
{
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:AbortMultipartUpload",
              "s3:GetBucketLocation",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:ListBucketMultipartUploads",
              "s3:PutObject"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}",
              "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
          ]
      },
      {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["${aws_s3_bucket.bucket.arn}"]
      },
      {
          "Action": "es:*",
          "Effect": "Allow",
          "Resource": "${aws_elasticsearch_domain.es.arn}/*"
      }
    ]
}
EOF
}
resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.TF_ENV}-domain"
  elasticsearch_version = "6.7"
  cluster_config {
    instance_type = "t2.small.elasticsearch"
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }
  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Domain = "${var.TF_ENV}-domain"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "test_stream" {
  name        = "terraform-kinesis-firehose-test-stream"
  destination = "elasticsearch"

  s3_configuration {
    role_arn           = "${aws_iam_role.firehose_role.arn}"
    bucket_arn         = "${aws_s3_bucket.bucket.arn}"
    buffer_size        = 3
    buffer_interval    = 60
    compression_format = "GZIP"
  }

  elasticsearch_configuration {
    domain_arn = "${aws_elasticsearch_domain.es.arn}"
    role_arn   = "${aws_iam_role.firehose_role.arn}"
    index_name = "test"
    type_name  = "test"
  }
}

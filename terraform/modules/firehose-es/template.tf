locals {
  firehose_name = "${var.env}-fh"
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

module "s3" {
  source = "./../s3"

  env          = "${var.env}"
  region       = "${var.region}"
  default_tags = "${var.default_tags}"
}

module "es" {
  source = "./../elasticsearch"

  env          = "${var.env}"
  default_tags = "${var.default_tags}"
}

# Create log group for Firehose
resource "aws_cloudwatch_log_group" "fh_lg" {
  name = "/aws/kinesisfirehose/${local.firehose_name}"

}

# Create log stream for S3
resource "aws_cloudwatch_log_stream" "s3_ls" {
  name           = "S3Delivery"
  log_group_name = "${aws_cloudwatch_log_group.fh_lg.name}"
}

resource "aws_cloudwatch_log_stream" "es_ls" {
  name           = "ElasticsearchDelivery"
  log_group_name = "${aws_cloudwatch_log_group.fh_lg.name}"
}

resource "aws_iam_role" "fh-rl" {
  name               = "${var.env}-fh-rl"
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


resource "aws_iam_role_policy" "fh-pl" {
  name = "${var.env}-fh-pl"
  role = "${aws_iam_role.fh-rl.id}"

  policy = <<EOF
{
    "Statement": [{
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
            "${module.s3.arn}",
            "${module.s3.arn}/*"
        ]
    }, {
        "Effect": "Allow",
        "Action": [
            "es:DescribeElasticsearchDomain",
            "es:DescribeElasticsearchDomains",
            "es:DescribeElasticsearchDomainConfig",
            "es:ESHttpPost",
            "es:ESHttpPut"
        ],
        "Resource": [
            "${module.es.arn}",
            "${module.es.arn}/*"
        ]
    }, {
        "Effect": "Allow",
        "Action": [
            "es:ESHttpGet"
        ],
        "Resource": [
            "${module.es.arn}/_all/_settings",
            "${module.es.arn}/_cluster/stats",
            "${module.es.arn}/events*/_mapping/_doc",
            "${module.es.arn}/_nodes",
            "${module.es.arn}/_nodes/stats",
            "${module.es.arn}/_nodes/*/stats",
            "${module.es.arn}/_stats",
            "${module.es.arn}/events*/_stats"
        ]
    }, {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "logs:PutLogEvents"
        ],
        "Resource": [
          "${aws_cloudwatch_log_group.fh_lg.arn}"
        ]
    }]
}
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "fh" {
  name        = "${local.firehose_name}"
  destination = "elasticsearch"
  server_side_encryption {
    enabled = true
  }

  s3_configuration {
    role_arn        = "${aws_iam_role.fh-rl.arn}"
    bucket_arn      = "${module.s3.arn}"
    buffer_size     = 1
    buffer_interval = 60
    kms_key_arn     = "${data.aws_kms_alias.s3.arn}"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "${aws_cloudwatch_log_group.fh_lg.name}"
      log_stream_name = "${aws_cloudwatch_log_stream.s3_ls.name}"
    }
  }

  elasticsearch_configuration {
    domain_arn            = "${module.es.arn}"
    role_arn              = "${aws_iam_role.fh-rl.arn}"
    index_name            = "events"
    type_name             = "_doc"
    index_rotation_period = "NoRotation"
    buffering_size        = 1
    buffering_interval    = 60
    retry_duration        = 60
    s3_backup_mode        = "AllDocuments"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "${aws_cloudwatch_log_group.fh_lg.name}"
      log_stream_name = "${aws_cloudwatch_log_stream.es_ls.name}"
    }
  }
  tags = "${merge(var.default_tags)}"
}

module "fh-s3" {
  source = "./../s3"

  env    = "${var.env}"
  region = "${var.region}"
}

module "fh-es" {
  source = "./../elasticsearch"

  env = "${var.env}"
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
            "${module.fh-s3.arn}",
            "${module.fh-s3.arn}/*"
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
            "${module.fh-es.arn}",
            "${module.fh-es.arn}/*"
        ]
    }, {
        "Effect": "Allow",
        "Action": [
            "es:ESHttpGet"
        ],
        "Resource": [
            "${module.fh-es.arn}/_all/_settings",
            "${module.fh-es.arn}/_cluster/stats",
            "${module.fh-es.arn}/events*/_mapping/_doc",
            "${module.fh-es.arn}/_nodes",
            "${module.fh-es.arn}/_nodes/stats",
            "${module.fh-es.arn}/_nodes/*/stats",
            "${module.fh-es.arn}/_stats",
            "${module.fh-es.arn}/events*/_stats"
        ]
    }]
}
EOF
}


resource "aws_kinesis_firehose_delivery_stream" "fh" {
  name        = "${var.env}-fh"
  destination = "elasticsearch"

  s3_configuration {
    role_arn        = "${aws_iam_role.fh-rl.arn}"
    bucket_arn      = "${module.fh-s3.arn}"
    buffer_size     = 1
    buffer_interval = 60
  }

  elasticsearch_configuration {
    domain_arn = "${module.fh-es.arn}"
    role_arn   = "${aws_iam_role.fh-rl.arn}"
    index_name = "events"
    type_name  = "_doc"
    index_rotation_period = "NoRotation"
    buffering_size = 1
    buffering_interval = 60
    s3_backup_mode = "AllDocuments"
  }
}

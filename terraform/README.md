# Terraform Style Guide

**Table of Contents**

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
- [Introduction](#introduction)
- [Syntax](#syntax)
  - [Spacing](#spacing)
  - [Block Alignment](#block-alignment)
  - [Comments](#comments)
  - [Organizing Variables](#organizing-variables)
- [Naming Conventions](#naming-conventions)
  - [File Names](#file-names)
  - [Resource Reference Naming](#resource-reference-naming)
  - [Resource Naming](#resource-naming)

## Introduction

This file gives coding conventions for Terraform's HashiCorp Configuration Language (HCL). Terraform allows infrastructure to be described as code. As such, we should adhere to a style guide to ensure readable and high quality code.

## Syntax

- Strings are in double-quotes.

### Spacing

Use 2 spaces when defining resources except when defining inline policies or other inline resources.

```
resource "aws_iam_role" "iam_role" {
  name = "${var.resource_name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
```

### Block Alignment

Parameter definitions in a resource block should be aligned. The `terraform fmt` command can do this for you.

```
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}
```

### Comments

When commenting use two "//" and a space in front of the comment.

```
// CREATE ELK IAM ROLE 
...
```

### Organizing Variables

The `variables.tf` file should be broken down into three sections with each section arranged alphabetically. Starting at the top of the file:

1. Variables that have no defaults defined
2. Variables that contain defaults
3. All locals blocks
4. variables can have 

For example:

```
variable "image_tag" {}

variable "desired_count" {
  default = "2"
}

locals {
  domain_name = "${data.terraform_remote_state.account.domain_name}"
}
```

## Naming Conventions

### File Names

Create a separate resource file for each type of AWS resource. Similar resources should be defined in the same file and named accordingly.

```
ami.tf
autoscaling-group.tf
cloudwatch.tf
iam.tf
launch-configuration.tf
providers.tf
s3.tf
security-groups.tf
sns.tf
sqs.tf
user-data.sh
variables.tf
```

### Resource Reference Naming

__A resource's reference name__
1. should be short and simple 
2. should use `_` if multiple words
3. Should have suffix at the end like s3, rl, pl, asg, sg.

```
//fh_rl is resource reference
resource "aws_iam_role" "fh_rl" {
  ...
}
```

### Resource Naming

__A resource's reference name__
1. should be short and simple 
2. should use `-` if multiple words
3. Should have suffix at the end like s3, rl, pl, asg, sg.

```
resource "aws_security_group" "fh_sg" {
  name = "${var.resource_name}-fh-sg"
  ...
}
```

If there are multiple resources of the same TYPE defined, add a minimalist identifier to differentiate between the two resources. A blank line should separate resource definitions contained in the same file.

```
// Create Data S3 Bucket
resource "aws_s3_bucket" "data_s3" {
  bucket = "${var.env}-data-${var.region}-s3"
  acl    = "private"
  versioning {
    enabled = true
  }
}

// Create Images S3 Bucket
resource "aws_s3_bucket" "images_s3" {
  bucket = "${var.env}-images-${var.region}-s3"
  acl    = "private"
}
```
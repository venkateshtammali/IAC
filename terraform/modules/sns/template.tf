data "aws_kms_alias" "sns_kms" {
  name = "alias/aws/sns"
}

data "template_file" "cloudformation_sns_stack" {
  template = "${file("${path.module}/templates/email-sns-stack.json.tpl")}"

  vars = {
    display_name  = "${var.display_name}-cf"
    kms_id        = "${data.aws_kms_alias.sns_kms.target_key_id}"
    subscriptions = "${join(",", formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\"  }", var.email_addresses, "email"))}"
  }
}

resource "aws_cloudformation_stack" "sns_topic" {
  name          = "${var.display_name}"
  template_body = "${data.template_file.cloudformation_sns_stack.rendered}"

  tags = "${var.default_tags}"
}


resource "aws_ecr_repository" "ecr" {
  name                 = "${var.env}-ecr"
  image_tag_mutability = "MUTABLE" # There two types mutable and immutable by default is mutable

  image_scanning_configuration {
    scan_on_push = true # Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false).
  }
  tags = "${merge(var.default_tags, map("Name", "${var.env}-ecr", ))}"
}


resource "aws_ecr_lifecycle_policy" "ecr_pl" {
  repository = "${aws_ecr_repository.ecr.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 5 images",      
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


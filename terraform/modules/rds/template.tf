data "aws_kms_alias" "rds_kms" {
  name = "alias/aws/rds"
}

locals {
  prefix = "${var.env}-${var.service_acronym}"
}

# Create subnet group for rds
resource "aws_db_subnet_group" "rds_sng" {
  name       = "${local.prefix}-sng"
  subnet_ids = "${var.subnet_ids}"
}

# Create security group for rds
resource "aws_security_group" "rds_sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "${local.prefix}-sg"
  description = "Allow RDS to be accesible on port 5432"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  # Metadata
  engine         = "postgres"
  engine_version = "11.5"
  instance_class = "db.t2.medium" # Minimum t2.medium for encryptio
  identifier     = "${local.prefix}-rds"

  # Storage
  allocated_storage         = 20 # In GB
  max_allocated_storage     = 30
  storage_encrypted         = true
  kms_key_id                = "${data.aws_kms_alias.rds_kms.target_key_arn}"
  final_snapshot_identifier = "some-snap" #Explore during backup

  # Accessibility
  name                = "apty"            #DB Name
  username            = "master"          # User Name
  password            = "${var.password}" # password for login
  port                = 5432
  publicly_accessible = false
  ca_cert_identifier  = "rds-ca-2019"

  # Networking
  db_subnet_group_name   = "${aws_db_subnet_group.rds_sng.name}"
  multi_az               = true
  storage_type           = "gp2"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]

  # Upgrades
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = true

  copy_tags_to_snapshot = true
  deletion_protection   = true

  # performance insights
  performance_insights_enabled    = true
  performance_insights_kms_key_id = "${data.aws_kms_alias.rds_kms.target_key_arn}" # should provide arn as value

  # Monitoring
  monitoring_interval = 0

  # Backup
  backup_window           = "00:00-00:00" # time to start backups
  backup_retention_period = 1             # particular days of backup by default is 7 
  # skip_final_snapshot  = false      # it will create the snapshot when ever we destroy the instance by default is false

  tags = "${merge(var.default_tags, map("Name", "${local.prefix}-rds", ))}"

}


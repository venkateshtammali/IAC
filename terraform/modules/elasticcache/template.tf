# Security GP
resource "aws_security_group" "ec_sg" {
  description = "Allow TLS inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-ec-sg"
  }
}

resource "aws_elasticache_subnet_group" "ec_sng" {
  name       = "${var.env}-ec-sng"
  subnet_ids = "${var.subnet_ids}"
}

resource "aws_elasticache_cluster" "ec" {
  cluster_id           = "${var.env}-ec"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.5"
  port                 = 6379
  subnet_group_name    = "${aws_elasticache_subnet_group.ec_sng.name}"
  security_group_ids = ["${aws_security_group.ec_sg.id}"]
}
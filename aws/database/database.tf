##############
# DB instance
##############
resource "aws_db_instance" "database" {
  identifier = "${var.identifier}"
  engine            = "${var.engine}"
  engine_version    = "${var.engine_version}"
  instance_class    = "${var.instance_class}"
  allocated_storage = "${var.allocated_storage}"
  storage_type      = "${var.storage_type}"
  storage_encrypted = "${var.storage_encrypted}"
  db_subnet_group_name   = "${var.db_subnet_group_name}"

  name                                = "${var.name}"
  username                            = "${var.username}"
  password                            = "${var.password}"
  port                                = "${var.port}"
  snapshot_identifier = "${var.snapshot_identifier}"
  multi_az            = "${var.multi_az}"
  publicly_accessible = "${var.publicly_accessible}"
  maintenance_window          = "${var.maintenance_window}"
  backup_window           = "${var.backup_window}"
  backup_retention_period = "${var.backup_retention_period}"
  tags = "${merge(var.tags, map("Name", format("%s", var.identifier)))}"
  final_snapshot_identifier   = "${var.final_snapshot_identifier}"
}

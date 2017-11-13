output "database_instance_address" {
  description = "The address of the RDS instance"
  value       = "${aws_db_instance.database.address}"
}

output "database_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = "${aws_db_instance.database.arn}"
}

output "database_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = "${aws_db_instance.database.availability_zone}"
}

output "database_instance_endpoint" {
  description = "The connection endpoint"
  value       = "${aws_db_instance.database.endpoint}"
}

output "database_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = "${aws_db_instance.database.hosted_zone_id}"
}

output "database_instance_id" {
  description = "The RDS instance ID"
  value       = "${aws_db_instance.database.id}"
}

output "database_instance_resource_id" {
  description = "The RDS Resource ID of database instance"
  value       = "${aws_db_instance.database.resource_id}"
}

output "database_instance_status" {
  description = "The RDS instance status"
  value       = "${aws_db_instance.database.status}"
}

output "database_instance_name" {
  description = "The database name"
  value       = "${aws_db_instance.database.name}"
}

output "database_instance_port" {
  description = "The database port"
  value       = "${aws_db_instance.database.port}"
}

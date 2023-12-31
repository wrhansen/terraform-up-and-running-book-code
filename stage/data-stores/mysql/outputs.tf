output "address" {
  value       = module.mysql_primary.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = module.mysql_primary.port
  description = "The port the database is listening on"
}

output "arn" {
  value       = module.mysql_primary.arn
  description = "The ARN of the database"
}

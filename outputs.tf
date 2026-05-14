output "postgres_id" {
  value       = try(sws_managed_database.postgres[0].id, null)
  description = "Postgres managed-database id. null when pg_enabled = false."
}

output "postgres_endpoint" {
  description = "Hostname/IP and port for psql clients. Defaults to 5432; override via var.postgres_port if your datastore template differs."
  value = try({
    host = sws_managed_database.postgres[0].address
    port = var.postgres_port
  }, null)
}

output "postgres_explorer_url" {
  description = "Click this in your browser to open the in-console DB Explorer."
  value       = try("https://savannaa.com/database/${sws_managed_database.postgres[0].id}/explorer", null)
}

output "mysql_id" {
  value       = try(sws_managed_database.mysql[0].id, null)
  description = "MySQL managed-database id. null when mysql_enabled = false."
}

output "mysql_endpoint" {
  description = "Hostname/IP and port for mysql clients. Defaults to 3306; override via var.mysql_port if your datastore template differs."
  value = try({
    host = sws_managed_database.mysql[0].address
    port = var.mysql_port
  }, null)
}

output "mysql_explorer_url" {
  value = try("https://savannaa.com/database/${sws_managed_database.mysql[0].id}/explorer", null)
}

output "cache_id" {
  value       = try(sws_cache.cache[0].id, null)
  description = "Cache instance id. null when cache_enabled = false."
}

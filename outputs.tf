output "postgres_id" {
  value       = try(sws_managed_database.postgres[0].id, null)
  description = "Postgres managed-database id. null when pg_enabled = false."
}

output "postgres_endpoint" {
  description = "Hostname/IP and port for psql clients."
  value = try({
    host = sws_managed_database.postgres[0].ip[0]
    port = sws_managed_database.postgres[0].port
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
  value = try({
    host = sws_managed_database.mysql[0].ip[0]
    port = sws_managed_database.mysql[0].port
  }, null)
}

output "mysql_explorer_url" {
  value = try("https://savannaa.com/database/${sws_managed_database.mysql[0].id}/explorer", null)
}

output "cache_id" {
  value       = try(sws_cache.cache[0].id, null)
  description = "Cache instance id. null when cache_enabled = false."
}

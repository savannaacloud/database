terraform {
  required_providers {
    sws = { source = "savannaacloud/sws", version = "~> 0.4" }
  }
}

# Smallest data-tier footprint: one tiny postgres, nothing else.
# Apply this first to confirm your auth + network are wired.

variable "network_id" {
  type        = string
  description = "Existing private network ID."
}

resource "sws_managed_database" "pg" {
  name       = "database-minimal-pg"
  datastore  = "postgresql"
  version    = "16"
  flavor_id  = "r1.small"
  size       = 10
  network_id = var.network_id
}

output "psql_endpoint" {
  value = "psql postgres://admin:<password>@${sws_managed_database.pg.ip[0]}:${sws_managed_database.pg.port}/postgres"
}

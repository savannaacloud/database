data "sws_network" "default" { name = var.network_name }

locals {
  prefix = var.prefix
}

# ── Managed Databases ──────────────────────────────────────────────────────
# Two engines deployed independently. Toggle each via vars; default is pg
# only because spinning up both costs an extra ~3 min on first apply.
#
# Each managed_database resource creates:
#   * a dedicated VM with the engine pre-installed
#   * an admin user (root_enabled=true means root is reachable on the VIP)
#   * automatic backups (configured via the sibling Storage module's
#     backup_policy resource, or via the console)
#   * a security group locking the engine port to the network

resource "sws_managed_database" "postgres" {
  count = var.pg_enabled ? 1 : 0

  name       = "${local.prefix}-pg"
  datastore  = "postgresql"
  version    = var.pg_version
  flavor_id  = var.db_flavor
  size       = var.db_size_gb
  network_id = data.sws_network.default.id
}

resource "sws_managed_database" "mysql" {
  count = var.mysql_enabled ? 1 : 0

  name       = "${local.prefix}-mysql"
  datastore  = "mysql"
  version    = var.mysql_version
  flavor_id  = var.db_flavor
  size       = var.db_size_gb
  network_id = data.sws_network.default.id
}

# ── Database Explorer ──────────────────────────────────────────────────────
# Database Explorer is a console-only feature — it's a built-in web client
# (psql / mysql wrapper running server-side) that lets you browse schemas,
# run queries, and pin saved queries WITHOUT exposing the DB to the public
# internet. It mounts onto the same VIP this module creates.
#
# After `terraform apply`, open it at:
#   https://savannaa.com/database/${self.id}/explorer
#
# There is intentionally no terraform resource: the Explorer is a managed
# UI service, not user-deployed infrastructure. It auto-enables for every
# managed_database the platform creates.
#
# If you want IaC-style access control to the Explorer, use the platform's
# IAM groups (terraform support coming — see sws_iam_group on the roadmap).

# ── Cache ──────────────────────────────────────────────────────────────────
# Managed Redis/memcached. Same security model as managed_database — VIP
# scoped to network_id, no public exposure by default.

resource "sws_cache" "cache" {
  count = var.cache_enabled ? 1 : 0

  name = "${local.prefix}-cache"
  config = jsonencode({
    engine     = var.cache_engine
    version    = var.cache_version
    flavor_id  = var.cache_flavor
    network_id = data.sws_network.default.id
  })
}

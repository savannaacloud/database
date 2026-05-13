variable "prefix" {
  description = "Prefix for every resource name so multiple environments coexist."
  type        = string
  default     = "database-demo"
}

variable "region" {
  description = "Savannaa region: ng-abuja-1 or ng-lagos-1."
  type        = string
  default     = "ng-abuja-1"
}

variable "network_name" {
  description = "Name of an existing network (defaults to 'default' — auto-created at signup)."
  type        = string
  default     = "default"
}

# ── Managed Database knobs ────────────────────────────────────────────────

variable "pg_enabled" {
  description = "Create a Postgres managed database."
  type        = bool
  default     = true
}

variable "pg_version" {
  description = "Postgres major version."
  type        = string
  default     = "16"
}

variable "mysql_enabled" {
  description = "Create a MySQL managed database (independent of pg)."
  type        = bool
  default     = false
}

variable "mysql_version" {
  description = "MySQL version."
  type        = string
  default     = "8.4"
}

variable "db_flavor" {
  description = "Compute size for managed-database instances. r1.* are RAM-optimised."
  type        = string
  default     = "r1.medium"
}

variable "db_size_gb" {
  description = "Persistent disk size per database (GiB)."
  type        = number
  default     = 20
}

# ── Cache knobs ────────────────────────────────────────────────────────────

variable "cache_enabled" {
  description = "Create a managed Redis-compatible cache."
  type        = bool
  default     = true
}

variable "cache_engine" {
  description = "Cache engine: redis or memcached."
  type        = string
  default     = "redis"
}

variable "cache_version" {
  description = "Engine version (engine-specific)."
  type        = string
  default     = "7.2"
}

variable "cache_flavor" {
  description = "Cache instance size."
  type        = string
  default     = "m1.small"
}

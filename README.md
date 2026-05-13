# Database — Savannaa Terraform Module

End-to-end terraform that deploys every **Database** product on Savannaa from one root module:

| Product | Resource | Notes |
|---|---|---|
| **Managed Databases** | `sws_managed_database` | Single-tenant Postgres or MySQL VM with admin user, backups, security group. Module spins up Postgres by default; flip `mysql_enabled = true` to add MySQL alongside. |
| **Database Explorer** | _(console-only)_ | Built-in web SQL client that auto-mounts onto every managed_database. No terraform resource — open `https://savannaa.com/database/<id>/explorer` after apply. |
| **Cache** | `sws_cache` | Managed Redis or memcached. Same VIP-on-private-network model as managed_database. |

---

## Prerequisites

1. A Savannaa account → **API key** from https://savannaa.com/account/api-keys.
2. **terraform** ≥ 1.5 ([install](https://developer.hashicorp.com/terraform/install)).
3. An existing **private network ID** from the console → Networks. The DB + cache attach here and stay off the public internet by default.

---

## Step-by-step

### 1. Clone

```bash
git clone https://github.com/savannaacloud/database.git
cd database
```

### 2. Set credentials

```bash
export SWS_API_URL="https://savannaa.com"
export SWS_API_KEY="sws_..."           # https://savannaa.com/account/api-keys
```

### 3. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars               # set network_id at minimum
```

### 4. Initialise

```bash
terraform init
```

### 5. Preview

```bash
terraform plan
```

With defaults you'll see:
* 1 × Postgres (`pg_enabled = true`, version 16, r1.medium, 20 GiB)
* 1 × Cache (`cache_enabled = true`, redis 7.2, m1.small)
* MySQL skipped (`mysql_enabled = false`)

### 6. Apply

```bash
terraform apply
```

Type `yes`. Apply takes:

* Postgres alone: ~3 min.
* Postgres + MySQL: ~5 min (parallel-built but separate amphora boots).
* + Cache: +60 s.

### 7. Open the Database Explorer

```bash
terraform output -raw postgres_explorer_url
```

Open the URL in your browser. Authenticated by your Savannaa session — no separate creds. Run queries, save common ones to your sidebar, export results as CSV.

### 8. Connect a real client

```bash
# Postgres
PGPASSWORD=<from console "Reveal password"> \
  psql -h $(terraform output -json postgres_endpoint | jq -r .host) \
       -p $(terraform output -json postgres_endpoint | jq -r .port) \
       -U admin postgres

# Redis cache (from any VM in the same network)
redis-cli -h <cache VIP from console>
```

The admin password isn't in terraform state — it's revealed once in the console at first creation, or rotated on demand from the same page.

### 9. Tear down

```bash
terraform destroy
```

~60-90 s. Snapshots (if any were taken via the Storage module's backup_policy) survive in your project's Recycle Bin for 24 h.

---

## Layout

```
database/
├── README.md                    ← you are here
├── versions.tf                  ← provider pin (sws ~> 0.4)
├── variables.tf                 ← 12 vars (engine versions, sizes, toggles)
├── main.tf                      ← managed_database (pg + mysql) + cache
├── outputs.tf                   ← endpoints, Explorer URLs
├── terraform.tfvars.example     ← copy → terraform.tfvars and edit
├── .gitignore                   ← keeps state out of the repo
└── examples/
    └── minimal/                 ← single tiny postgres; smoke-test
```

---

## Picking the right `db_flavor`

| Flavor | vCPU / RAM | Workload | Cost tier |
|---|---|---|---|
| `r1.small` | 2 / 8 GiB | dev/staging, small apps | $ |
| `r1.medium` | 4 / 16 GiB | production OLTP — **module default** | $$ |
| `r1.large` | 8 / 32 GiB | high-throughput, multi-tenant SaaS | $$$ |
| `r1.xlarge` | 16 / 64 GiB | analytical, big in-memory workloads | $$$$ |

`r1.*` are RAM-optimised — better for Postgres / MySQL than `m1.*`.

---

## Database Explorer — what's in it

Once apply finishes, the Explorer for each database is at:

```
https://savannaa.com/database/<id>/explorer
```

It includes:

* **Schema browser** — click through databases → schemas → tables → columns.
* **Query editor** — autocomplete, syntax highlight, multi-statement, EXPLAIN button.
* **Saved queries** — pin queries to a sidebar, shareable inside the project.
* **CSV export** — download any result set.
* **Activity log** — every query is logged for audit (off by default for prod; toggle in the database's Settings tab).

The Explorer runs server-side (psql / mysql process inside the same VPC as the DB), so connections never traverse the public internet.

---

## Common gotchas

* **`Multiple security_group matches`** — stale SGs from a prior failed apply. Backend dedupes by UUID now (since `python-backend` PR #311), but if you saw this in an old session, just `terraform apply` again.
* **`flavor not found`** — region capacity. Try `db_flavor = "r1.small"` or switch region.
* **`network_id required`** — `terraform.tfvars` placeholder not edited.
* **Explorer page loads but query errors** — the DB itself is fine; the Explorer waits for the admin password to be revealed in the console once (security model). Open the database's **Credentials** tab once and re-run the query.
* **Cache reachable from VM but not from terraform** — that's correct. Cache has no public IP by design; `terraform apply` connects via the orchestration API, not direct redis-protocol.

---

## Region toggle

```hcl
region = "ng-lagos-1"     # was "ng-abuja-1"
```

Both regions support Postgres / MySQL / Redis / memcached. Plans + capacity are independent per region.

---

## CI usage

```yaml
- uses: hashicorp/setup-terraform@v3
- run: terraform init && terraform apply -auto-approve
  env:
    SWS_API_URL: https://savannaa.com
    SWS_API_KEY: ${{ secrets.SWS_API_KEY }}
    TF_VAR_network_id: ${{ vars.NETWORK_ID }}
```

---

## Support

* Console: https://savannaa.com/database
* Docs: https://savannaa.com/docs
* Issues with this module: https://github.com/savannaacloud/database/issues

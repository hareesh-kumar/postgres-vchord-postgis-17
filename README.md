# PostgreSQL 17 + Extensions (Immich, Dawarich, Adventurelog, Paperless-NGX)

This folder contains everything needed to build a PostgreSQL 17 image with the required extensions for **Immich**, **Dawarich**, **Adventurelog**, and **Paperless-NGX**. The image and init scripts are pinned to exact versions to ensure compatibility and repeatable builds on your NAS.

---

## 📂 Folder Structure

```
/volume1/docker/postgresql/
│
├── data/                        # PostgreSQL data directory (persistent)
│
└── docker/                      # Build context folder for Docker
    ├── Dockerfile               # Main image build file (no file extension)
    ├── init-extensions.sql      # SQL script to enable extensions on first init
    ├── check-extensions.sh      # Startup check script to verify extension versions
    └── README.md                # This file (pinned versions)
```

---

## 🛠 Included Extensions (Pinned)

| Extension      | Purpose                                                   | Version (Pinned) |
|----------------|-----------------------------------------------------------|------------------:|
| `PostgreSQL`   | Database server                                           | `17.0`            |
| `pgvector`     | Vector search (used by Immich AI features)                | `0.8.0`           |
| `vchord`       | VectorChord indexing (for Immich + vector search)         | `0.4.3`           |
| `PostGIS`      | Geospatial queries (used by Dawarich / AdventureLog)      | `3.5.0` (packaged as `3.5.0+dfsg-1.pgdg110+1`) |
| `pg_trgm`      | Trigram text search (postgres contrib)                    | (built into contrib) |
| `unaccent`     | Normalizes text for searching                             | (built into contrib) |
| `earthdistance`| Distance utilities                                        | (built into contrib) |
| `pgcrypto`     | Cryptographic functions                                   | (built into contrib) |
| `uuid-ossp`    | UUID generation                                           | (built into contrib) |
| `hstore`       | Key/value store inside Postgres                           | (built into contrib) |

> **Note:** The PostGIS package string (`3.5.0+dfsg-1.pgdg110+1`) is the Debian/PGDG packaging name we pinned when building on Debian/Ubuntu-like distributions. If your NAS uses a different packaging name, adjust the Dockerfile and `check-extensions.sh` accordingly.

---

## 🚀 How to Build & Run (Portainer / Docker Compose)

1. **Place files correctly**  
   Ensure your folder structure matches the one above. Files should be in `/volume1/docker/postgresql/docker/` for the build context.

2. **Build & deploy with Docker Compose** (from `/volume1/docker/postgresql/`):
   ```bash
   docker compose up -d --build
   ```

3. **Verify installed extensions** (after container starts):
   ```bash
   docker exec -it PostgreSQL psql -U root -d harvi_DB -c "\dx"
   ```

4. **Check Postgres logs**:
   ```bash
   docker logs PostgreSQL
   ```

---

## 📋 How the version check works

- `check-extensions.sh` runs on first initialization (it is copied to `/docker-entrypoint-initdb.d/00-check-extensions.sh`) and temporarily starts Postgres to verify the installed extension versions match the pinned values below:
  - `pgvector` (extension `vector`) — **0.8.0**
  - `vchord` (extension `vchord`) — **0.4.3**
  - `postgis` (extension `postgis`) — **3.5.0**

If any extension is missing or its version mismatches, the script exits and prevents the container from finishing init so you can fix the build/dockerfile before accepting a potentially incompatible database state.

---

## 🧹 Maintenance & Upgrades

- To bump versions, edit `Dockerfile` and change the pinned tags/packaging, then rebuild (`docker compose up -d --build`). Update `check-extensions.sh` with the new expected versions.
- **Back up** your DB before making major changes:
  ```bash
  docker exec PostgreSQL pg_dump -U root harvi_DB > backup.sql
  ```

---

## ⚠️ Troubleshooting

- If the stack fails to build in Portainer: ensure `Dockerfile` and the two init files are in the build **context path** you provided (`/volume1/docker/postgresql/docker/`). Portainer must have read access to that folder.
- If `check-extensions.sh` reports a different PostGIS package string than expected, run inside the container:
  ```bash
  docker exec -it PostgreSQL psql -U root -d harvi_DB -c "SELECT extname, extversion FROM pg_extension;"
  ```
  and adjust the pinned string if needed.

---

**Author:** Harvi's NAS Postgres Stack  
**Pinned versions:** PostgreSQL 17.0 · pgvector 0.8.0 · vchord 0.4.3 · PostGIS 3.5.0 (pgdg)  
**Last Updated:** 2025-08-08

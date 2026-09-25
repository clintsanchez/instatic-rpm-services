# RPM Services — Instatic trial

Fork of [CoreBunch/Instatic](https://github.com/CoreBunch/Instatic) used to trial Instatic as the RPM Services site builder, side by side with the WordPress + Etch recommendation. This is not a platform decision. Client source of truth: the `rpm-services` pCloud repo.

## Run

```sh
./rpm-services.sh up       # start; builds the image the first time
./rpm-services.sh build    # rebuild after changing fork code
./rpm-services.sh logs | ps | down
./rpm-services.sh backup   # WAL checkpoint, then copy cms.db + uploads to ./backups/
```

- Container: `rpm-services`. Compose project: `rpm-services`. URL: http://localhost:3031 (override with `HOST_PORT`).
- SQLite at `/app/data/cms.db` in volume `rpm-services_data`; media in `rpm-services_uploads`.
- `.env` (gitignored, mode 600) holds `INSTATIC_SECRET_KEY`. It encrypts stored AI/MCP credentials and signs form tokens. Keep the same value if this moves to staging or production; losing it strands encrypted data.

## Why built from source

The GHCR image is amd64-only and its Bun segfaults under Rosetta on Apple Silicon. The image builds natively for arm64 with `BUILD_COMMAND` skipping `tsc -b`, which runs out of memory in the default 2 GB Docker Desktop VM.

## Upstream updates

```sh
git fetch upstream && git merge upstream/main && ./rpm-services.sh build
```

The fork's only change to upstream files is the `BUILD_COMMAND` arg in `Dockerfile`, which defaults to the upstream behavior.

## Connecting Claude (MCP)

1. Open http://localhost:3031/admin/setup and create the owner account.
2. In the admin, open AI → MCP connections and create a personal access token (`imcp_pat_…`, shown once).
3. `claude mcp add --transport http instatic-rpm http://localhost:3031/_instatic/mcp --header "Authorization: Bearer <token>"`
4. Keep the Site editor tab open while authoring. The editing tools relay through it.

Hosted OAuth connectors (claude.ai) cannot reach localhost. They need an HTTPS public origin.

#!/usr/bin/env bash
# Wrapper for the RPM Services Instatic container.
#   ./rpm-services.sh up | build | down | logs | ps | backup
set -euo pipefail
cd "$(dirname "$0")"

compose() {
  docker compose -f compose.prod.yml -f compose.sqlite.yml \
    -f compose.rpm-services.yml "$@"
}

case "${1:-}" in
  up)     compose up -d ;;
  # Stop first: the Vite build does not fit in a 2 GB Docker VM beside the app.
  build)  compose stop app; compose build && compose up -d ;;
  down)   compose down ;;
  logs)   compose logs -f app ;;
  ps)     compose ps ;;
  backup)
    out="backups/rpm-services-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$out"
    docker exec rpm-services bun -e \
      'import {Database} from "bun:sqlite"; new Database("/app/data/cms.db").run("PRAGMA wal_checkpoint(TRUNCATE)")'
    docker cp rpm-services:/app/data/cms.db "$out/cms.db"
    docker cp rpm-services:/app/uploads "$out/uploads"
    echo "Backed up to $out" ;;
  *) echo "usage: $0 up|down|logs|ps|backup" >&2; exit 1 ;;
esac

#!/bin/sh
set -eu

mkdir -p /app/data

python - <<'PY'
import json
import os
import secrets
from pathlib import Path

path = Path("/app/data/config.json")

try:
    config = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
except (OSError, ValueError):
    config = {}

def env(name, fallback=""):
    value = os.environ.get(name)
    return value if value not in (None, "") else fallback

try:
    nntp_port = int(env("ATLAS_NNTP_PORT", str(config.get("port", 563))))
except ValueError:
    nntp_port = 563

config.update({
    "host": env("ATLAS_NNTP_HOST", config.get("host", "")),
    "username": env("ATLAS_NNTP_USER", config.get("username", "")),
    "password": env("ATLAS_NNTP_PASS", config.get("password", "")),
    "port": nntp_port,
    "index_mode": env("ATLAS_INDEX_MODE", config.get("index_mode", "dynamic")),
    "api_host": "0.0.0.0",
    "api_port": 9090,
})

config.setdefault("group", "")
config.setdefault("groups", [])
config.setdefault("api_key", secrets.token_urlsafe(32))

temporary = path.with_suffix(".json.tmp")
temporary.write_text(json.dumps(config, indent=4) + "\n", encoding="utf-8")
temporary.chmod(0o600)
temporary.replace(path)
PY

# Force Atlas to load the persistent file instead of its incomplete
# environment-only configuration path.
unset ATLAS_NNTP_HOST ATLAS_NNTP_PORT ATLAS_NNTP_USER ATLAS_NNTP_PASS

exec python main.py


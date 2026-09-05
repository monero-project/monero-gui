#!/usr/bin/env python3
"""Validate live Foundry connectivity and compare required object API names."""
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = json.loads((ROOT / "ontology" / "xuniaxmr.ontology.json").read_text())

def required(name):
    value = os.getenv(name)
    if not value:
        raise SystemExit(f"Missing required environment variable: {name}")
    return value

stack = required("FOUNDRY_STACK_URL").rstrip("/")
client_id = required("FOUNDRY_CLIENT_ID")
client_secret = required("FOUNDRY_CLIENT_SECRET")
ontology = required("FOUNDRY_ONTOLOGY")
token_url = os.getenv("FOUNDRY_TOKEN_URL", f"{stack}/multipass/api/oauth2/token")

body = urllib.parse.urlencode({
    "grant_type": "client_credentials",
    "client_id": client_id,
    "client_secret": client_secret,
    "scope": "api:ontologies-read"
}).encode()
request = urllib.request.Request(token_url, data=body, headers={"Content-Type":"application/x-www-form-urlencoded"})
try:
    with urllib.request.urlopen(request, timeout=30) as response:
        token = json.load(response)["access_token"]
except (urllib.error.URLError, KeyError) as exc:
    raise SystemExit(f"Foundry OAuth failed: {exc}") from exc

url = f"{stack}/api/v2/ontologies/{urllib.parse.quote(ontology, safe='')}/objectTypes?pageSize=1000"
request = urllib.request.Request(url, headers={"Authorization":f"Bearer {token}","Accept":"application/json"})
try:
    with urllib.request.urlopen(request, timeout=30) as response:
        payload = json.load(response)
except urllib.error.URLError as exc:
    raise SystemExit(f"Foundry Ontology API failed: {exc}") from exc

live = {item["apiName"] for item in payload.get("data", [])}
expected = {item["apiName"] for item in SPEC["objectTypes"]}
missing = sorted(expected - live)
if missing:
    print("::error::Foundry is reachable but object types are missing: " + ", ".join(missing))
    print("Create/publish them in Ontology Manager, then rerun this check.")
    raise SystemExit(1)
print(f"Foundry integration healthy: {len(expected)} required object types are active.")

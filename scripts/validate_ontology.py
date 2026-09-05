#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "ontology" / "xuniaxmr.ontology.json"
API_NAME = re.compile(r"^[a-z][A-Za-z0-9]*$")

def fail(message):
    print(f"::error::{message}")
    raise SystemExit(1)

data = json.loads(SPEC.read_text())
for key in ("schemaVersion", "ontology", "policies", "objectTypes", "linkTypes", "actionTypes"):
    if key not in data:
        fail(f"missing top-level field: {key}")

objects = data["objectTypes"]
names = [item.get("apiName") for item in objects]
if len(names) != len(set(names)):
    fail("object type apiName values must be unique")

prohibited = {x.lower() for x in data["policies"]["prohibitedProperties"]}
for obj in objects:
    name = obj.get("apiName", "")
    if not API_NAME.fullmatch(name):
        fail(f"invalid object apiName: {name}")
    props = obj.get("properties", {})
    primary = obj.get("primaryKey")
    if primary not in props:
        fail(f"{name}: primaryKey must exist in properties")
    leaked = prohibited.intersection(x.lower() for x in props)
    if leaked:
        fail(f"{name}: prohibited sensitive properties: {sorted(leaked)}")

known = set(names)
for link in data["linkTypes"]:
    if link.get("from") not in known or link.get("to") not in known:
        fail(f"link {link.get('apiName')} references unknown object type")
for action in data["actionTypes"]:
    if action.get("target") not in known:
        fail(f"action {action.get('apiName')} references unknown target")

required_approvals = set(data["policies"]["humanApprovalRequired"])
actions = {a["apiName"]: a for a in data["actionTypes"]}
for name in required_approvals:
    if name in actions and actions[name].get("approval") != "HUMAN_REQUIRED":
        fail(f"{name} must require human approval")

print(f"Ontology valid: {len(objects)} objects, {len(data['linkTypes'])} links, {len(data['actionTypes'])} actions")

"""Derive the 289-row production master (S section 1, R1 derivation) from the Appendix B snapshots in S.

Writes production-master-r1.csv next to this file with an empty allowed_effect_kinds column for the church to fill.
Run: python3 -I derive_master.py   (fails with AssertionError if the derivation no longer matches S)
"""
import csv, json, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
S = os.path.join(HERE, "..", "GMIM_Treasurer_Domain_Model_Posting_Rules_State_Machines_and_Report_Pack_Data_Mapping_v2.0.md")
OUT = os.path.join(HERE, "production-master-r1.csv")

blocks = [json.loads(b) for b in re.findall(r"```json\n(.*?)\n```", open(S, encoding="utf-8").read(), re.S)]
definition = next(b for b in blocks if b.get("definition_version"))
catalogs = {b["kind"]: b["rows"] for b in blocks if b.get("kind") in ("PENDAPATAN", "BELANJA")}
assert definition["definition_version"] == "GMIM_TREASURER_PRODUCTION_MASTER_R1_2026-10-08"
assert definition["postability"] == {"leaf_default": True, "parent_default": False, "parent_overrides": []}

overrides = {(c["kind"], c["source_row_id"]): c for c in definition["corrections"]}
out = []
for kind, rows in catalogs.items():
    assert len(rows) == definition["source_catalog_row_counts"][kind], kind
    ids = {r["id"] for r in rows}
    parents = {r["parent_id"] for r in rows if r["parent_id"]}
    assert parents <= ids, f"{kind}: unknown parent"
    assert sum(r["parent_id"] is None for r in rows) == 6, f"{kind}: six roots"
    by_id = {r["id"]: r for r in rows}
    for r in rows:
        if r["parent_id"]:
            assert r["level"] == by_id[r["parent_id"]]["level"] + 1, r["id"]
        code = r["code"]
        c = overrides.get((kind, r["id"]))
        if c:
            assert (code, r["name"], r["parent_id"]) == (c["source_code"], c["name"], c["parent_id"]), r["id"]
            code = c["production_code"]
        out.append({
            "kind": kind, "row_id": r["id"], "source_row": r["source_row"],
            "production_code": code, "source_code": r["code"], "name": r["name"],
            "parent_id": r["parent_id"] or "", "family_id": r["family_id"], "level": r["level"],
            "display_order": r["display_order"], "node_role": r["node_role"],
            "postable": "true" if r["id"] not in parents else "false",
            "allowed_effect_kinds": "", "church_note": "",
        })

assert len(out) == 289
assert sum(r["postable"] == "true" for r in out) == 237 and sum(r["postable"] == "false" for r in out) == 52
for kind in catalogs:
    codes = [r["production_code"] for r in out if r["kind"] == kind]
    assert len(codes) == len(set(codes)), f"{kind}: duplicate production code"
assert sum(r["production_code"] != r["source_code"] for r in out) == 1, "only B113 changes code"

# utf-8-sig so Excel opens names correctly
with open(OUT, "w", newline="", encoding="utf-8-sig") as f:
    w = csv.DictWriter(f, fieldnames=list(out[0]))
    w.writeheader()
    w.writerows(out)
print(f"ok   {len(out)} rows, 237 postable, 52 not postable, B113 -> 2.3.02.02; wrote {os.path.basename(OUT)}")

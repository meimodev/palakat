"""Check arithmetic.vectors.json against the S section 7.2 definitions. Run: python3 -I check_arithmetic.py"""
import json, os, sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
vectors = json.load(open(os.path.join(HERE, "arithmetic.vectors.json")))["vectors"]
by_id = {v["id"]: v for v in vectors}


def signed(leg):
    return leg.get("dr", 0) - leg.get("cr", 0)


def batch_ok(legs, exempt):
    globally = sum(l.get("dr", 0) for l in legs) == sum(l.get("cr", 0) for l in legs)
    per_fund = defaultdict(int)
    for l in legs:
        per_fund[l["fund"]] += signed(l)
    return globally, exempt or all(v == 0 for v in per_fund.values())


def measures(opening, events):
    m = defaultdict(int)
    liquid_fund = defaultdict(int)
    for l in opening:
        if l["t"].startswith("LIQUID"):
            m["C_open"] += signed(l)
        if l["t"].startswith("ADVANCE"):
            m["A_open"] += signed(l)
        if l["t"].startswith("TRANSIT"):
            m["L_open"] -= signed(l)
    for l in opening + [x for e in events for x in e["legs"]]:
        t = l["t"]
        if t.startswith("LIQUID"):
            m["C"] += signed(l)
            liquid_fund[l["fund"]] += signed(l)
        elif t.startswith("ADVANCE"):
            m["A"] += signed(l)
        elif t.startswith("TRANSIT"):
            m["L"] -= signed(l)
        elif t == "INCOME":
            m["I"] -= signed(l)
        elif t == "EXPENSE":
            m["E"] += signed(l)
    for e in events:
        m["Tin"] += e.get("sched", {}).get("tin", 0)
        m["Tout"] += e.get("sched", {}).get("tout", 0)
    m["N"] = m["C"] + m["A"] - m["L"]
    m["GP"] = m["I"] + m["Tin"]
    m["GB"] = m["E"] + m["Tout"]
    return m, liquid_fund


fails = 0
for v in vectors:
    base = by_id[v["extends"]] if "extends" in v else v
    opening = base["opening"]
    events = base["events"] + v.get("extra_events", [])
    m, lf = measures(opening, events)
    problems = []
    all_pf = True
    for e in events:
        g, p = batch_ok(e["legs"], e.get("kind") == "FUND_TRANSFER")
        if not g:
            problems.append(f"event not globally balanced: {e['name']}")
        if not p:
            all_pf = False
            if v["expect"].get("unbalanced_event") != e["name"]:
                problems.append(f"unexpected per-Fund imbalance: {e['name']}")
    if all_pf != v["expect"].get("per_fund_balanced", True):
        problems.append(f"per_fund_balanced is {all_pf}")
    for k, want in v["expect"].items():
        if k in ("per_fund_balanced", "unbalanced_event"):
            continue
        got = dict(lf) if k == "liquid_by_fund" else m[k]
        if got != want:
            problems.append(f"{k}: expected {want}, got {got}")
    # bridges for approved whole-workspace vectors
    if v["id"] in ("A01", "A02"):
        e1 = m["C_open"] + m["I"] - m["E"] - (m["A"] - m["A_open"]) + (m["L"] - m["L_open"])
        e2 = m["C_open"] + m["GP"] - m["GB"] - (m["A"] - m["A_open"]) + ((m["L"] - m["L_open"]) - (m["Tin"] - m["Tout"]))
        if not (e1 == e2 == m["C"]):
            problems.append(f"bridges: {e1}, {e2}, C={m['C']}")
        if m["C_open"] + m["I"] - m["E"] != m["N"]:
            problems.append("net-position bridge fails")
    for per, want in v.get("expect_by_period", {}).items():
        sub = [e for e in events if e.get("period") == per]
        pm, _ = measures([], sub)
        for k, w in want.items():
            if pm[k] != w:
                problems.append(f"{per} {k}: expected {w}, got {pm[k]}")
    print(("FAIL " if problems else "ok   ") + v["id"] + "  " + v["title"])
    for p in problems:
        print("     -", p)
    fails += bool(problems)
sys.exit(1 if fails else 0)

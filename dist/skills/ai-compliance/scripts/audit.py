#!/usr/bin/env python3
"""
AI Compliance Audit Scanner
Scans source files for AI UX compliance patterns per SKILL.md rules AI-001~AI-011.

Usage:
  python3 audit.py                          # Scan current directory
  python3 audit.py --path src/              # Scan specific path
  python3 audit.py --jurisdiction tw,eu     # Filter rules by jurisdiction
  python3 audit.py --format markdown        # Output as markdown
  python3 audit.py --rule AI-003            # Check specific rule only
"""

import argparse
import os
import re
import sys
import json
from pathlib import Path
from dataclasses import dataclass, field

SCAN_EXTENSIONS = {".tsx", ".ts", ".jsx", ".js", ".svelte", ".vue", ".html", ".py"}

@dataclass
class Finding:
    rule: str
    severity: str
    file: str
    line: int
    status: str  # PASS / FAIL / WARN
    message: str

@dataclass
class RuleCheck:
    id: str
    name: str
    severity: str
    jurisdictions: list
    pass_patterns: list = field(default_factory=list)
    fail_patterns: list = field(default_factory=list)
    warn_patterns: list = field(default_factory=list)

RULES = [
    RuleCheck(
        id="AI-001", name="Chatbot AI Disclosure", severity="CRITICAL",
        jurisdictions=["tw", "eu", "us"],
        pass_patterns=[
            r'ai[_-]?(badge|disclosure|notice)',
            r'aria-label=["\'].*[Aa][Ii]\s*(assistant|system)',
            r'role=["\']status["\']',
        ],
        fail_patterns=[
            r'(chat[_-]?header|chat[_-]?title)(?!.*ai)',
        ],
        warn_patterns=[
            r'(support|helper|assistant)(?!.*ai)',
        ],
    ),
    RuleCheck(
        id="AI-002", name="Periodic AI Reminder", severity="HIGH",
        jurisdictions=["us"],
        pass_patterns=[
            r'(reminder|remind).*interval',
            r'setInterval.*[Aa][Ii].*remind',
            r'AI_REMINDER_INTERVAL',
        ],
    ),
    RuleCheck(
        id="AI-003", name="AI Content Label", severity="CRITICAL",
        jurisdictions=["tw", "eu"],
        pass_patterns=[
            r'data-ai-generated=["\']true["\']',
            r'data-ai-model=',
            r'ai[_-]?(label|tag|badge|generated)',
            r'aria-label=["\'].*[Aa][Ii]\s*generated',
        ],
        fail_patterns=[
            r'generatedContent|aiOutput|ai_response(?!.*data-ai)',
        ],
    ),
    RuleCheck(
        id="AI-004", name="Consent Equal Prominence", severity="CRITICAL",
        jurisdictions=["eu", "us"],
        fail_patterns=[
            r'text-xs.*text-gray.*(?:later|skip|close|dismiss)',
            r'btn-lg.*\n.*text-xs',
        ],
        warn_patterns=[
            r'consent.*accept(?!.*reject)',
        ],
    ),
    RuleCheck(
        id="AI-005", name="Human Override", severity="CRITICAL",
        jurisdictions=["tw", "eu"],
        pass_patterns=[
            r'override.*[Aa][Ii]',
            r'emergency[_-]?stop',
            r'(覆寫|override).*(決策|decision)',
        ],
        fail_patterns=[
            r'auto[_-]?(approv|accept|confirm)(?!.*override)',
        ],
    ),
    RuleCheck(
        id="AI-006", name="Recommendation Transparency", severity="HIGH",
        jurisdictions=["eu"],
        pass_patterns=[
            r'[Ww]hy.*seeing\s*this',
            r'(non[_-]?personalized|chronological)',
            r'recommendation.*explain',
        ],
    ),
    RuleCheck(
        id="AI-007", name="Explainability Interface", severity="HIGH",
        jurisdictions=["tw", "eu"],
        pass_patterns=[
            r'(explanation|explainab|explain.*factor)',
            r'(human[_-]?review|appeal|申訴)',
            r'<details>.*factor',
        ],
    ),
    RuleCheck(
        id="AI-008", name="Granular AI Consent", severity="HIGH",
        jurisdictions=["tw", "eu", "us"],
        pass_patterns=[
            r'role=["\']switch["\']',
            r'(per[_-]?feature|granular).*consent',
            r'disable[_-]?all',
        ],
        fail_patterns=[
            r'checked=\{?\s*true\s*\}?.*consent',
            r'defaultChecked.*ai',
        ],
    ),
    RuleCheck(
        id="AI-009", name="Confidence Score Disclosure", severity="HIGH",
        jurisdictions=["tw", "eu"],
        pass_patterns=[
            r'confidence.*indicator',
            r'role=["\']status["\'].*confidence',
            r'sr-only.*review',
        ],
        warn_patterns=[
            r'confidence.*color(?!.*text)(?!.*icon)',
        ],
    ),
    RuleCheck(
        id="AI-010", name="Audit Trail", severity="HIGH",
        jurisdictions=["tw", "eu"],
        pass_patterns=[
            r'(audit|decision)[_-]?log',
            r'append[_-]?only',
            r'sha256.*hash',
            r'ai_audit',
        ],
    ),
    RuleCheck(
        id="AI-011", name="C2PA Content Provenance", severity="MEDIUM",
        jurisdictions=["eu", "tw"],
        pass_patterns=[
            r'c2pa',
            r'content[_-]?credentials',
            r'claim_generator',
        ],
    ),
]


def scan_file(filepath: str, rules: list[RuleCheck]) -> list[Finding]:
    findings = []
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
            lines = content.split("\n")
    except Exception:
        return findings

    for rule in rules:
        for pattern in rule.pass_patterns:
            for i, line in enumerate(lines, 1):
                if re.search(pattern, line, re.IGNORECASE):
                    findings.append(Finding(
                        rule=rule.id, severity=rule.severity,
                        file=filepath, line=i, status="PASS",
                        message=f"{rule.name}: pattern found"
                    ))

        for pattern in rule.fail_patterns:
            for i, line in enumerate(lines, 1):
                if re.search(pattern, line, re.IGNORECASE):
                    findings.append(Finding(
                        rule=rule.id, severity=rule.severity,
                        file=filepath, line=i, status="FAIL",
                        message=f"{rule.name}: potential violation"
                    ))

        for pattern in rule.warn_patterns:
            for i, line in enumerate(lines, 1):
                if re.search(pattern, line, re.IGNORECASE):
                    findings.append(Finding(
                        rule=rule.id, severity=rule.severity,
                        file=filepath, line=i, status="WARN",
                        message=f"{rule.name}: review recommended"
                    ))

    return findings


def scan_directory(path: str, rules: list[RuleCheck]) -> list[Finding]:
    findings = []
    for root, _, files in os.walk(path):
        if "node_modules" in root or ".git" in root or "__pycache__" in root:
            continue
        for fname in files:
            ext = Path(fname).suffix
            if ext in SCAN_EXTENSIONS:
                filepath = os.path.join(root, fname)
                findings.extend(scan_file(filepath, rules))
    return findings


def filter_rules(jurisdictions: list[str] | None, rule_id: str | None) -> list[RuleCheck]:
    rules = RULES
    if rule_id:
        rules = [r for r in rules if r.id == rule_id.upper()]
    if jurisdictions:
        jset = set(j.strip().lower() for j in jurisdictions)
        rules = [r for r in rules if any(j in jset for j in r.jurisdictions)]
    return rules


def format_text(findings: list[Finding], rules: list[RuleCheck]) -> str:
    out = ["AI Compliance Audit Report", "=" * 40, ""]

    rule_ids_checked = {r.id for r in rules}
    rule_ids_found = set()
    fail_count = warn_count = pass_count = 0

    for f in findings:
        rule_ids_found.add(f.rule)
        if f.status == "FAIL":
            fail_count += 1
        elif f.status == "WARN":
            warn_count += 1
        else:
            pass_count += 1

    not_found = rule_ids_checked - rule_ids_found

    if fail_count > 0:
        out.append(f"FAIL: {fail_count} | WARN: {warn_count} | PASS: {pass_count}")
    else:
        out.append(f"PASS: {pass_count} | WARN: {warn_count} | No failures detected")
    out.append("")

    for status in ["FAIL", "WARN", "PASS"]:
        group = [f for f in findings if f.status == status]
        if not group:
            continue
        out.append(f"--- {status} ---")
        for f in group:
            out.append(f"  [{f.rule}] {f.file}:{f.line} — {f.message}")
        out.append("")

    if not_found:
        out.append("--- NOT DETECTED (no patterns found) ---")
        for rid in sorted(not_found):
            rule = next(r for r in rules if r.id == rid)
            out.append(f"  [{rid}] {rule.name} ({rule.severity})")
        out.append("")

    return "\n".join(out)


def format_markdown(findings: list[Finding], rules: list[RuleCheck]) -> str:
    out = ["# AI Compliance Audit Report", ""]

    rule_ids_checked = {r.id for r in rules}
    rule_ids_found = set()
    stats = {"FAIL": 0, "WARN": 0, "PASS": 0}

    for f in findings:
        rule_ids_found.add(f.rule)
        stats[f.status] = stats.get(f.status, 0) + 1

    not_found = rule_ids_checked - rule_ids_found

    out.append(f"**FAIL**: {stats['FAIL']} | **WARN**: {stats['WARN']} | **PASS**: {stats['PASS']}")
    out.append("")

    out.append("| Status | Rule | File | Line | Message |")
    out.append("|--------|------|------|------|---------|")
    for f in sorted(findings, key=lambda x: (x.status != "FAIL", x.status != "WARN", x.rule)):
        icon = {"FAIL": "❌", "WARN": "⚠️", "PASS": "✅"}[f.status]
        out.append(f"| {icon} {f.status} | {f.rule} | `{f.file}` | {f.line} | {f.message} |")
    out.append("")

    if not_found:
        out.append("## Not Detected")
        out.append("No matching patterns found for these rules (may need manual review):")
        out.append("")
        for rid in sorted(not_found):
            rule = next(r for r in rules if r.id == rid)
            out.append(f"- **{rid}**: {rule.name} ({rule.severity})")

    return "\n".join(out)


def format_json(findings: list[Finding], rules: list[RuleCheck]) -> str:
    return json.dumps(
        {"findings": [vars(f) for f in findings], "rules_checked": [r.id for r in rules]},
        indent=2, ensure_ascii=False
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="AI Compliance Audit Scanner")
    parser.add_argument("--path", "-p", default=".", help="Directory to scan (default: current)")
    parser.add_argument("--jurisdiction", "-j", default=None, help="Filter by jurisdiction: tw,eu,us (comma-separated)")
    parser.add_argument("--rule", "-r", default=None, help="Check specific rule (e.g. AI-003)")
    parser.add_argument("--format", "-f", choices=["text", "markdown", "json"], default="text", help="Output format")

    args = parser.parse_args()

    jurisdictions = args.jurisdiction.split(",") if args.jurisdiction else None
    rules = filter_rules(jurisdictions, args.rule)

    if not rules:
        print("No matching rules found for the given filters.", file=sys.stderr)
        sys.exit(1)

    findings = scan_directory(args.path, rules)

    formatter = {"text": format_text, "markdown": format_markdown, "json": format_json}
    print(formatter[args.format](findings, rules))

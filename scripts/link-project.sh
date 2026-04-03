#!/bin/bash
set -euo pipefail

HUB="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="${1:?用法: $0 /path/to/project}"
PROJECT="$(cd "$PROJECT" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

linked=0
skipped=0

link_file() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    skipped=$((skipped + 1))
    return
  fi
  [ -e "$dst" ] || [ -L "$dst" ] && rm -rf "$dst"
  ln -sf "$src" "$dst"
  echo -e "  ${GREEN}linked${NC} $(basename "$dst")"
  linked=$((linked + 1))
}

link_dir() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    skipped=$((skipped + 1))
    return
  fi
  [ -e "$dst" ] || [ -L "$dst" ] && rm -rf "$dst"
  ln -sfn "$src" "$dst"
  echo -e "  ${GREEN}linked${NC} $(basename "$dst")/"
  linked=$((linked + 1))
}

echo "Source:  $HUB"
echo "Project: $PROJECT"
echo ""

# ── Commands ──
echo -e "${YELLOW}Commands${NC}"
mkdir -p "$PROJECT/.cursor/commands"
for f in "$HUB/.cursor/commands/"*.md; do
  [ -f "$f" ] || continue
  link_file "$f" "$PROJECT/.cursor/commands/$(basename "$f")"
done

# ── Skills (directory-level symlinks) ──
echo -e "${YELLOW}Skills${NC}"
mkdir -p "$PROJECT/.cursor/skills"
for d in "$HUB/.cursor/skills/"/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  link_dir "$d" "$PROJECT/.cursor/skills/$name"
done

# ── Rules (file-level, exclude speckitsync) ──
SHARED_RULES=(speckit-rules.mdc clean-code.mdc codequality.mdc git-conventions.mdc figma-to-code.mdc)
echo -e "${YELLOW}Rules${NC}"
mkdir -p "$PROJECT/.cursor/rules"
for rule in "${SHARED_RULES[@]}"; do
  src="$HUB/.cursor/rules/$rule"
  [ -f "$src" ] || continue
  link_file "$src" "$PROJECT/.cursor/rules/$rule"
done

# ── .agent/workflows (if dir exists) ──
if [ -d "$PROJECT/.agent/workflows" ]; then
  echo -e "${YELLOW}.agent/workflows${NC}"
  for f in "$HUB/.cursor/commands/"*.md; do
    [ -f "$f" ] || continue
    link_file "$f" "$PROJECT/.agent/workflows/$(basename "$f")"
  done
  [ -f "$PROJECT/.agent/workflows/speckitsync_rule.mdc" ] && rm -f "$PROJECT/.agent/workflows/speckitsync_rule.mdc"
fi

# ── .agent/rules (if dir exists) ──
if [ -d "$PROJECT/.agent/rules" ]; then
  echo -e "${YELLOW}.agent/rules${NC}"
  for rule in "${SHARED_RULES[@]}"; do
    src="$HUB/.cursor/rules/$rule"
    [ -f "$src" ] || continue
    link_file "$src" "$PROJECT/.agent/rules/$rule"
  done
  [ -f "$PROJECT/.agent/rules/speckitsync_rule.mdc" ] && rm -f "$PROJECT/.agent/rules/speckitsync_rule.mdc"
fi

echo ""
echo "Done — linked: $linked, already up-to-date: $skipped"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[info]${NC}  $*"; }
ok() { echo -e "${GREEN}[ok]${NC}    $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}  $*"; }
err() { echo -e "${RED}[err]${NC}   $*"; }

backup_if_exists() {
  local target="$1"
  if [ -f "$target" ]; then
    local backup="${target}.bak.$(date +%s)"
    warn "Backing up existing $target → $backup"
    cp "$target" "$backup"
  fi
}

install_skills() {
  local src="$SCRIPT_DIR/skills"
  local dest="$HOME/.claude/skills"

  info "Installing skills..."

  mkdir -p "$dest/caveman"
  cp "$src/caveman/SKILL.md" "$dest/caveman/SKILL.md"
  ok "caveman/SKILL.md → $dest/caveman/SKILL.md"

  mkdir -p "$dest/guidelines"
  cp "$src/guidelines/SKILL.md" "$dest/guidelines/SKILL.md"
  ok "guidelines/SKILL.md → $dest/guidelines/SKILL.md"
}

install_claude_code() {
  local src="$SCRIPT_DIR/claude-code"
  local dest="$HOME/.claude"

  info "Installing Claude Code config..."

  # settings.json
  mkdir -p "$dest"
  backup_if_exists "$dest/settings.json"
  cp "$src/settings.json" "$dest/settings.json"
  ok "settings.json → $dest/settings.json"

  # agents
  mkdir -p "$dest/agents"
  cp "$src/agents/implementer.md" "$dest/agents/implementer.md"
  ok "implementer.md → $dest/agents/implementer.md"
  cp "$src/agents/reviewer.md" "$dest/agents/reviewer.md"
  ok "reviewer.md → $dest/agents/reviewer.md"

  ok "Claude Code installed. Run: claude --agent implementer"
}

install_opencode() {
  local src="$SCRIPT_DIR/opencode"
  local dest="$HOME/.config/opencode"

  info "Installing OpenCode config..."

  # opencode.json
  mkdir -p "$dest"
  backup_if_exists "$dest/opencode.json"
  cp "$src/opencode.json" "$dest/opencode.json"
  ok "opencode.json → $dest/opencode.json"

  # agents
  mkdir -p "$dest/agents"
  cp "$src/agents/implementer.md" "$dest/agents/implementer.md"
  ok "implementer.md → $dest/agents/implementer.md"
  cp "$src/agents/reviewer.md" "$dest/agents/reviewer.md"
  ok "reviewer.md → $dest/agents/reviewer.md"

  echo ""
  ok "OpenCode installed. Run: opencode (then Tab to switch to implementer)"
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
usage() {
  echo "Usage: $0 [claude-code|opencode|all]"
  echo ""
  echo "  claude-code  Install Claude Code configs to ~/.claude/"
  echo "  opencode     Install OpenCode configs to ~/.config/opencode/"
  echo "  all          Install both (default)"
}

case "${1:-all}" in
claude-code)
  install_skills
  install_claude_code
  ;;
opencode)
  install_skills
  install_opencode
  ;;
all)
  install_skills
  echo ""
  install_claude_code
  echo ""
  echo "───────────────────────────────────────"
  echo ""
  install_opencode
  ;;
-h | --help | help)
  usage
  ;;
*)
  err "Unknown target: $1"
  usage
  exit 1
  ;;
esac

echo ""
ok "Done."

#!/usr/bin/env bash
# Claude SEO — Vantage (AI-citation checker) extension installer.
#
# Registers the hosted Vantage MCP server (https://vantagemcp.dev/mcp,
# Streamable HTTP) in ~/.claude.json and copies the seo-vantage skill into
# ~/.claude/skills/. Vantage checks whether a domain is cited in ChatGPT or
# Google AI Overview answers. Free tier: 30 quota units/month, no card.
set -euo pipefail

main() {
    SKILL_DIR="${HOME}/.claude/skills"
    # MCP servers live in ~/.claude.json (the file `claude mcp add` writes).
    # NOT ~/.claude/settings.json - `mcpServers` is not a key Claude Code reads
    # there, so entries written to settings.json silently never load.
    MCP_CONFIG_JSON="${HOME}/.claude.json"

    echo "════════════════════════════════════════"
    echo "║    Claude SEO — Vantage extension    ║"
    echo "════════════════════════════════════════"

    command -v python3 >/dev/null 2>&1 || { echo "✗ Python 3 required."; exit 1; }
    if [ ! -d "${SKILL_DIR}/seo" ]; then
        echo "✗ claude-seo base plugin not installed."
        echo "  Install it first: curl -fsSL https://raw.githubusercontent.com/AgriciDaniel/claude-seo/main/install.sh | bash"
        exit 1
    fi

    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

    echo "Get a free API key (no card) at https://vantagemcp.dev"
    read -rsp "Vantage API key: " VANTAGE_KEY
    echo
    [ -z "${VANTAGE_KEY}" ] && { echo "✗ No key provided."; exit 1; }

    mkdir -p "${SKILL_DIR}/seo-vantage"
    cp "${SOURCE_DIR}/skills/seo-vantage/SKILL.md" "${SKILL_DIR}/seo-vantage/SKILL.md"
    echo "✓ Installed skill: ${SKILL_DIR}/seo-vantage/SKILL.md"

    # Merge the MCP entry into ~/.claude.json atomically. The key is passed as
    # argv, never interpolated into the Python source.
    python3 - "${MCP_CONFIG_JSON}" "${VANTAGE_KEY}" <<'PY'
import json
import os
import sys
import tempfile

path, key = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    try:
        with open(path) as fh:
            data = json.load(fh)
    except json.JSONDecodeError:
        # ~/.claude.json holds all of Claude Code's user config; never reset it.
        sys.exit(f"✗ {path} is not valid JSON; not modifying it.")
data.setdefault("mcpServers", {})["vantage"] = {
    "type": "http",
    "url": "https://vantagemcp.dev/mcp",
    "headers": {"Authorization": f"Bearer {key}"},
}
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path) or ".",
                          prefix=".settings.", suffix=".json")
try:
    with os.fdopen(fd, "w") as fh:
        json.dump(data, fh, indent=2)
    os.chmod(tmp, 0o600)
    os.replace(tmp, path)
except Exception:
    if os.path.exists(tmp):
        os.unlink(tmp)
    raise
print(f"✓ Wrote mcpServers.vantage to {path}")
PY

    echo
    echo "Done. Open a new Claude Code session and run:"
    echo "  /seo vantage trend example.com"
    echo
    echo "Full docs: extensions/vantage/docs/VANTAGE-SETUP.md"
}
main "$@"

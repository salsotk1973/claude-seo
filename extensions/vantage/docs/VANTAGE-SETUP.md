# Vantage extension setup

Registers the hosted [Vantage](https://vantagemcp.dev) MCP server
(`https://vantagemcp.dev/mcp`, Streamable HTTP) in your Claude Code session
so the `seo-vantage` skill can check live AI-answer citations.

## Install

```bash
./extensions/vantage/install.sh        # Linux / macOS
.\extensions\vantage\install.ps1       # Windows PowerShell
```

The installer:

1. Verifies Python 3 is on `$PATH` and the claude-seo base plugin is installed.
2. Prompts for your Vantage API key (input is hidden). Free key, no card:
   https://vantagemcp.dev
3. Copies `skills/seo-vantage/SKILL.md` into `~/.claude/skills/seo-vantage/`.
4. Atomically writes `mcpServers.vantage` into `~/.claude.json` as an `http`
   server with an `Authorization: Bearer <key>` header, `chmod 0o600`. If
   `~/.claude.json` exists but is not valid JSON, the installer stops rather
   than overwrite it.

Nothing runs locally: no Node, no npm package, no pre-warm.

## Verify

```bash
claude mcp get vantage
```

should show `Type: http` and `URL: https://vantagemcp.dev/mcp`. Then open a
new Claude Code session and ask:

```
/seo vantage trend example.com
```

## Rotate key

Re-run the installer; it replaces only `mcpServers.vantage`, leaving the rest
of `~/.claude.json` intact.

## Uninstall

```bash
./extensions/vantage/uninstall.sh    # removes the skill + the MCP entry
```

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Vantage tools missing in session | Session started before install | Open a new Claude Code session |
| 401 from any `/seo vantage *` command | Key wrong or revoked | Get a key at https://vantagemcp.dev and re-run the installer |
| Monthly limit message | Free tier (30 units/month: `leaders` 10, `check`/`structure` 1 per keyword, `trend` 1) used up | Wait for the reset or upgrade at https://vantagemcp.dev |

# Claude SEO — Vantage extension installer (Windows / PowerShell).
# Mirrors extensions/vantage/install.sh.
$ErrorActionPreference = "Stop"
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw "Python 3 required" }
$SkillDir = Join-Path $HOME ".claude/skills"
# MCP servers live in ~/.claude.json (the file `claude mcp add` writes).
# NOT ~/.claude/settings.json - `mcpServers` is not a key Claude Code reads
# there, so entries written to settings.json silently never load.
$McpConfigJson = Join-Path $HOME ".claude.json"
if (-not (Test-Path (Join-Path $SkillDir "seo"))) { throw "claude-seo base plugin not installed." }
Write-Host "Get a free API key (no card) at https://vantagemcp.dev"
$Key = Read-Host "Vantage API key" -AsSecureString
$Plain = [System.Net.NetworkCredential]::new("", $Key).Password
if (-not $Plain) { throw "No key provided." }
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillTarget = Join-Path $SkillDir "seo-vantage"
New-Item -ItemType Directory -Path $SkillTarget -Force | Out-Null
Copy-Item (Join-Path $SourceDir "skills/seo-vantage/SKILL.md") `
          (Join-Path $SkillTarget "SKILL.md") -Force
Write-Host "✓ Installed skill: $SkillTarget"
$py = @"
import json, os, sys, tempfile
path, key = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    try:
        data = json.load(open(path))
    except json.JSONDecodeError:
        sys.exit(f'{path} is not valid JSON; not modifying it.')
data.setdefault('mcpServers', {})['vantage'] = {
    'type': 'http',
    'url': 'https://vantagemcp.dev/mcp',
    'headers': {'Authorization': f'Bearer {key}'},
}
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path) or '.', prefix='.settings.', suffix='.json')
with os.fdopen(fd, 'w') as fh:
    json.dump(data, fh, indent=2)
os.replace(tmp, path)
print(f'Wrote mcpServers.vantage to {path}')
"@
$py | python - $McpConfigJson $Plain
if ($LASTEXITCODE -ne 0) { throw "Could not register the Vantage MCP server." }
Write-Host ""
Write-Host "Done. Open a new Claude Code session and run /seo vantage trend example.com"

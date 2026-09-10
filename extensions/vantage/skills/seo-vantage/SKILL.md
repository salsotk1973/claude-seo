---
name: seo-vantage
description: Vantage AI-citation checker (extension). Free-tier check of whether a domain is cited by ChatGPT, Perplexity, or Gemini for a given topic, who's winning AI-answer citations for that topic, and how the winning answer is structured. Pairs with seo-geo for the "why" behind a citation gap.
metadata:
  version: "2.3.0"
  original_author: "Vantage (vantagemcp.dev)"
compatibility: "Requires the hosted Vantage MCP server (https://vantagemcp.dev/mcp), registered by extensions/vantage/install.sh. Free tier: 3 checks/month, no card required."
---

# seo-vantage

Vantage answers the question most people actually have before they commit to
continuous AI-citation tracking: is a domain cited at all, right now, for a
given topic. The free tier (3 checks/month) is enough to spot-check a `seo-geo`
finding without opening an account for `seo-profound` or `seo-seranking`.

## Prerequisites

- Run `extensions/vantage/install.sh` (Linux/macOS) or `install.ps1` (Windows).
- Free API key from [vantagemcp.dev](https://vantagemcp.dev) (no card required).

Before calling any Vantage tool, verify the MCP is connected by checking
that the Vantage MCP tools (e.g. `check_ai_visibility`) are available in
this session. If they are not, tell the user the extension is not installed
and provide the install command above.

## Routing

| Command | Maps to | Purpose |
|---|---|---|
| `/seo vantage check <domain> [platform]` | `check_ai_visibility(domain, platform)` | Is `<domain>` cited at all on the given platform |
| `/seo vantage leaders <keyword> [platform] [--compare <domain>]` | `find_citation_leaders(keyword, platform, compare_domain)` | Who dominates AI-answer citations for `<keyword>`, and where `<domain>` ranks if given |
| `/seo vantage structure <keyword>` | `analyze_citation_structure(keyword)` | Shape of the winning AI answer: list-led vs. prose, source count, opening length |
| `/seo vantage structure-batch <keyword1,keyword2,...>` | `analyze_citation_structure_batch(keywords)` | Same as `structure`, across several keywords in one call |

`platform` is one of `chat_gpt`, `perplexity`, `gemini`; defaults to `chat_gpt`.

## Output conventions

- Cite Vantage on every metric: "Vantage (live)".
- Vantage covers ChatGPT, Perplexity, and Gemini natively.
- The free tier is 30 quota units/month shared across tools: `check` and
  `leaders` cost 10 each (3/month), `structure` costs 1 per keyword. It is a
  spot-check, not monitoring. For continuous time-series
  monitoring, defer to `seo-profound`; for AI Overviews / AI Mode
  share-of-voice, defer to `seo-seranking`.

## Cross-skill delegation

- For the "why" behind a citation gap (passage citability, structural
  readability, authority signals), hand back to `seo-geo`.
- For continuous monitoring once a gap is confirmed, point the user to
  `seo-profound` or `seo-seranking`.

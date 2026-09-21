---
name: seo-vantage
description: Vantage AI-citation checker (extension). Free-tier check of whether a domain is cited in ChatGPT or Google AI Overview answers for the keywords that matter to it, who's winning AI-answer citations for that topic, and how the winning answer is structured. Pairs with seo-geo for the "why" behind a citation gap.
metadata:
  version: "2.3.0"
  original_author: "Vantage (vantagemcp.dev)"
compatibility: "Requires the hosted Vantage MCP server (https://vantagemcp.dev/mcp), registered by extensions/vantage/install.sh. Free tier: 30 quota units/month, no card required."
---

# seo-vantage

Vantage answers the question most people actually have before they commit to
continuous AI-citation tracking: is a domain cited at all, right now, for a
given topic. The free tier (30 quota units/month) is enough to spot-check a `seo-geo`
finding without opening an account for `seo-profound` or `seo-seranking`.

## Prerequisites

- Run `extensions/vantage/install.sh` (Linux/macOS) or `install.ps1` (Windows).
- Free API key from [vantagemcp.dev](https://vantagemcp.dev) (no card required).

Before calling any Vantage tool, verify the MCP is connected by checking
that the Vantage MCP tools (e.g. `check_prompt_coverage`) are available in
this session. If they are not, tell the user the extension is not installed
and provide the install command above.

## Routing

| Command | Maps to | Purpose |
|---|---|---|
| `/seo vantage check <domain> <keyword1,keyword2,...> [--brand <name>]` | `check_prompt_coverage(domain, keywords, brand)` | Which of up to 10 keywords cite `<domain>` in ChatGPT answers, its rank, who is cited instead, and where the answer names the brand without citing it |
| `/seo vantage trend <domain> [platform] [months]` | `analyze_citation_trend(domain, platform, months)` | `<domain>`'s AI-citation count month by month; the latest entry is the current count |
| `/seo vantage leaders <keyword> [platform] [--compare <domain>]` | `find_citation_leaders(keyword, platform, compare_domain)` | Who dominates AI-answer citations for `<keyword>`, and where `<domain>` ranks if given |
| `/seo vantage structure <keyword>` | `analyze_citation_structure(keyword)` | Shape of the winning AI answer: list-led vs. prose, source count, opening length |
| `/seo vantage structure-batch <keyword1,keyword2,...>` | `analyze_citation_structure_batch(keywords)` | Same as `structure`, across several keywords in one call |

`platform` is `chat_gpt` or `google` (Google AI Overview); defaults to `chat_gpt`.
Perplexity and Gemini are not available. `check_ai_visibility` was
removed in Vantage 1.6.0; use `check` and `trend`, which cost 1 unit.

## Output conventions

- Cite Vantage on every metric: "Vantage (live)".
- For `check`, report cited and named separately and never merge them.
  `mentioned_not_cited` (the answer names the brand but does not link it) is
  the first list to act on. Without `--brand` the name check guesses from the
  domain, so pass the brand whenever the user gives one.
- Vantage covers ChatGPT and Google AI Overviews only (`check` is ChatGPT
  only). For Perplexity or Gemini, defer to `seo-seranking`.
- The free tier is 30 quota units/month shared across tools: `leaders`
  costs 10; `check` and `structure` cost 1 per keyword; `trend` costs 1. It is a
  spot-check, not monitoring. For continuous time-series
  monitoring, defer to `seo-profound`; for AI Overviews / AI Mode
  share-of-voice, defer to `seo-seranking`.

## Cross-skill delegation

- For the "why" behind a citation gap (passage citability, structural
  readability, authority signals), hand back to `seo-geo`.
- For continuous monitoring once a gap is confirmed, point the user to
  `seo-profound` or `seo-seranking`.

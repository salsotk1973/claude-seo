---
name: seo-vantage
description: Vantage AI-citation checker (extension). Free-tier check of whether a domain is cited in ChatGPT, Gemini, Perplexity or Google AI Overview answers for the keywords that matter to it, which questions already cite it, who's winning AI-answer citations for a topic, and a fix brief for a page that is missing. Pairs with seo-geo for the "why" behind a citation gap.
metadata:
  version: "2.4.0"
  original_author: "Vantage (vantagemcp.dev)"
compatibility: "Requires the hosted Vantage MCP server (https://vantagemcp.dev/mcp), registered by extensions/vantage/install.sh. Free tier: 30 quota units/month, no card required."
---

# seo-vantage

Vantage answers the question most people actually have before they commit to
continuous AI-citation tracking: is a domain cited at all, right now, for a
given topic, and what would change that. The free tier (30 quota units/month)
is enough to spot-check a `seo-geo` finding without opening an account for
`seo-profound` or `seo-seranking`.

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
| `/seo vantage check <domain> <keyword1,keyword2,...> [--brand <name>] [--engine <e>] [--samples <n>]` | `check_prompt_coverage(domain, keywords, brand, engine, samples)` | Which of up to 10 keywords cite `<domain>`, its rank, who is cited instead, where the answer names the brand without citing it, and what changed since the last check |
| `/seo vantage questions <domain>` | `find_cited_questions(domain)` | The questions AI answers already cite `<domain>` for, most asked first |
| `/seo vantage gap <keyword> <url> [--engine <e>]` | `analyze_citation_gap(keyword, your_url, engine)` | Compares `<url>` with the cited answer and returns a fix brief: ordered changes to make, ending with the off-site step |
| `/seo vantage trend <domain> [platform] [months]` | `analyze_citation_trend(domain, platform, months)` | `<domain>`'s AI-citation count month by month; the latest entry is the current count |
| `/seo vantage leaders <keyword> [platform] [--compare <domain>]` | `find_citation_leaders(keyword, platform, compare_domain)` | Who dominates AI-answer citations for `<keyword>`, and where `<domain>` ranks if given |
| `/seo vantage structure <keyword> [--engine <e>] [--samples <n>]` | `analyze_citation_structure(keyword, engine, samples)` | Shape of the winning AI answer: list-led vs. prose, source count, opening length |
| `/seo vantage structure-batch <keyword1,keyword2,...> [--engine <e>]` | `analyze_citation_structure_batch(keywords, engine)` | Same as `structure`, across several keywords in one call |
| `/seo vantage history <domain>` | `get_check_history(domain)` | Earlier `check` results for `<domain>`, newest first |

`--engine` is `chat_gpt` (default), `gemini` or `perplexity`, on the tools that
read a live answer (`check`, `gap`, `structure`, `structure-batch`).
`--samples` (1 to 5) asks for several answers, since answers change run to run:
report "cited in 2 of 3 answers" rather than a single yes or no. `platform`
(`trend`, `leaders`) is `chat_gpt` or `google` (Google AI Overview); defaults
to `chat_gpt`. `check_ai_visibility` was removed in Vantage 1.6.0.

## Output conventions

- Cite Vantage on every metric: "Vantage (live)", with the engine and model the
  response names.
- For `check`, report cited and named separately and never merge them.
  `mentioned_not_cited` (the answer names the brand but does not link it) is
  the first list to act on. Without `--brand` the name check guesses from the
  domain, so pass the brand whenever the user gives one.
- Before telling a user they are or are not cited, prefer `--samples 3`.
- For `gap`, present the fix brief in order and let the user (or the agent,
  with the user's go-ahead) apply it to the page; Vantage never keeps the cited
  answer's text.
- The free tier is 30 quota units/month shared across tools: `leaders` and
  `questions` cost 10; `check` and `structure` cost 1 per keyword per sample;
  `gap` and `trend` cost 1; `history` costs 0. It is a spot-check, not
  monitoring. For continuous time-series monitoring, defer to `seo-profound`;
  for AI Overviews / AI Mode share-of-voice, defer to `seo-seranking`.

## Cross-skill delegation

- For the "why" behind a citation gap (passage citability, structural
  readability, authority signals), hand back to `seo-geo`.
- For continuous monitoring once a gap is confirmed, point the user to
  `seo-profound` or `seo-seranking`.

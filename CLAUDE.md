# imkaidu.net — Claude Code Settings

@AGENTS.md

Only `AGENTS.md` is auto-imported — behavioural rules belong in context every
session. Everything else is read on demand, which keeps startup context small.
This mirrors the convention used across the sibling research repos.

## What this repo is, in one line

The static site at **imkaidu.net** (GitHub Pages, single `master` branch,
pandoc-generated) — and the apex domain under which the research repos'
Cloudflare-hosted dashboards are published.

## Repo family

| Repo | Role |
|---|---|
| `Spatial_SFA_Latent_Class_2025` | Spatial SFA + latent class. Holds the shared harness runbook: `06_Supporting_Files/GUIDE_HARNESS_RUNBOOK.md` |
| `SFA_GMM_ModSel_JTest_Jack_Boot_2026` | GMM model selection / J-test / jackknife-bootstrap. Origin of the worktree isolation system |
| `SFA_GMM_Majorization_2025` | GMM majorization |
| `Imkaidu.github.io` (this repo) | The public site + dashboard apex domain |

The three research repos share a common harness (hook wiring, commit-message
spec, plan taxonomy, task worktrees). **This repo shares the documentation
conventions only** — see `AGENTS.md` for which guards are deliberately absent
and why.

## Common tasks

| Task | Command |
|---|---|
| Rebuild one page | `script/generate.sh <file>.md` |
| Rebuild every page | `script/generate-all.sh` (writes `results.out`; **exits 1 and names the page if any step failed**) |
| Refresh blog index, `feed.xml`, `sitemap.xml` | `script/build-index.py` (run by `generate-all.sh`; `--check` writes nothing) |
| Publish | `git push origin master` — the push *is* the deploy |

There is no test suite, no CI, and no staging environment. Preview locally by
opening the generated `.html` before pushing. Do not push after a failed
`generate-all.sh`: a failed PDF leaves the previous committed PDF in place.

## Writing a blog post

Add `blog/posts/<name>.md` with this front matter (see `AGENTS.md` for the rules):

```yaml
---
title: "…"
author: Kai Du
date: 2026-10-03        # ISO 8601 only; the index, feed and sitemap read it
description: "One sentence for link previews and the feed."
---
```

Optional: `updated:` (shown on the page), `note:` (a caveat box under the
byline, e.g. "written in 2020, not re-checked"), `pagetitle:` (a short title for
the browser tab and link previews), `unlisted: true` (stays on the site but out
of the index, feed and sitemap, and `noindex`; used for the two Matthew Low
posts kept for the record), `slides: true` (also build a beamer deck; off by
default), `nopdf: true` (skip PDF and slides for a page that cannot yet be
typeset). Then run `script/generate-all.sh`; the blog
index is generated between the `POSTS:START/END` markers in `blog/blog.md` —
never edit that block by hand.

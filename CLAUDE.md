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
| Rebuild every page | `script/generate-all.sh` (writes `results.out`) |
| Publish | `git push origin master` — the push *is* the deploy |

There is no test suite, no CI, and no staging environment. Preview locally by
opening the generated `.html` before pushing.

# imkaidu.net — Agent Instructions

Behavioural constraints for AI coding agents working on this repository.

This repo is part of a four-repo family that shares one harness. The other
three are MATLAB research projects; **this one is not**, and the differences
below are deliberate, not gaps to be filled in. The shared runbook lives at
`Spatial_SFA_Latent_Class_2025/06_Supporting_Files/GUIDE_HARNESS_RUNBOOK.md`.

## What this repository is

The static personal/academic site served at **imkaidu.net** (see `CNAME`),
published by GitHub Pages from the single `master` branch. It holds the
public CV/landing pages, teaching material, and paper links — plus, in an
untracked `private/` folder, working notes that cross project boundaries.

It is also the **apex domain for the research dashboards**. Each research
repo publishes its generated `dashboard.html` to a Cloudflare Worker on a
subdomain of this domain (e.g. `spatial-sfa-latent-class.imkaidu.net`). This
repo does not build or host those dashboards — it owns the domain they sit
under. If a dashboard subdomain needs DNS or an Access policy, that is
Cloudflare configuration for this domain, not a change to any research repo.

## Branch model — single branch, by design

`master` only. No `dev`, no `release`, no task worktrees.

The research repos separate `dev` from a stable branch because a broken
intermediate state there can silently corrupt *results* — a half-finished
estimation, a stale exhibit, a number that reaches the manuscript. Nothing
here has that failure mode: a broken page is visibly broken, immediately, and
is fixed by another commit. A second branch would add ceremony without
removing a hazard.

- Commit directly to `master`.
- A push to `master` is a publish. There is no staging step, so **read the
  rendered output before pushing** if the change affects a live page.

## No hooks, no CI, no worktrees — stated positively

This repo deliberately has **none** of the guard machinery the research repos
run. That is a considered position, recorded here so it is not "fixed" by a
future agent who notices the inconsistency:

| Guard in the research repos | Why it is absent here |
|---|---|
| `core.hooksPath` + `pre-commit` guards | Nothing to guard: no frozen kernel, no DGP byte-identity, no write-once results directory |
| `check_results_immutable.sh` | No `02_HPC_Results/`; nothing here is irreplaceable evidence |
| Manuscript/claim checkers | No manuscript, no numeric claims to reconcile |
| Task worktrees + ownership manifests | Concurrency hazard has not arisen; pages are small and independently editable, unlike a shared `main.tex` |
| CI (`validate.yml`) | Nothing to validate that a browser does not show immediately |

**If that changes, revisit — do not copy reflexively.** The rule from the
runbook applies: a guard earns its place by naming the specific irreversible
harm it prevents.

## Build convention — pandoc, committed output

Pages are authored in Markdown and rendered with pandoc into HTML, PDF, and
beamer slides, all three of which are **committed alongside the source**:

```bash
script/generate.sh index.md     # one page -> .html + .pdf + -slides.pdf
script/generate-all.sh          # every *.md, max depth 4; log to results.out
```

- Templates: `templates/default.tex` (PDF), `default.html` (web),
  `header/latex.tex` (PDF preamble). Styling: `css/custom.css`, KaTeX for
  maths.
- **Never hand-edit a generated `.html`, `.pdf`, or `-slides.pdf`.** Edit the
  `.md` and re-run `script/generate.sh`. This is the same
  never-edit-generated-output rule the research repos apply to `.tex` tables
  and figures.
- `.nojekyll` is present: GitHub Pages serves these files as-is rather than
  running Jekyll over them. Do not remove it.

## `private/` is untracked — keep it that way

`private/` is in `.gitignore` and holds cross-project working notes
(implementation plans, drafts). It is **local only and must stay that way**:
it is a scratch surface, and its contents have not been reviewed for
publication on a live public domain.

- Do not add `private/` to a whitelist, un-ignore it, or move its contents
  into a tracked directory.
- Do not link to `private/` paths from any tracked page — the link would
  404 publicly while resolving locally, which is worse than no link.

## Code Conventions

- Markdown source is the authority; generated artefacts follow.
- Keep page front-matter consistent with neighbouring pages (title, author)
  so the pandoc templates render uniformly.
- Prefer relative links (`/docs/...`) over absolute `https://imkaidu.net/...`
  so pages work when previewed locally.

## Do-NOT Directives

- Do NOT hand-edit generated `.html` / `.pdf` / `-slides.pdf`.
- Do NOT track `private/`.
- Do NOT remove `.nojekyll` or `CNAME` — the first changes how Pages serves
  the site, the second is what points imkaidu.net here.
- Do NOT introduce a build step that requires CI. The value of this repo's
  setup is that `git push` is the whole deployment.

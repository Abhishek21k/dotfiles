---
description: Save session log to second-brain vault (claude-code-memory-setup)
argument-hint: "[short kebab description]"
---

Vault root: `/Users/zenitsu/Documents/claude`

Steps:
1. Determine project: current cwd basename, or ask if ambiguous.
2. Determine date via `date +%Y-%m-%d`.
3. Build filename: `YYYY-MM-DD-<kebab-description>.md` using `$ARGUMENTS` (kebab-case it). If empty, derive 3-5 word kebab summary of session.
4. Write to:
   - Global: `/Users/zenitsu/Documents/claude/logs/<filename>`
   - Project (if project folder exists in vault): also `/Users/zenitsu/Documents/claude/<project>/logs/<filename>`
5. Frontmatter required:
```yaml
---
title: <Title Case description>
tags: [session-log, <project>]
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: active
type: log
---
```
6. Body sections:
   - **Done** — what changed (cite files via wikilinks `[[file-stem]]` for vault notes; use code paths for repo files).
   - **Decisions** — key choices + reason.
   - **Pending** — what's left, blockers, next step.
   - **Links** — wikilinks to created/modified vault notes.
7. If inside a git repo AND user has previously authorized pushing in this project, run `git add -A && git commit -m "session: <description>" && git push`. Otherwise stop after writing log and report path.

Never delete prior logs. Never overwrite existing log file — append `-2`, `-3` suffix on collision.

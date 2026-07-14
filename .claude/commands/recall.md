---
description: Recall context from second-brain vault (claude-code-memory-setup)
argument-hint: "[project-name optional]"
---

Vault root: `/Users/zenitsu/Documents/claude`

Steps:
1. Read up to 3 most recent files in `/Users/zenitsu/Documents/claude/logs/` (global session logs).
2. If `$ARGUMENTS` provided OR current cwd basename matches a folder in the vault, also read up to 3 most recent files in `/Users/zenitsu/Documents/claude/<project>/logs/`.
3. If `/Users/zenitsu/Documents/claude/<project>/architecture/decisions.md` exists, read it.
4. If `/Users/zenitsu/Documents/claude/graphify/<project>/` exists, list its contents.
5. Summarize: current state, last decisions, pending items, open threads. Cite notes via wikilinks `[[note-name]]`.

If no logs exist, say so explicitly. Do not fabricate prior sessions.

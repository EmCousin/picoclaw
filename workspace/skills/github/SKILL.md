---
name: github
description: "Interact with GitHub using the gh CLI. Handle PRs, issues, and repository operations autonomously. Always ask which repository if unclear from context."
metadata: {"nanobot":{"emoji":"🐙","requires":{"bins":["gh"]},"install":[]}}
---

# GitHub Skill

Interact with GitHub repositories using the `gh` CLI. This skill enables autonomous GitHub operations.

## Prerequisites

- GitHub CLI (`gh`) is pre-installed in the container
- GitHub token is stored in MEMORY.md
- Use `exec` tool for all gh commands

## Authentication

Before any GitHub operation, authenticate:
```
exec({"command": "echo TOKEN | gh auth login --with-token"})
```

The token is in MEMORY.md under "Github Account" → "Auth token".

## Autonomous Workflows

### 1. Review Open PRs

**When user says:** "Check my PRs" / "Review open pull requests" / "What PRs need attention?"

**Workflow:**
1. Ask "Which repository?" if unclear from context or cwd
2. Authenticate with GitHub
3. List open PRs: `exec({"command": "gh pr list --repo OWNER/REPO --json number,title,state,author"})`
4. For each PR, check CI status: `exec({"command": "gh pr checks NUMBER --repo OWNER/REPO"})`
5. Report summary:
   - Total open PRs
   - Which have passing CI
   - Which have failing CI
   - Which are ready to merge (passing CI + approved)

### 2. Merge Ready PRs

**When user says:** "Merge my ready PRs" / "Merge PRs that are ready"

**Workflow:**
1. Ask "Which repository?" if unclear
2. Authenticate
3. List PRs with passing CI: `exec({"command": "gh pr list --repo OWNER/REPO --json number,title,mergeStateStatus"})`
4. Filter to find "clean" PRs (passing CI, no conflicts)
5. **CONFIRM BEFORE MERGING:**
   ```
   "I found N PRs ready to merge:
   - #XXX: Title
   - #YYY: Title
   
   Merge all of them? (yes/no)"
   ```
6. If confirmed, merge each: `exec({"command": "gh pr merge NUMBER --repo OWNER/REPO --squash"})`
7. Report results

### 3. Handle Security Updates

**When user says:** "Handle security updates" / "Check security PRs"

**Workflow:**
1. Ask "Which repository?" if unclear
2. Authenticate
3. Search for security-related PRs (labels: security, dependabot, depfu)
4. Check CI status on each
5. Report:
   - Security PRs found
   - Which are ready to merge (passing CI)
   - Which need attention (failing CI)
6. **CONFIRM BEFORE MERGING** any security PRs

### 4. View Specific PR

**When user says:** "Show me PR #123" / "What's the status of PR 456?"

**Workflow:**
1. Ask "Which repository?" if unclear
2. Authenticate
3. View PR details: `exec({"command": "gh pr view NUMBER --repo OWNER/REPO"})`
4. Check CI status: `exec({"command": "gh pr checks NUMBER --repo OWNER/REPO"})`
5. Show PR description, changes, and CI status

## Confirmation Requirements

**ALWAYS ask for confirmation before:**
- Merging any PR (destructive operation)
- Closing PRs
- Making changes to repository settings

**Format:**
```
"I'm about to merge PR #XXX: TITLE
This will merge the changes into the main branch.

Confirm? (yes/no)"
```

## Error Handling

If authentication fails:
1. Check if token in MEMORY.md is valid
2. Try re-authenticating
3. If still failing, report: "GitHub authentication failed. Please check the token in MEMORY.md"

If merge fails:
1. Check CI status
2. Check for merge conflicts
3. Report specific error to user

## Context Detection

**How to determine repository:**
1. Check if user mentioned repo in message (e.g., "in EmCousin/pkp")
2. Check current working directory (if in a git repo, use that)
3. If still unclear, ask: "Which repository? (format: owner/repo)"

## Examples

**User:** "Check my PRs"
**Agent:** "Which repository?"
**User:** "EmCousin/pkp"
**Agent:** *[Lists PRs with status]*

**User:** "Merge the ready ones"
**Agent:** "I found 2 PRs ready to merge:
- #603: Security update for trix
- #601: Bump ajv

Merge both? (yes/no)"

**User:** "yes"
**Agent:** *[Merges PRs and reports success]*

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

**ALWAYS use the auth token for authentication.**

Before any GitHub operation:
1. Read MEMORY.md to get the auth token: `read_file({"path": "/home/picoclaw/.picoclaw/workspace/memory/MEMORY.md"})`
2. Extract the auth token (starts with `ghp_`)
3. Authenticate: `exec({"command": "echo GH_TOKEN | gh auth login --with-token"})`

The **auth token** is stored in MEMORY.md under "Github Account" → "Auth token".

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

### 5. Respond to GitHub Mentions

**When:** Someone mentions @danuclaw in an issue, PR, or comment

**Workflow:**
1. Authenticate with GitHub
2. Find the mention using: `exec({"command": "gh api notifications --repo OWNER/REPO --json subject,reason"})`
3. Read the context (issue/PR where mentioned)
4. React with 👀 eyes emoji immediately: `exec({"command": "gh api repos/OWNER/REPO/issues/comments/COMMENT_ID/reactions -X POST -f content=eyes"})`
5. Provide helpful response based on the mention context
6. Post reply as comment

**Response Guidelines:**
- If asked a question → Answer helpfully
- If asked to review → See "Review PR" workflow below
- If mentioned in passing → Acknowledge with 👀 and brief response

### 6. Review Pull Request

**When:** Assigned as reviewer on a PR OR asked to review a specific PR

**Workflow:**
1. Authenticate with GitHub
2. View PR details: `exec({"command": "gh pr view NUMBER --repo OWNER/REPO"})`
3. Check CI status: `exec({"command": "gh pr checks NUMBER --repo OWNER/REPO"})`
4. Get PR diff: `exec({"command": "gh pr diff NUMBER --repo OWNER/REPO"})`
5. Review the code changes thoroughly
6. Post review comments using:
   ```
   exec({"command": "gh api repos/OWNER/REPO/pulls/NUMBER/reviews -X POST -f body='REVIEW_SUMMARY' -f event='COMMENT'"})
   ```

**For inline comments on specific lines:**
```
exec({"command": "gh api repos/OWNER/REPO/pulls/NUMBER/comments -X POST -f body='COMMENT_TEXT' -f commit_id='COMMIT_SHA' -f path='FILE_PATH' -f line=LINE_NUMBER"})
```

**Review Format:**
```
**Review Summary:**
- Overall assessment: [Approve/Request Changes/Comment]
- Code quality: [Good/Needs work]
- CI status: [Passing/Failing]

**Inline Comments:**
- File: path/to/file.rb, Line 42: "Consider using constant here"
- File: path/to/file.rb, Line 55: "This logic could be simplified"

**Action Items:**
- [ ] Fix failing test
- [ ] Address security concern
```

**Review Guidelines:**
- Check for: logic errors, security issues, code style, test coverage
- Be constructive and specific
- Suggest improvements, not just point out problems
- Approve if minor issues only, request changes for major issues

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

**Scenario: Mentioned on GitHub**
**GitHub:** "@danuclaw Can you review this PR?"
**Agent:** *[Reacts with 👀 eyes, reads PR, posts review comments]*

**Scenario: Assigned as reviewer**
**GitHub:** "@danuclaw requested as reviewer"
**Agent:** *[Reviews PR thoroughly, posts inline comments on diff, submits review]*

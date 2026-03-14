# PicoClaw Development Workflow

## Source of Truth

**The GitHub repository is the SOURCE OF TRUTH.** All changes must be made to the repo FIRST, then synced to Docker containers.

## Workflow Rules

### 1. Update Repo First

ALWAYS modify files in `/Users/emmanuelcousin/GitHub/picoclaw/` (the repo), NOT in `/Users/emmanuelcousin/GitHub/picoclaw/docker/data/` (the container volume).

### 2. Directory Mapping

| Repo Location | Container Location | Purpose |
|--------------|---------------------|---------|
| `workspace/` | `/home/picoclaw/.picoclaw/workspace/` | Agent config, skills, memory |
| `docker/Dockerfile.debian` | Built into image | Container setup with RTK, browser tools |
| `bin/start` | Not in container | Startup script |
| `docker/data/config.json` | `/home/picoclaw/.picoclaw/config.json` | Runtime config (API keys, models) |

### 3. Sync Commands

**Repo → Container (after updating repo files):**
```bash
# Sync workspace files
./bin/sync-workspace

# Or manually:
docker cp workspace/AGENTS.md picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/
docker cp workspace/IDENTITY.md picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/
docker cp -r workspace/skills/rtk picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/skills/

# Restart to apply changes
./bin/stop && ./bin/start
```

**Container → Repo (only if changes were made in container accidentally):**
```bash
# Copy FROM container TO repo
docker cp picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/AGENTS.md workspace/
docker cp picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/IDENTITY.md workspace/
docker cp -r picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/skills/rtk workspace/skills/

# Commit changes
git add workspace/
git commit -m "Sync workspace changes from container"
```

### 4. What Gets Committed

**Always commit to repo:**
- ✅ `workspace/AGENTS.md` - Agent instructions
- ✅ `workspace/IDENTITY.md` - Agent identity
- ✅ `workspace/skills/*` - Custom skills
- ✅ `docker/Dockerfile.debian` - Container setup
- ✅ `bin/start`, `bin/stop` - Scripts
- ✅ Code changes (`pkg/`, `cmd/`, etc.)

**DON'T commit (runtime data):**
- ❌ `docker/data/config.json` - Contains API keys
- ❌ `docker/data/workspace/cron/` - Runtime cron jobs
- ❌ `docker/data/workspace/memory/` - Runtime memory
- ❌ `docker/data/workspace/state/` - Runtime state

### 5. Commit Message Style

Use imperative mood, concise:
- "Add RTK skill for token optimization"
- "Update AGENTS.md with browser automation instructions"
- "Fix browser tool CDP port handling"

## Quick Reference

```bash
# Edit in repo first!
vim workspace/AGENTS.md

# Sync to container
./bin/sync-workspace && ./bin/restart

# Or full cycle:
./bin/stop && ./bin/build && ./bin/start

# Check status
docker logs picoclaw-gateway | tail -20
```

## Emergency Container → Repo Sync

If changes were made directly in the container and need to be preserved:

```bash
# Copy from container to repo
docker cp picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/AGENTS.md workspace/
docker cp picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/IDENTITY.md workspace/
docker cp -r picoclaw-gateway:/home/picoclaw/.picoclaw/workspace/skills/ workspace/

# Commit
git add workspace/
git commit -m "Sync workspace changes from container"
git push
```

**Note:** This should be avoided. Always prefer repo → container workflow.

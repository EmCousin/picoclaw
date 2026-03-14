---
name: rtk
description: "MANDATORY: Always use RTK (Rust Token Killer) to reduce token consumption by 60-90%. Prefix ALL commands with 'rtk' - e.g., 'rtk git status', 'rtk read file.rs', 'rtk test cargo test'. Never use raw commands."
metadata: {"nanobot":{"emoji":"🔪","requires":{"bins":["rtk"]},"install":[]}}
---

# RTK - Rust Token Killer

## Description

RTK is a CLI proxy that reduces LLM token consumption by 60-90% on common dev commands. It filters and compresses command outputs before they reach the LLM context.

## When to Use

**ALWAYS use RTK for ALL terminal commands.** This is not optional - it is mandatory for all code-related tasks.

## Installation

RTK is pre-installed in the container. Verify with:
```bash
rtk --version
```

## Usage

### ALWAYS Prefix Commands with RTK

**❌ WRONG:**
```bash
git status
cat file.rs
cargo test
```

**✅ CORRECT:**
```bash
rtk git status
rtk read file.rs
rtk test cargo test
```

## Commands Reference

### File Operations
- `rtk ls .` - Token-optimized directory listing
- `rtk read file.rs` - Smart file reading (reduces tokens by ~70%)
- `rtk read file.rs -l aggressive` - Signatures only (minimal tokens)
- `rtk smart file.rs` - 2-line code summary
- `rtk find "*.rs" .` - Compact find results
- `rtk grep "pattern" .` - Grouped search results

### Git Commands
- `rtk git status` - Compact status (80% fewer tokens)
- `rtk git log -n 10` - One-line commits
- `rtk git diff` - Condensed diff (75% fewer tokens)
- `rtk git add .` - Returns just "ok"
- `rtk git commit -m "msg"` - Returns "ok abc1234"
- `rtk git push` - Returns "ok main"

### Test Runners
- `rtk test cargo test` - Show failures only (-90% tokens)
- `rtk err npm run build` - Errors/warnings only
- `rtk pytest` - Python tests (-90%)
- `rtk go test` - Go tests (-90%)

### Build & Lint
- `rtk cargo build` - Cargo build (-80%)
- `rtk cargo clippy` - Cargo clippy (-80%)
- `rtk ruff check` - Python linting (-80%)
- `rtk lint` - ESLint grouped by rule

### GitHub CLI
- `rtk gh pr list` - Compact PR listing
- `rtk gh issue list` - Compact issue listing

### Docker
- `rtk docker ps` - Compact container list
- `rtk docker logs <container>` - Deduplicated logs

## Token Savings

| Command | Standard | RTK | Savings |
|---------|----------|-----|---------|
| ls/tree | 2,000 | 400 | -80% |
| cat/read | 40,000 | 12,000 | -70% |
| git status | 3,000 | 600 | -80% |
| git diff | 10,000 | 2,500 | -75% |
| cargo test | 25,000 | 2,500 | -90% |

## Analytics

Track your savings:
```bash
rtk gain                    # Summary stats
rtk gain --graph            # ASCII graph
rtk gain --history          # Recent history
```

## Rule

**Every terminal command MUST use RTK.** No exceptions. This saves tokens, reduces costs, and improves response quality.

## Examples

**Reading a file:**
```bash
# Instead of:
cat src/main.rs

# Use:
rtk read src/main.rs
```

**Checking git status:**
```bash
# Instead of:
git status

# Use:
rtk git status
```

**Running tests:**
```bash
# Instead of:
cargo test

# Use:
rtk test cargo test
```

## Configuration

RTK works automatically. For advanced config:
- Config file: `~/.config/rtk/config.toml`
- Database: `~/.local/share/rtk/history.db`

## Important Notes

1. RTK is pre-installed in this container
2. Always check output with `rtk gain` to see savings
3. Use `-l aggressive` for maximum compression
4. The `rtk read` command is superior to `cat` for LLM contexts

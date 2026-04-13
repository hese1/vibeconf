# Agent Swarm Config

Strict two-agent setup for [Claude Code](https://code.claude.com) and [OpenCode](https://opencode.ai). An **implementer** that edits files, a **reviewer** subagent that lints and tests. Neither can install packages, access git, or run arbitrary commands. Both speak caveman.

## Install

```bash
git clone <this-repo>
cd agent-swarm-config
./install.sh          # both
./install.sh claude-code
./install.sh opencode
```

Backs up existing configs before overwriting.

## Usage

```bash
# Claude Code
claude --agent implementer

# OpenCode
opencode --agent implementer  # Tab to switch to implementer
```

## Architecture

```
┌───────────────────────────────────────────┐
│  caveman skill (shared)                   │
│  ~/.claude/skills/caveman/SKILL.md        │
│                                           │
│  Discovered by both Claude Code and       │
│  OpenCode. Preloaded into both agents.    │
│  Cuts ~65% output tokens. No filler.     │
│  "stop caveman" to turn off mid-session.  │
└───────────────────────────────────────────┘

┌───────────────────────────────────────────┐
│  Global permissions                       │
│                                           │
│  Allowed: read, edit, write, grep, glob   │
│  Allowed bash: ruff, pytest (reviewer)    │
│  Denied:  everything else                 │
└───────────────────────────────────────────┘

┌──────────────────────┐  delegates  ┌──────────────────────┐
│  implementer         │ ─────────►  │  reviewer            │
│  (primary)           │             │  (subagent)          │
│                      │             │                      │
│  CAN: read, edit,    │             │  CAN: read, grep,    │
│  write, grep, glob,  │             │  glob, ruff, pytest  │
│  invoke @reviewer    │             │                      │
│                      │             │  CANNOT: edit, write, │
│  CANNOT: bash, git,  │             │  other bash, git,    │
│  install anything    │             │  install, subagents  │
└──────────────────────┘             └──────────────────────┘
```

## File structure

```
.
├── install.sh
├── skills/
│   ├── caveman/
│   │   └── SKILL.md            → ~/.claude/skills/caveman/SKILL.md
│   └── guidelines/
│       └── SKILL.md            → ~/.claude/skills/guidelines/SKILL.md
├── claude-code/
│   ├── settings.json           → ~/.claude/settings.json
│   └── agents/
│       ├── implementer.md      → ~/.claude/agents/implementer.md
│       └── reviewer.md         → ~/.claude/agents/reviewer.md
└── opencode/
    ├── opencode.json           → ~/.config/opencode/opencode.json
    └── agents/
        ├── implementer.md      → ~/.config/opencode/agents/implementer.md
        └── reviewer.md         → ~/.config/opencode/agents/reviewer.md
```

## Caveman skill

Stripped-down output style. No articles, no filler, no pleasantries. Technical terms and code stay exact. Cuts ~65% output tokens.

Preloaded into Claude Code agents via `skills: [caveman]` frontmatter. OpenCode agents load it via prompt instruction (OpenCode doesn't have a skills preload field in agent config).

Both tools discover it from `~/.claude/skills/caveman/SKILL.md`.

Turn off mid-session: "stop caveman" or "normal mode".

## Adapting for other languages

Reviewer is configured for Python (ruff + pytest). To adapt:

| Language | Replace ruff with | Replace pytest with |
|----------|-------------------|---------------------|
| JS/TS    | eslint, prettier  | vitest, jest        |
| Go       | golangci-lint, gofmt | go test          |
| Rust     | cargo clippy, cargo fmt | cargo test     |

Update allowed commands in:

- `claude-code/settings.json` allow list + `reviewer.md` hook + prompt
- `opencode/agents/reviewer.md` permission.bash + prompt

## License

MIT

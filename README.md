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

## License

MIT

# Anchor File Pattern

Reliably locate a project root from any shell script.

## Layout

Place an anchor file at the root; symlink it from each script directory:

```
myproject/
├── PROJECT_ROOT.md                          ← anchor
├── scripts/
│   └── PROJECT_ROOT.md → ../PROJECT_ROOT.md
└── tools/ci/
    └── PROJECT_ROOT.md → ../../PROJECT_ROOT.md
```

## Setup

```bash
touch PROJECT_ROOT.md
ln -s ../PROJECT_ROOT.md     scripts/PROJECT_ROOT.md
ln -s ../../PROJECT_ROOT.md  tools/ci/PROJECT_ROOT.md
```

## Usage

```bash
#!/bin/bash
SWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PRJ="$(cd "$(dirname "$(readlink -f "$SWD/PROJECT_ROOT.md")")" &>/dev/null && pwd)"

source "$PRJ/config/settings.sh"
```

`readlink -f` resolves the symlink → anchor → project root. Adjust the filename and symlink depth to fit your layout.

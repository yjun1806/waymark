#!/bin/sh
# Install docat git hooks into a docat DATA repo (the repo that holds docat/).
# Run from anywhere inside that repo:
#     sh /path/to/docat-plugin/hooks/install.sh
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git rev-parse --show-toplevel)"

mkdir -p "$ROOT/.git/hooks"
cp "$SRC/docat-index.py" "$SRC/docat-check.py" "$ROOT/.git/hooks/"
cp "$SRC/pre-commit" "$ROOT/.git/hooks/pre-commit"
chmod +x "$ROOT/.git/hooks/pre-commit"

echo "✓ docat hooks installed → $ROOT/.git/hooks/pre-commit"
echo "  (on commit: regenerate index.md + run the gate)"

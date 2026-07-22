#!/bin/sh
# Install docat git hooks into a docat DATA repo (the repo that holds docat/).
# Safe: respects core.hooksPath and never clobbers an existing pre-commit.
# Run from anywhere inside that repo:  sh /path/to/docat-plugin/hooks/install.sh
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git rev-parse --show-toplevel)"

# 1) Respect a custom hooks path (husky, lefthook, …) — installing into .git/hooks would
#    silently never run. Tell the user how to wire it into their existing runner instead.
HP="$(git -C "$ROOT" config --get core.hooksPath 2>/dev/null || true)"
if [ -n "$HP" ]; then
  echo "⚠ This repo sets core.hooksPath = $HP (husky/lefthook?)."
  echo "  Docat will NOT install into .git/hooks (it would never run here)."
  echo "  Add this to your existing pre-commit runner instead:"
  echo "      python3 \"$SRC/docat-index.py\" . && python3 \"$SRC/docat-check.py\" ."
  exit 1
fi

HOOKS="$ROOT/.git/hooks"
mkdir -p "$HOOKS"
cp "$SRC/docat-index.py" "$SRC/docat-check.py" "$HOOKS/"

# 2) Don't clobber an unrelated existing pre-commit — back it up first.
if [ -e "$HOOKS/pre-commit" ] && ! grep -q "docat-check.py" "$HOOKS/pre-commit" 2>/dev/null; then
  BAK="$HOOKS/pre-commit.pre-docat.$(date +%Y%m%d%H%M%S)"
  cp "$HOOKS/pre-commit" "$BAK"
  echo "⚠ Existing pre-commit backed up → $BAK"
  echo "  Docat installed its own; chain the two manually if you need both."
fi
cp "$SRC/pre-commit" "$HOOKS/pre-commit"
chmod +x "$HOOKS/pre-commit"

echo "✓ docat hooks installed → $HOOKS/pre-commit"
echo "  (on commit: regenerate index.md · freeze done/ · run the gate)"

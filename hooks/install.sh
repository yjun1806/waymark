#!/bin/sh
# Install waymark git hooks into a waymark DATA repo (the repo that holds waymark/).
# Safe: respects core.hooksPath and never clobbers an existing pre-commit.
# Run from anywhere inside that repo:  sh /path/to/waymark-plugin/hooks/install.sh
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git rev-parse --show-toplevel)"

# 1) Respect a custom hooks path (husky, lefthook, …) — installing into .git/hooks would
#    silently never run. Tell the user how to wire it into their existing runner instead.
HP="$(git -C "$ROOT" config --get core.hooksPath 2>/dev/null || true)"
if [ -n "$HP" ]; then
  echo "⚠ This repo sets core.hooksPath = $HP (husky/lefthook?)."
  echo "  Waymark will NOT install into .git/hooks (it would never run here)."
  echo "  Add this to your existing pre-commit runner instead:"
  echo "      python3 \"$SRC/waymark-index.py\" . && python3 \"$SRC/waymark-check.py\" ."
  exit 1
fi

HOOKS="$ROOT/.git/hooks"
mkdir -p "$HOOKS"
cp "$SRC/waymark-index.py" "$SRC/waymark-check.py" "$HOOKS/"

# 2) Don't clobber an unrelated existing pre-commit — back it up first.
if [ -e "$HOOKS/pre-commit" ] && ! grep -q "waymark-check.py" "$HOOKS/pre-commit" 2>/dev/null; then
  BAK="$HOOKS/pre-commit.pre-waymark.$(date +%Y%m%d%H%M%S)"
  cp "$HOOKS/pre-commit" "$BAK"
  echo "⚠ Existing pre-commit backed up → $BAK"
  echo "  Waymark installed its own; chain the two manually if you need both."
fi
cp "$SRC/pre-commit" "$HOOKS/pre-commit"
chmod +x "$HOOKS/pre-commit"

echo "✓ waymark hooks installed → $HOOKS/pre-commit"
echo "  (on commit: regenerate index.md · freeze done/ · run the gate)"

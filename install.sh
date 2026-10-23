#!/usr/bin/env bash
# install.sh -- make Bend 2 highlight in Helix.
#
# Helix has no plugin system, so there is nothing to install *into*. What a
# language actually needs is: a tree-sitter parser Helix can load, and highlight
# queries in one of Helix's runtime dirs. Helix reads queries from ITS OWN
# runtime dirs and never from a grammar repo, which is the one thing that makes
# this more than a config line.
#
# This script does the mechanical parts. The one part it will not do for you is
# edit your languages.toml, because it cannot know what else is in there --
# it prints the snippet and tells you if it is already present.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELIX_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/helix"
RUNTIME="$HELIX_CONFIG/runtime"
GRAMMAR_REPO="https://github.com/davidawad/tree-sitter-bend2"
GRAMMAR_REV="8ad225d157f7409b59c995a11a86908123b9b20c"

if ! command -v hx >/dev/null 2>&1; then
  echo "install: the 'hx' binary is not on PATH." >&2
  exit 1
fi
if ! command -v tree-sitter >/dev/null 2>&1; then
  echo "install: the tree-sitter CLI is not on PATH." >&2
  echo "  install: cargo install tree-sitter-cli   (or: npm i -g tree-sitter-cli)" >&2
  exit 1
fi

mkdir -p "$RUNTIME/grammars/sources" "$RUNTIME/queries/bend"

if [ ! -d "$RUNTIME/grammars/sources/bend2/.git" ]; then
  git clone --quiet "$GRAMMAR_REPO" "$RUNTIME/grammars/sources/bend2"
fi
git -C "$RUNTIME/grammars/sources/bend2" fetch --quiet origin
git -C "$RUNTIME/grammars/sources/bend2" checkout --quiet "$GRAMMAR_REV"

tree-sitter build -o "$RUNTIME/grammars/bend2.so" "$RUNTIME/grammars/sources/bend2"
cp "$HERE/queries/bend/highlights.scm" "$RUNTIME/queries/bend/highlights.scm"

echo "install: built $RUNTIME/grammars/bend2.so from $GRAMMAR_REPO @ ${GRAMMAR_REV:0:12}"
echo "install: installed $RUNTIME/queries/bend/highlights.scm"

if grep -q 'name = "bend"' "$HELIX_CONFIG/languages.toml" 2>/dev/null; then
  echo "install: a 'bend' language entry is already present in $HELIX_CONFIG/languages.toml"
else
  echo
  echo "install: still to do -- add this to $HELIX_CONFIG/languages.toml:"
  echo "---------------------------------------------------------------"
  cat "$HERE/languages.toml"
  echo "---------------------------------------------------------------"
fi

echo
echo "install: verify with:  hx --health bend"
echo "install: expected --    Tree-sitter parser OK, Highlight queries OK"
echo "install: Textobject/Indent queries show as missing; the grammar has no"
echo "install: textobjects.scm or indents.scm yet (see tree-sitter-bend2)."

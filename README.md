# helix-bend

[Bend 2](https://github.com/bendlang/bend) support for the
[Helix](https://helix-editor.com/) editor.

**Helix has no plugin system** (the project's own FAQ: "While there is
currently no plugin system available, we do intend to eventually have one"),
so this is not a plugin you install into Helix. It is the thing Helix actually
consumes: a language entry, the highlight queries, and the grammar Helix
builds a parser from -- packaged so you don't have to assemble it.

Three files do all the work:

| file | goes where | why |
| --- | --- | --- |
| `languages.toml` | merged into `~/.config/helix/languages.toml` | declares the `bend` language and where its grammar comes from |
| `queries/bend/highlights.scm` | `~/.config/helix/runtime/queries/bend/` | Helix reads queries from its **own** runtime dir, never from a grammar repo |
| `install.sh` | run it | fetches the grammar, compiles the parser, installs the queries |

## Install

```sh
git clone https://github.com/davidawad/helix-bend
cd helix-bend
./install.sh
```

Then append the `[[language]]` / `[[grammar]]` pair that `install.sh` prints to
your `~/.config/helix/languages.toml` (it detects and skips this if you already
have it), and verify:

```sh
hx --health bend
```

Expected:

```
Tree-sitter parser:  ✓
Highlight queries:   ✓
Textobject queries:  ✘
Indent queries:      ✘
```

The two ✘ are honest and expected: the grammar does not implement
`textobjects.scm` or `indents.scm` yet. Helix falls back to its own
indentation logic.

## What it covers

Line comments, nested block comments, strings, char literals, all reserved
keywords, `@unsafe`, the kind-former keywords, `def NAME`/`law NAME`,
uppercase type/constructor identifiers, numeric literals, quantity markers,
and `?hole`/`?TODO` goals -- i.e. whatever
[tree-sitter-bend2](https://github.com/davidawad/tree-sitter-bend2) provides,
which is where the grammar and its limitations are documented. This repo owns
no grammar; it pins one.

## Why a separate repo

Because the grammar now has consumers that are not this one (Helix, plus
nvim-treesitter and the [bend.vim](https://github.com/davidawad/bend.vim)
plugin), and because a repo named `tree-sitter-bend2` should not have to
pretend to be Helix packaging. The grammar is the reusable artifact; this is
one distribution of it.

The upstream-at-everyone answer is a PR to
[helix-editor/helix](https://github.com/helix-editor/helix) adding the language,
grammar and queries to Helix's own `languages.toml` + `runtime/queries/`. That
is how every other Helix language ships, and it would make this repo
unnecessary for most people. Not done yet.

## Other editors

- Vim / Neovim: [bend.vim](https://github.com/davidawad/bend.vim)
- Emacs: [bend-mode.el](https://github.com/davidawad/bend-mode.el)
- Grammar (any other tree-sitter editor): [tree-sitter-bend2](https://github.com/davidawad/tree-sitter-bend2)

## License

MIT -- see [LICENSE](LICENSE).

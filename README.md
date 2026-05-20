# Emacs Configuration

A modular, extensible Emacs configuration aimed at general-purpose IDE work
(Go, Python, Terraform, YAML, JavaScript / TypeScript, Clojure, Markdown,
Elisp). Originally forked from
[`flyingmachine/emacs-for-clojure`](https://github.com/flyingmachine/emacs-for-clojure)
and re-shaped over time.

## Installing

1. Close Emacs.
2. Move any existing `~/.emacs.d` aside if you want a clean install.
3. Clone this repo with submodules (the GitHub Dark Dimmed theme is a
   submodule under `themes/`):

   ```sh
   git clone --recurse-submodules <this-repo-url> ~/.emacs.d
   ```

4. Start Emacs. The first run installs ~50 packages from MELPA / GNU ELPA and
   may take a couple of minutes.
5. Once it's up, run `M-x all-the-icons-install-fonts` to install the icon
   fonts used by `doom-modeline`. Do this once per machine.

### Optional prerequisites

Each language module degrades gracefully when its tooling is missing, but to
get the full experience install:

- **Go** — `gopls` (`go install golang.org/x/tools/gopls@latest`).
- **Python** — `pylsp` and `ruff` in your project's `.venv`. The Python module
  detects the nearest `.venv` (uv-style) or `pyproject.toml` and uses the
  project-local Python tools first.
- **Terraform** — `terraform` (the `fmt` subcommand is used on save).
- **Clojure** — [`clojure-lsp`](https://clojure-lsp.io/installation/) and
  [Leiningen](https://leiningen.org/).
- **JS / TS** — per-project `eslint` and / or `biome` in `node_modules`.
  These LSP clients are auto-disabled when the project has no matching
  config file.
- **Markdown** —
  [`markdownlint-cli2`](https://github.com/DavidAnson/markdownlint-cli2) for
  linting and format-on-save.
- **Search** —
  [`ripgrep`](https://github.com/BurntSushi/ripgrep) (`M-x counsel-rg`) or
  [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)
  (`M-x counsel-ag`).
- **Fonts** — [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads)
  if you want the configured default font.

## Layout

```
~/.emacs.d/
├── early-init.el                  Pause GC during startup.
├── init.el                        Bootstrap + auto-load + local.el hook.
├── custom.el                      Auto-generated, gitignored.
├── local.el                       Optional, gitignored, machine-specific.
├── themes/github/                 Theme submodule (GitHub Dark Dimmed).
└── customizations/
    ├── 00-lib-utils.el            Shared utilities.
    ├── 01-lib-language.el         my/define-language helper.
    ├── 10-ui.el                   Frame, theme, modeline, fonts.
    ├── 15-editing.el              Editing defaults, tree-sitter grammars.
    ├── 20-navigation.el           which-key, ivy/counsel/swiper.
    ├── 25-projects.el             Projectile + counsel-projectile + ag.
    ├── 30-git.el                  Magit.
    ├── 35-filetree.el             Treemacs + ace-window.
    ├── 40-lsp.el                  Core LSP, flycheck, dap-mode.
    ├── 45-extra-modes.el          prog-mode-wide LSP hook + Ruby/JVM/.h mappings.
    ├── 50-elisp-editing.el        paredit, eldoc, rainbow-delimiters.
    ├── lang-clojure.el            CIDER, clj-refactor, cider-hydra.
    ├── lang-go.el                 go-ts-mode + gopls + format-on-save.
    ├── lang-js.el                 js-ts-mode, eslint/biome gating.
    ├── lang-markdown.el           markdown-mode + markdownlint-cli2.
    ├── lang-python.el             python-ts-mode + pylsp + ruff + venv resolution.
    ├── lang-terraform.el          terraform-mode + format-on-save + outline.
    └── lang-yaml.el               yaml-mode + LSP.
```

`init.el` auto-loads every `.el` file in `customizations/` in alphabetic
order. The numeric prefixes on core modules (`00-`, `10-`, …) and the
`lang-` prefix on language modules document and enforce load order. There
is no hand-curated list to maintain.

## Adding a new language

For a typical "tree-sitter mode + LSP + format-on-save" language, drop a
single file in `customizations/`. Example — Rust:

```elisp
;;; lang-rust.el --- Rust editing -*- lexical-binding: t -*-
;;; Code:

(my/define-language rust
  :mode rust-ts-mode
  :extensions ("\\.rs\\'")
  :lsp t
  :formatter lsp-format-buffer)

(provide 'lang-rust)
;;; lang-rust.el ends here
```

That's it. Restart Emacs (or `M-x load-file`) and `.rs` files will open in
`rust-ts-mode`, start `rust-analyzer` via `lsp-deferred`, and reformat on
save.

`my/define-language` arguments:

| Argument       | Description |
|----------------|-------------|
| `:mode`        | The major-mode symbol (required). |
| `:extensions`  | List of regexps mapped to `:mode` in `auto-mode-alist`. |
| `:lsp`         | When non-nil, add `lsp-deferred` to `<mode>-hook`. |
| `:formatter`   | A formatter function. If its name ends in `-mode` it is enabled as a buffer-local minor mode; otherwise it is added to `before-save-hook` buffer-locally. |
| `:save-hooks`  | A list of functions added to `before-save-hook` (use this when you need several save-time actions, e.g. format + organize-imports). |
| `:extra-hooks` | A list of functions appended to `<mode>-hook`. |

If a language needs more than that — virtualenv resolution, multiple LSP
clients, project-local executables, custom file-name mappings — write a
hand-rolled `lang-<name>.el`. See `lang-python.el`, `lang-js.el`, and
`lang-clojure.el` as references.

## Per-machine overrides (`local.el`)

`init.el` loads `~/.emacs.d/local.el` last if it exists. The file is
gitignored, so machine-specific tweaks don't pollute the repo. Typical uses:

```elisp
;;; local.el --- machine-specific overrides
(set-face-attribute 'default nil :height 130)  ;; bigger font for this monitor
(setq projectile-project-search-path '("~/work/" "~/oss/"))
(load "~/work/internal-tools.el")              ;; private setup
```

## Project-wide search

- `M-x counsel-rg` — ripgrep (recommended).
- `M-x counsel-ag` — The Silver Searcher.
- `M-x counsel-git-grep` — `git grep` (no extra binary required, but only
  works inside git repositories).

## Upgrading packages

`M-x list-packages` refreshes the cache and shows updates. Press `U` to
mark all upgradeable packages, then `x` to install. Installed packages
live in `~/.emacs.d/elpa`.

## Running as a daemon (macOS)

To run Emacs as a background daemon that starts on login, create a
launchd plist at `~/Library/LaunchAgents/org.gnu.emacs.daemon.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.gnu.emacs.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/emacs</string>
        <string>--fg-daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Use `--fg-daemon`, not `--daemon`. The `--daemon` flag forks a child
process, which causes launchd to lose track of the real PID. That breaks
`KeepAlive` restarts and `launchctl kickstart -k`, and can result in stale
duplicate daemons. `--fg-daemon` keeps Emacs in the foreground so launchd
manages it correctly.

Load the service with:

```sh
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.gnu.emacs.daemon.plist
```

Connect with `emacsclient -c` for a graphical frame, or `emacsclient -t`
for a terminal frame.

To restart the daemon:

```sh
launchctl kickstart -k gui/$(id -u)/org.gnu.emacs.daemon
```

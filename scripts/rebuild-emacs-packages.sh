#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/rebuild-emacs-packages.sh --yes

Stops the user Emacs daemon when systemd is available, purges generated
package/bytecode artifacts, reinstalls packages by batch-loading init.el, and
restarts the daemon.

Deleted paths:
  - elpa/
  - eln-cache/
  - archive-contents
  - package-quickstart.el and package-quickstart.elc
  - stray *.elc files under this config
USAGE
}

if [[ "${1:-}" != "--yes" ]]; then
  usage
  exit 2
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$(cd -- "$script_dir/.." && pwd)"

cd "$config_dir"

if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet emacs; then
  echo "Stopping emacs.service..."
  systemctl --user stop emacs
fi

echo "Purging generated Emacs package artifacts..."
rm -rf elpa eln-cache archive-contents package-quickstart.el package-quickstart.elc
find . -path ./.git -prune -o -name '*.elc' -type f -print -delete

echo "Reinstalling packages by loading init.el in batch mode..."
emacs --batch -l init.el

if command -v systemctl >/dev/null 2>&1; then
  echo "Starting emacs.service..."
  systemctl --user start emacs
  systemctl --user status emacs --no-pager
else
  echo "systemctl not found; start Emacs manually when ready."
fi

#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/install-spell-dictionaries.sh

Installs the OS-level spell-checking backend/dictionaries used by Enchant and
Jinx. This script supports common Linux distros and macOS/Homebrew.
USAGE
}

run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew not found. Install Homebrew first: https://brew.sh"
      exit 1
    fi
    # Enchant is the library Jinx uses. Aspell provides English dictionaries
    # on macOS; Homebrew's Hunspell formula does not ship dictionaries.
    run brew install enchant aspell
    ;;

  Linux)
    if [[ -r /etc/os-release ]]; then
      # shellcheck source=/dev/null
      . /etc/os-release
    fi

    distro_ids=" ${ID:-} ${ID_LIKE:-} "

    if [[ "$distro_ids" == *" arch "* ]]; then
      run sudo pacman -S --needed enchant hunspell hunspell-en_us
    elif [[ "$distro_ids" == *" debian "* || "$distro_ids" == *" ubuntu "* ]]; then
      run sudo apt-get update
      run sudo apt-get install -y enchant-2 hunspell hunspell-en-us
    elif [[ "$distro_ids" == *" fedora "* || "$distro_ids" == *" rhel "* ]]; then
      run sudo dnf install -y enchant2 hunspell hunspell-en-US
    else
      cat <<'EOF'
Unsupported Linux distribution.

Install these with your package manager:
  - Enchant 2
  - Hunspell
  - A Hunspell English dictionary for en_US

Common package names:
  Arch:          enchant hunspell hunspell-en_us
  Debian/Ubuntu: enchant-2 hunspell hunspell-en-us
  Fedora/RHEL:   enchant2 hunspell hunspell-en-US
EOF
      exit 1
    fi
    ;;

  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

if command -v enchant-lsmod-2 >/dev/null 2>&1; then
  echo
  echo "Available Enchant dictionaries:"
  enchant-lsmod-2 -list-dicts || true
elif command -v enchant-lsmod >/dev/null 2>&1; then
  echo
  echo "Available Enchant dictionaries:"
  enchant-lsmod -list-dicts || true
fi

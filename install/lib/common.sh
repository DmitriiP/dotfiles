#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DOTFILES_STATE_DIR="$XDG_CONFIG_HOME/dotfiles"

log() {
    printf '[dotfiles] %s\n' "$*"
}

warn() {
    printf '[dotfiles] warning: %s\n' "$*" >&2
}

die() {
    printf '[dotfiles] error: %s\n' "$*" >&2
    exit 1
}

ensure_dir() {
    mkdir -p "$1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    if command_exists pacman; then
        printf 'arch\n'
        return
    fi

    if command_exists apt-get; then
        printf 'debian\n'
        return
    fi

    if command_exists brew; then
        printf 'macos\n'
        return
    fi

    printf 'unknown\n'
}

require_stow() {
    command_exists stow || die "GNU Stow is required. Run install/bootstrap.sh first."
}

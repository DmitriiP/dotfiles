#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

WIZARD=0
PROFILE_FILE=""

usage() {
    cat <<'EOF'
Usage: ./install/bootstrap.sh [options]

Options:
  --wizard          Force interactive setup
  --profile FILE    Use a profile env file
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --wizard)
            WIZARD=1
            shift
            ;;
        --profile)
            [[ $# -ge 2 ]] || die "--profile requires a value"
            PROFILE_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

case "$(detect_os)" in
    arch)
        if ! command_exists stow; then
            log "Installing GNU Stow on Arch"
            sudo pacman -S --needed stow
        fi
        ;;
    debian)
        if ! command_exists stow; then
            log "Installing GNU Stow on Debian/Ubuntu"
            sudo apt-get install -y stow
        fi
        ;;
    macos)
        warn "Bootstrap package installation is not implemented for macOS yet"
        ;;
    *)
        warn "Unknown OS; continuing without package installation"
        ;;
esac

if (( WIZARD )); then
    if [[ -n "$PROFILE_FILE" ]]; then
        exec "$REPO_ROOT/install/wizard.sh" --profile "$PROFILE_FILE"
    fi
    exec "$REPO_ROOT/install/wizard.sh"
fi

if [[ -n "$PROFILE_FILE" ]]; then
    exec "$REPO_ROOT/install/apply.sh" --profile "$PROFILE_FILE"
fi

if [[ -f "$DOTFILES_STATE_DIR/profile.env" ]]; then
    exec "$REPO_ROOT/install/apply.sh"
fi

exec "$REPO_ROOT/install/wizard.sh"

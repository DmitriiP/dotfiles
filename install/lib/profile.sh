#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

profile_path() {
    printf '%s/profile.env\n' "$DOTFILES_STATE_DIR"
}

managed_modules_path() {
    printf '%s/managed-modules\n' "$DOTFILES_STATE_DIR"
}

load_profile() {
    ENABLED_MODULES="${ENABLED_MODULES:-}"
    AWESOME_WALLPAPER_SOURCE="${AWESOME_WALLPAPER_SOURCE:-}"
    GIT_USER_NAME="${GIT_USER_NAME:-}"
    GIT_USER_EMAIL="${GIT_USER_EMAIL:-}"
    GIT_SIGNING_KEY="${GIT_SIGNING_KEY:-}"
    GIT_COMMIT_SIGNING="${GIT_COMMIT_SIGNING:-}"
    AGENT_CLI="${AGENT_CLI:-}"

    local path
    path="$(profile_path)"
    if [[ -f "$path" ]]; then
        # shellcheck disable=SC1090
        source "$path"
    fi
}

save_profile() {
    ensure_dir "$DOTFILES_STATE_DIR"

    cat >"$(profile_path)" <<EOF
ENABLED_MODULES=${ENABLED_MODULES@Q}
AWESOME_WALLPAPER_SOURCE=${AWESOME_WALLPAPER_SOURCE@Q}
GIT_USER_NAME=${GIT_USER_NAME@Q}
GIT_USER_EMAIL=${GIT_USER_EMAIL@Q}
GIT_SIGNING_KEY=${GIT_SIGNING_KEY@Q}
GIT_COMMIT_SIGNING=${GIT_COMMIT_SIGNING@Q}
AGENT_CLI=${AGENT_CLI@Q}
EOF
}

read_managed_modules() {
    local path
    path="$(managed_modules_path)"
    if [[ -f "$path" ]]; then
        tr '\n' ' ' <"$path"
    fi
}

write_managed_modules() {
    ensure_dir "$DOTFILES_STATE_DIR"
    : >"$(managed_modules_path)"

    local module
    for module in "$@"; do
        printf '%s\n' "$module" >>"$(managed_modules_path)"
    done
}

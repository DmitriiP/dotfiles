#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
source "$REPO_ROOT/install/lib/profile.sh"

TARGET="${HOME}"
PROFILE_FILE=""
INSTALL_PACKAGES=1
DRY_RUN=0
ENABLED_MODULES="${ENABLED_MODULES:-}"
AWESOME_WALLPAPER_SOURCE="${AWESOME_WALLPAPER_SOURCE:-}"
GIT_USER_NAME="${GIT_USER_NAME:-}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-}"
GIT_SIGNING_KEY="${GIT_SIGNING_KEY:-}"
GIT_COMMIT_SIGNING="${GIT_COMMIT_SIGNING:-}"
AGENT_CLI="${AGENT_CLI:-}"

usage() {
    cat <<'EOF'
Usage: ./install/apply.sh [options]

Options:
  --module NAME           Enable a module for this run (repeatable)
  --profile FILE          Load a profile env file instead of the saved profile
  --target DIR            Link into DIR instead of $HOME
  --wallpaper PATH        Use a local wallpaper override for the awesome module
  --skip-packages         Do not install system packages
  --dry-run               Show what Stow would do
  -h, --help              Show this help
EOF
}

MODULE_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --module)
            [[ $# -ge 2 ]] || die "--module requires a value"
            MODULE_ARGS+=("$2")
            shift 2
            ;;
        --profile)
            [[ $# -ge 2 ]] || die "--profile requires a value"
            PROFILE_FILE="$2"
            shift 2
            ;;
        --target)
            [[ $# -ge 2 ]] || die "--target requires a value"
            TARGET="$2"
            shift 2
            ;;
        --wallpaper)
            [[ $# -ge 2 ]] || die "--wallpaper requires a value"
            AWESOME_WALLPAPER_SOURCE="$2"
            shift 2
            ;;
        --skip-packages)
            INSTALL_PACKAGES=0
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
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

if [[ -n "$PROFILE_FILE" ]]; then
    [[ -f "$PROFILE_FILE" ]] || die "Profile not found: $PROFILE_FILE"
    # shellcheck disable=SC1090
    source "$PROFILE_FILE"
else
    load_profile
fi

if [[ ${#MODULE_ARGS[@]} -gt 0 ]]; then
    ENABLED_MODULES="${MODULE_ARGS[*]}"
fi

modules=()
for _m in ${ENABLED_MODULES:-}; do modules+=("$_m"); done
unset _m
[[ ${#modules[@]} -gt 0 ]] || die "No modules selected. Run install/wizard.sh or pass --module."

read_manifest_packages() {
    local manifest_dir="$1"
    local -a result=()
    local manifest pkg

    for manifest in "$manifest_dir/base.txt"; do
        [[ -f "$manifest" ]] || continue
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] || continue
            [[ "$pkg" != \#* ]] || continue
            result+=("$pkg")
        done <"$manifest"
    done

    local module
    for module in "${modules[@]}"; do
        manifest="$manifest_dir/${module}.txt"
        [[ -f "$manifest" ]] || continue
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] || continue
            [[ "$pkg" != \#* ]] || continue
            result+=("$pkg")
        done <"$manifest"
    done

    [[ ${#result[@]} -gt 0 ]] && printf '%s\n' "${result[@]}"
}

install_arch_packages() {
    local -a packages=()
    mapfile -t packages < <(read_manifest_packages "$REPO_ROOT/install/manifests/arch")

    if [[ ${#packages[@]} -eq 0 ]]; then
        return
    fi

    log "Installing Arch packages for selected modules"
    sudo pacman -S --needed "${packages[@]}"
}

install_debian_packages() {
    local -a packages=()
    mapfile -t packages < <(read_manifest_packages "$REPO_ROOT/install/manifests/ubuntu")

    if [[ ${#packages[@]} -eq 0 ]]; then
        return
    fi

    log "Installing packages for selected modules"
    sudo apt-get install -y "${packages[@]}"
}

run_module_hooks() {
    local module hook
    for module in "${modules[@]}"; do
        hook="$REPO_ROOT/install/hooks/${module}.sh"
        [[ -x "$hook" ]] || continue
        log "Running post-install hook: $module"
        source "$hook"
    done
}

run_module_post_hooks() {
    local module hook
    for module in "${modules[@]}"; do
        hook="$REPO_ROOT/install/hooks/${module}.post.sh"
        [[ -x "$hook" ]] || continue
        log "Running post-stow hook: $module"
        source "$hook"
    done
}

BACKUP_DIR=""

backup_stow_conflicts() {
    local module="$1"
    local conflicts

    conflicts="$(stow -n --restow --dir "$REPO_ROOT/modules" --target "$TARGET" "$module" 2>&1 || true)"

    local -a paths=()
    while IFS= read -r line; do
        if [[ "$line" == *"existing target is neither a link nor a directory:"* ]]; then
            local rel="${line##*existing target is neither a link nor a directory: }"
            rel="${rel% }"
            [[ -n "$rel" ]] && paths+=("$rel")
        fi
    done <<<"$conflicts"

    [[ ${#paths[@]} -gt 0 ]] || return 0

    if [[ -z "$BACKUP_DIR" ]]; then
        BACKUP_DIR="$DOTFILES_STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
        ensure_dir "$BACKUP_DIR"
        log "Backing up conflicting files to $BACKUP_DIR"
    fi

    local rel_path
    for rel_path in "${paths[@]}"; do
        local src="$TARGET/$rel_path"
        [[ -e "$src" ]] || continue
        ensure_dir "$BACKUP_DIR/$(dirname "$rel_path")"
        mv "$src" "$BACKUP_DIR/$rel_path"
        log "  backed up: $rel_path"
    done
}

ensure_git_checkout() {
    local repo_url="$1"
    local target_dir="$2"

    if [[ -d "$target_dir/.git" ]]; then
        return
    fi

    if [[ -e "$target_dir" && ! -d "$target_dir/.git" ]]; then
        die "Cannot clone into existing non-git path: $target_dir"
    fi

    ensure_dir "$(dirname "$target_dir")"
    log "Cloning $(basename "$target_dir")"
    git clone --depth 1 "$repo_url" "$target_dir"
}

if (( INSTALL_PACKAGES )); then
    case "$(detect_os)" in
        arch)
            install_arch_packages
            ;;
        debian)
            install_debian_packages
            ;;
        macos)
            warn "Package installation is not implemented for macOS yet; applying links only"
            ;;
        *)
            warn "Unknown OS; applying links only"
            ;;
    esac

    run_module_hooks
fi

require_stow

if [[ " ${modules[*]} " == *" yubikey "* ]]; then
    ensure_dir "$TARGET/.gnupg"
    chmod 700 "$TARGET/.gnupg"
fi

if [[ " ${modules[*]} " == *" awesome "* || " ${modules[*]} " == *" alacritty "* || " ${modules[*]} " == *" git "* || " ${modules[*]} " == *" zellij "* || " ${modules[*]} " == *" nvim "* || " ${modules[*]} " == *" zscaler "* ]]; then
    ensure_dir "$TARGET/.config"
fi

if [[ " ${modules[*]} " == *" alacritty "* || " ${modules[*]} " == *" yubikey "* || " ${modules[*]} " == *" zellij "* || " ${modules[*]} " == *" agent "* || " ${modules[*]} " == *" zscaler "* ]]; then
    ensure_dir "$TARGET/.local/bin"
fi

if [[ " ${modules[*]} " == *" git "* ]]; then
    ensure_dir "$TARGET/.config/git"
fi

if [[ " ${modules[*]} " == *" zscaler "* ]]; then
    ensure_dir "$TARGET/.config/systemd/user"
    ensure_dir "$TARGET/.local/share/applications"
fi

previous_modules=()
for _m in $(read_managed_modules); do previous_modules+=("$_m"); done
unset _m

declare -A selected=()
for module in "${modules[@]}"; do
    selected["$module"]=1
done

if (( DRY_RUN )); then
    STOW_FLAGS=(-n -v)
else
    STOW_FLAGS=(-v)
fi

for module in "${previous_modules[@]}"; do
    [[ -n "$module" ]] || continue
    if [[ -z "${selected[$module]:-}" ]]; then
        log "Unstowing disabled module: $module"
        stow -D "${STOW_FLAGS[@]}" --dir "$REPO_ROOT/modules" --target "$TARGET" "$module"
    fi
done

for module in "${modules[@]}"; do
    [[ -d "$REPO_ROOT/modules/$module" ]] || die "Unknown module: $module"
    if ! (( DRY_RUN )); then
        backup_stow_conflicts "$module"
    fi
    log "Stowing module: $module"
    stow "${STOW_FLAGS[@]}" --restow --dir "$REPO_ROOT/modules" --target "$TARGET" "$module"
done

if [[ " ${modules[*]} " == *" awesome "* ]]; then
    ensure_dir "$TARGET/.config/awesome"
    if [[ -n "${AWESOME_WALLPAPER_SOURCE:-}" ]]; then
        [[ -e "$AWESOME_WALLPAPER_SOURCE" ]] || die "Wallpaper not found: $AWESOME_WALLPAPER_SOURCE"
        log "Linking awesome wallpaper override"
        ln -sfn "$AWESOME_WALLPAPER_SOURCE" "$TARGET/.config/awesome/wall.override"
    else
        rm -f "$TARGET/.config/awesome/wall.override"
    fi
fi

if [[ " ${modules[*]} " == *" zsh "* ]]; then
    ensure_git_checkout "https://github.com/ohmyzsh/ohmyzsh.git" "$TARGET/.oh-my-zsh"
    ensure_git_checkout "https://github.com/romkatv/powerlevel10k.git" "$TARGET/.oh-my-zsh/custom/themes/powerlevel10k"
    ensure_git_checkout "https://github.com/jeffreytse/zsh-vi-mode" "$TARGET/.oh-my-zsh/custom/plugins/zsh-vi-mode"
fi

if [[ " ${modules[*]} " == *" git "* ]]; then
    [[ -n "$GIT_USER_NAME" ]] || die "Git module requires GIT_USER_NAME"
    [[ -n "$GIT_USER_EMAIL" ]] || die "Git module requires GIT_USER_EMAIL"

    local_git_config="$TARGET/.config/git/local.inc"
    rm -f "$local_git_config"
    git config -f "$local_git_config" user.name "$GIT_USER_NAME"
    git config -f "$local_git_config" user.email "$GIT_USER_EMAIL"

    if [[ -n "$GIT_SIGNING_KEY" ]]; then
        git config -f "$local_git_config" user.signingKey "$GIT_SIGNING_KEY"
    fi

    if [[ "$GIT_COMMIT_SIGNING" == "true" ]]; then
        git config -f "$local_git_config" commit.gpgsign true
        git config -f "$local_git_config" gpg.format openpgp
    fi

    chmod 600 "$local_git_config"
fi

if [[ " ${modules[*]} " == *" nvim "* ]]; then
    if command_exists nvim; then
        log "Bootstrapping Neovim plugins and tools"
        HOME="$TARGET" \
        XDG_CONFIG_HOME="$TARGET/.config" \
        XDG_DATA_HOME="$TARGET/.local/share" \
        XDG_STATE_HOME="$TARGET/.local/state" \
        XDG_CACHE_HOME="$TARGET/.cache" \
        nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa
    else
        warn "Neovim is not installed yet; skipping runtime bootstrap"
    fi
fi

if ! (( DRY_RUN )); then
    run_module_post_hooks
fi

write_managed_modules "${modules[@]}"
ENABLED_MODULES="${modules[*]}"
save_profile

if [[ -n "$BACKUP_DIR" ]]; then
    log "Conflicting files were backed up to $BACKUP_DIR"
fi

log "Done"

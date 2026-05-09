#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
source "$REPO_ROOT/install/lib/profile.sh"

PROFILE_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || die "--profile requires a value"
            PROFILE_FILE="$2"
            shift 2
            ;;
        -h|--help)
            printf 'Usage: ./install/wizard.sh [--profile FILE]\n'
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

awesome_default="y"
if [[ " ${ENABLED_MODULES:-} " != *" awesome "* ]]; then
    awesome_default="n"
fi

alacritty_default="y"
if [[ " ${ENABLED_MODULES:-} " != *" alacritty "* ]]; then
    alacritty_default="n"
fi

zsh_default="y"
if [[ " ${ENABLED_MODULES:-} " != *" zsh "* ]]; then
    zsh_default="n"
fi

yubikey_default="y"
if [[ " ${ENABLED_MODULES:-} " != *" yubikey "* ]]; then
    yubikey_default="n"
fi

git_default="y"
if [[ " ${ENABLED_MODULES:-} " != *" git "* ]]; then
    git_default="n"
fi

zellij_default="y"
if [[ " ${ENABLED_MODULES:-} " != *" zellij "* ]]; then
    zellij_default="n"
fi

nvim_default="y"
if [[ " ${ENABLED_MODULES:-} " != *" nvim "* ]]; then
    nvim_default="n"
fi

copilot_default="y"
if [[ " ${ENABLED_MODULES:-} " != *" copilot "* ]]; then
    copilot_default="n"
fi

read -r -p "Enable awesome module? [${awesome_default^^}/${awesome_default,,}] " awesome_answer
awesome_answer="${awesome_answer:-$awesome_default}"

read -r -p "Enable alacritty module? [${alacritty_default^^}/${alacritty_default,,}] " alacritty_answer
alacritty_answer="${alacritty_answer:-$alacritty_default}"

read -r -p "Enable zsh module? [${zsh_default^^}/${zsh_default,,}] " zsh_answer
zsh_answer="${zsh_answer:-$zsh_default}"

read -r -p "Enable yubikey module? [${yubikey_default^^}/${yubikey_default,,}] " yubikey_answer
yubikey_answer="${yubikey_answer:-$yubikey_default}"

read -r -p "Enable git module? [${git_default^^}/${git_default,,}] " git_answer
git_answer="${git_answer:-$git_default}"

read -r -p "Enable zellij module? [${zellij_default^^}/${zellij_default,,}] " zellij_answer
zellij_answer="${zellij_answer:-$zellij_default}"

read -r -p "Enable nvim module? [${nvim_default^^}/${nvim_default,,}] " nvim_answer
nvim_answer="${nvim_answer:-$nvim_default}"

read -r -p "Enable copilot module? [${copilot_default^^}/${copilot_default,,}] " copilot_answer
copilot_answer="${copilot_answer:-$copilot_default}"

modules=()
case "$awesome_answer" in
    y|Y|yes|YES)
        modules+=(awesome)
        ;;
    n|N|no|NO)
        ;;
    *)
        die "Please answer yes or no"
        ;;
esac

case "$alacritty_answer" in
    y|Y|yes|YES)
        modules+=(alacritty)
        ;;
    n|N|no|NO)
        ;;
    *)
        die "Please answer yes or no"
        ;;
esac

case "$zsh_answer" in
    y|Y|yes|YES)
        modules+=(zsh)
        ;;
    n|N|no|NO)
        ;;
    *)
        die "Please answer yes or no"
        ;;
esac

case "$yubikey_answer" in
    y|Y|yes|YES)
        modules+=(yubikey)
        ;;
    n|N|no|NO)
        ;;
    *)
        die "Please answer yes or no"
        ;;
esac

case "$git_answer" in
    y|Y|yes|YES)
        modules+=(git)
        ;;
    n|N|no|NO)
        ;;
    *)
        die "Please answer yes or no"
        ;;
esac

case "$zellij_answer" in
    y|Y|yes|YES)
        modules+=(zellij)
        ;;
    n|N|no|NO)
        ;;
    *)
        die "Please answer yes or no"
        ;;
esac

case "$nvim_answer" in
    y|Y|yes|YES)
        modules+=(nvim)
        ;;
    n|N|no|NO)
        ;;
    *)
        die "Please answer yes or no"
        ;;
esac

case "$copilot_answer" in
    y|Y|yes|YES)
        modules+=(copilot)
        ;;
    n|N|no|NO)
        ;;
    *)
        die "Please answer yes or no"
        ;;
esac

if [[ " ${modules[*]} " == *" awesome "* ]]; then
    read -r -p "Custom awesome wallpaper path [leave empty for repo default]: " wallpaper_input
    if [[ -n "$wallpaper_input" ]]; then
        AWESOME_WALLPAPER_SOURCE="$wallpaper_input"
    else
        AWESOME_WALLPAPER_SOURCE=""
    fi
else
    AWESOME_WALLPAPER_SOURCE=""
fi

if [[ " ${modules[*]} " == *" git "* ]]; then
    git_name_default="${GIT_USER_NAME:-$(git config --global --get user.name 2>/dev/null || true)}"
    git_email_default="${GIT_USER_EMAIL:-$(git config --global --get user.email 2>/dev/null || true)}"
    git_signing_key_default="${GIT_SIGNING_KEY:-$(git config --global --get user.signingkey 2>/dev/null || true)}"
    git_commit_signing_default="${GIT_COMMIT_SIGNING:-$(git config --global --get commit.gpgsign 2>/dev/null || true)}"

    if [[ -z "$git_commit_signing_default" ]]; then
        if [[ -n "$git_signing_key_default" ]]; then
            git_commit_signing_default="true"
        else
            git_commit_signing_default="false"
        fi
    fi

    read -r -p "Git user name [$git_name_default]: " git_name_input
    GIT_USER_NAME="${git_name_input:-$git_name_default}"

    read -r -p "Git user email [$git_email_default]: " git_email_input
    GIT_USER_EMAIL="${git_email_input:-$git_email_default}"

    read -r -p "Git signing key [$git_signing_key_default]: " git_signing_key_input
    GIT_SIGNING_KEY="${git_signing_key_input:-$git_signing_key_default}"

    signing_prompt_default="n"
    if [[ "$git_commit_signing_default" == "true" ]]; then
        signing_prompt_default="y"
    fi
    read -r -p "Enable commit signing by default? [${signing_prompt_default^^}/${signing_prompt_default,,}] " git_signing_answer
    git_signing_answer="${git_signing_answer:-$signing_prompt_default}"
    case "$git_signing_answer" in
        y|Y|yes|YES)
            GIT_COMMIT_SIGNING="true"
            ;;
        n|N|no|NO)
            GIT_COMMIT_SIGNING="false"
            ;;
        *)
            die "Please answer yes or no"
            ;;
    esac
else
    GIT_USER_NAME=""
    GIT_USER_EMAIL=""
    GIT_SIGNING_KEY=""
    GIT_COMMIT_SIGNING=""
fi

ENABLED_MODULES="${modules[*]}"
save_profile

log "Saved profile to $(profile_path)"
if [[ -n "$PROFILE_FILE" ]]; then
    exec "$REPO_ROOT/install/apply.sh" --profile "$PROFILE_FILE"
fi
exec "$REPO_ROOT/install/apply.sh"

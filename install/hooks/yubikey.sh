#!/usr/bin/env bash
# YubiKey pcscd hotplug install hook.
#
# install/apply.sh sources this file (giving it REPO_ROOT/log/warn/
# command_exists/detect_os for free), but it is also safe to `source`
# directly or run as `bash install/hooks/yubikey.sh`. Everything, including
# bootstrapping install/lib/common.sh, happens inside a subshell so its
# `set -e` and any `exit` can never mutate options in - or close - whatever
# shell sources this file.
(
    repo_root="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

    if ! declare -F log >/dev/null 2>&1; then
        # shellcheck source=/dev/null
        source "$repo_root/install/lib/common.sh"
    fi

    set -euo pipefail

    if [[ "$(detect_os)" == "macos" ]]; then
        exit 0
    fi

    if ! command_exists systemctl; then
        warn "systemctl not found; skipping YubiKey pcscd hotplug rule"
        exit 0
    fi

    rule_src="$repo_root/install/resources/yubikey/99-yubikey-pcscd-reload.rules"
    unit_src="$repo_root/install/resources/yubikey/yubikey-pcscd-reload.service"
    script_src="$repo_root/install/resources/yubikey/yubikey-pcscd-reload"
    rule_dest="/etc/udev/rules.d/99-yubikey-pcscd-reload.rules"
    unit_dest="/etc/systemd/system/yubikey-pcscd-reload.service"
    script_dest="/usr/local/libexec/yubikey-pcscd-reload"

    install_system_file() {
        local src="$1" dest="$2" mode="$3"

        if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
            return 0
        fi

        log "Installing $dest"
        sudo install -D -m "$mode" "$src" "$dest"
    }

    install_system_file "$rule_src" "$rule_dest" 644
    install_system_file "$unit_src" "$unit_dest" 644
    install_system_file "$script_src" "$script_dest" 755

    log "Reloading udev rules and systemd units"
    sudo udevadm control --reload-rules
    sudo udevadm trigger --subsystem-match=usb
    sudo systemctl daemon-reload
)

#!/usr/bin/env bash
set -euo pipefail

case "$(detect_os)" in
    debian)
        if command_exists npm && ! command_exists tree-sitter; then
            log "Installing tree-sitter-cli via npm"
            sudo npm install -g tree-sitter-cli
        fi
        ;;
esac

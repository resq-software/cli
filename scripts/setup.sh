#!/usr/bin/env bash

# Copyright 2026 ResQ
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Sets up the ResQ CLI development environment.
#
# Usage:
#   ./scripts/setup.sh [--check] [--skip-hooks] [--yes]
#
# Options:
#   --check        Verify the environment without making changes.
#   --skip-hooks   Skip git hook configuration.
#   --yes          Auto-confirm all prompts (CI mode).
#
# What this does:
#   1. Installs Nix with flakes support (if missing).
#   2. Re-enters the script inside `nix develop` so all Rust tools are available.
#   3. Installs Docker (if missing).
#   4. Configures git hooks (.git-hooks/).
#
# Requirements:
#   curl, git, bash 4+
#
# Exit codes:
#   0  Success.
#   1  A required step failed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/shell-utils.sh
source "${SCRIPT_DIR}/lib/shell-utils.sh"

# ── Argument parsing ──────────────────────────────────────────────────────────
CHECK_ONLY=false
SKIP_HOOKS=false
for arg in "$@"; do
    case "$arg" in
        --check)       CHECK_ONLY=true ;;
        --skip-hooks)  SKIP_HOOKS=true ;;
        --yes)         export YES=1 ;;
        --help|-h)
            sed -n '/^# Usage/,/^$/p' "$0"
            exit 0
            ;;
    esac
done

# ── Check mode ────────────────────────────────────────────────────────────────
if [ "$CHECK_ONLY" = true ]; then
    log_info "Checking ResQ CLI environment..."
    ERRORS=0

    command_exists nix    || { log_error "nix not found";    ERRORS=$((ERRORS+1)); }
    command_exists rustc  || { log_warning "rustc not found (run: nix develop)"; }
    command_exists cargo  || { log_warning "cargo not found (run: nix develop)"; }
    command_exists docker || { log_warning "docker not found"; }

    HOOK_PATH=$(git -C "$PROJECT_ROOT" config core.hooksPath 2>/dev/null || echo "(not set)")
    if [ "$HOOK_PATH" = ".git-hooks" ]; then
        log_success "git hooks configured"
    else
        log_warning "git hooks not configured (core.hooksPath: $HOOK_PATH)"
    fi

    [ $ERRORS -eq 0 ] && log_success "Environment looks good." || exit 1
    exit 0
fi

# ── Main setup ────────────────────────────────────────────────────────────────
echo "╔════════════════════════════════╗"
echo "║  ResQ CLI — Environment Setup  ║"
echo "╚════════════════════════════════╝"
echo ""

# 1. Nix
install_nix

# 2. Re-enter inside nix develop (Rust toolchain, cargo-watch, etc.)
#    If nix is available and we're not already inside a dev shell this call
#    will exec into nix develop and re-run the rest of this script there.
ensure_nix_env "$@"

# 3. Docker
install_docker

# 4. Git hooks
if [ "$SKIP_HOOKS" = false ]; then
    if [ -d "$PROJECT_ROOT/.git-hooks" ]; then
        log_info "Configuring git hooks..."
        git -C "$PROJECT_ROOT" config core.hooksPath .git-hooks
        chmod +x "$PROJECT_ROOT"/.git-hooks/* 2>/dev/null || true
        log_success "Git hooks configured."
    else
        log_warning ".git-hooks/ not found — skipping hook setup."
    fi
fi

# 5. Verify Rust toolchain is available
if command_exists rustc && command_exists cargo; then
    log_info "Rust toolchain:"
    rustc --version
    cargo --version
else
    log_warning "Rust tools not in PATH. If outside nix develop, run: nix develop"
fi

echo ""
echo "╔════════════════════════════════════════╗"
echo "║  ✓ ResQ CLI setup complete             ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  nix develop                              # Enter dev shell"
echo "  cargo build --release --workspace        # Build all tools"
echo "  cargo nextest run                        # Run tests"
echo "  docker build -t resq-cli .               # Build Docker image"

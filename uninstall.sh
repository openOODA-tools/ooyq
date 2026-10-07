#!/bin/sh
# ==============================================================================
# ooyq Sovereign Clean Uninstaller
# "Removes ooyq binary, package installations, and cache."
#
# Usage:
#   curl -fsSL https://openooda-tooyq.github.io/ooyq/uninstall.sh | bash
#   or: ./uninstall.sh [options]
#
# Options:
#   --prefix <dir>       Target directory where standalone binary was installed
#   --dry-run            Simulate uninstallation without modifying the system
#   -y, --yes            Assume yes to all prompts (non-interactive)
#   -h, --help           Show this help message
# ==============================================================================

set -eu

if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ] && [ "${TERM:-dumb}" != "dumb" ]; then
    CYAN="\033[38;5;51m"
    GREEN="\033[38;5;82m"
    YELLOW="\033[38;5;220m"
    RED="\033[38;5;196m"
    DIM="\033[38;5;242m"
    BOLD="\033[1m"
    RESET="\033[0m"
else
    CYAN="" GREEN="" YELLOW="" RED="" DIM="" BOLD="" RESET=""
fi

say()  { printf '%b\n' "$*"; }
ok()   { say "  ${GREEN}✔${RESET} $*"; }
warn() { say "  ${YELLOW}!${RESET} $*"; }
err()  { say "  ${RED}ERROR:${RESET} $*" >&2; }
step() { say ""; say " ${CYAN}${BOLD}$*${RESET}"; }

PREFIX=""
DRY_RUN=0
ASSUME_YES=0

while [ $# -gt 0 ]; do
    case "$1" in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        -h|--help)
            say "Usage: uninstall.sh [options]"
            say "Options:"
            say "  --prefix <dir>       Target directory where standalone binary was installed"
            say "  --dry-run            Simulate uninstallation without disk writes"
            say "  -y, --yes            Assume yes to all prompts"
            say "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            err "Unknown option: $1"
            exit 2
            ;;
    esac
done

step "ooyq Sovereign Clean Uninstaller"

REMOVED_COUNT=0

# --- 1. Detect Package Manager Installations ---
if command -v dpkg >/dev/null 2>&1 && dpkg -s ooyq >/dev/null 2>&1; then
    if [ "$DRY_RUN" -eq 1 ]; then
        say "  [dry-run] Would remove Debian package 'ooyq' (dpkg/apt)"
    else
        say "  Removing Debian package 'ooyq'..."
        sudo apt-get remove -y ooyq 2>/dev/null || sudo dpkg -r ooyq 2>/dev/null || true
        ok "Removed Debian package 'ooyq'"
    fi
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
fi

if command -v rpm >/dev/null 2>&1 && rpm -q ooyq >/dev/null 2>&1; then
    if [ "$DRY_RUN" -eq 1 ]; then
        say "  [dry-run] Would remove RPM package 'ooyq' (rpm/dnf)"
    else
        say "  Removing RPM package 'ooyq'..."
        sudo dnf remove -y ooyq 2>/dev/null || sudo rpm -e ooyq 2>/dev/null || true
        ok "Removed RPM package 'ooyq'"
    fi
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
fi

if command -v pacman >/dev/null 2>&1; then
    if pacman -Q ooyq >/dev/null 2>&1; then
        if [ "$DRY_RUN" -eq 1 ]; then
            say "  [dry-run] Would remove Arch package 'ooyq' (pacman)"
        else
            say "  Removing Arch package 'ooyq'..."
            sudo pacman -R --noconfirm ooyq 2>/dev/null || true
            ok "Removed Arch package 'ooyq'"
        fi
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    elif pacman -Q ooyq-bin >/dev/null 2>&1; then
        if [ "$DRY_RUN" -eq 1 ]; then
            say "  [dry-run] Would remove Arch package 'ooyq-bin' (pacman)"
        else
            say "  Removing Arch package 'ooyq-bin'..."
            sudo pacman -R --noconfirm ooyq-bin 2>/dev/null || true
            ok "Removed Arch package 'ooyq-bin'"
        fi
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
fi

# --- 2. Remove Standalone Binaries and Helpers ---
PATHS_TO_CHECK=""
if [ -n "$PREFIX" ]; then
    PATHS_TO_CHECK="$PREFIX/ooyq $PREFIX/ooyq-uninstall"
fi

PATHS_TO_CHECK="$PATHS_TO_CHECK
/usr/local/bin/ooyq
/usr/local/bin/ooyq-uninstall
${HOME}/.local/bin/ooyq
${HOME}/.local/bin/ooyq-uninstall
/usr/bin/ooyq
/usr/bin/ooyq-uninstall
${HOME}/.openooda/bin/ooyq
${HOME}/.openooda/bin/ooyq-uninstall"

if command -v ooyq >/dev/null 2>&1; then
    ACTIVE_BIN="$(command -v ooyq)"
    PATHS_TO_CHECK="$PATHS_TO_CHECK
$ACTIVE_BIN"
fi

DEDUPED_PATHS=""
for bin_candidate in $PATHS_TO_CHECK; do
    case " $DEDUPED_PATHS " in
        *" $bin_candidate "*) ;;
        *) DEDUPED_PATHS="$DEDUPED_PATHS $bin_candidate" ;;
    esac
done

for bin_path in $DEDUPED_PATHS; do
    if [ -f "$bin_path" ] || [ -L "$bin_path" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
            say "  [dry-run] Would delete $bin_path"
        else
            rm -f "$bin_path" 2>/dev/null || sudo rm -f "$bin_path" 2>/dev/null || true
            ok "Removed $bin_path"
        fi
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
done

# --- 3. Final Verification ---
say ""
if [ "$DRY_RUN" -eq 1 ]; then
    ok "${GREEN}Dry run complete.${RESET} (No system modifications were made)"
else
    if command -v ooyq >/dev/null 2>&1; then
        REMAINING="$(command -v ooyq)"
        warn "ooyq is still reachable at: $REMAINING (check your PATH or shell aliases)"
    else
        ok "${GREEN}${BOLD}ooyq has been cleanly uninstalled.${RESET}"
    fi
fi

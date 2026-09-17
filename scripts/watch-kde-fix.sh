#!/usr/bin/env bash

set -u

BASELINE="6.7.5-1.1"

UPSTREAM_URL="https://discuss.kde.org/t/fullscreen-windows-are-not-raised-correctly-after-kwin-6-7-5-update/50074"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/watch-kde-fix"
STATE_FILE="$STATE_DIR/last-alerted-version"

mkdir -p "$STATE_DIR"

CURRENT_KWIN="$(pacman -Q kwin 2>/dev/null | awk '{print $2}')"
AVAILABLE_KWIN="$(pacman -Si kwin 2>/dev/null | awk '/^Version/ {print $3; exit}')"

if [[ -z "${CURRENT_KWIN:-}" || -z "${AVAILABLE_KWIN:-}" ]]; then
    exit 0
fi

# Do nothing until CachyOS offers something newer than KWin 6.7.5.
if [[ "$(vercmp "$AVAILABLE_KWIN" "$BASELINE")" -le 0 ]]; then
    exit 0
fi

# Do not alert repeatedly for the same repository version.
if [[ -f "$STATE_FILE" ]]; then
    LAST_ALERTED="$(cat "$STATE_FILE" 2>/dev/null || true)"

    if [[ "$LAST_ALERTED" == "$AVAILABLE_KWIN" ]]; then
        exit 0
    fi
fi

TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

if ! curl -LfsS \
    --connect-timeout 10 \
    --max-time 20 \
    "$UPSTREAM_URL" \
    -o "$TMPFILE"; then
    exit 0
fi

# Convert the page to lower case for simpler matching.
PAGE_TEXT="$(tr '[:upper:]' '[:lower:]' < "$TMPFILE")"

# Strong positive language suggesting an actual fix.
POSITIVE_PATTERN='(fixed in|resolved in|fix merged|fixed by|patch merged|backported to|backport merged|this is fixed|issue is fixed|problem is fixed|regression is fixed|works in 6\.7\.6|works in 6\.8|fixed with 6\.7\.6|fixed with 6\.8)'

# Negative wording that should prevent a false positive.
NEGATIVE_PATTERN='(not fixed|still broken|still not fixed|not resolved|issue persists|problem persists|regression persists|still happens|still reproducible)'

POSITIVE_MATCH=0
NEGATIVE_MATCH=0

if printf '%s\n' "$PAGE_TEXT" | grep -Eqi "$POSITIVE_PATTERN"; then
    POSITIVE_MATCH=1
fi

if printf '%s\n' "$PAGE_TEXT" | grep -Eqi "$NEGATIVE_PATTERN"; then
    NEGATIVE_MATCH=1
fi

# Only notify when there is positive fix language and no obvious
# contradictory "still broken" language.
if [[ "$POSITIVE_MATCH" -eq 1 && "$NEGATIVE_MATCH" -eq 0 ]]; then

    kdialog \
        --title "KDE/KWin Fix May Be Available" \
        --msgbox "Installed KWin: $CURRENT_KWIN

Repository KWin: $AVAILABLE_KWIN

CachyOS now has a KWin release newer than 6.7.5.

The upstream report for the Steam/Wayland fullscreen regression contains language indicating that the issue may be fixed, merged, resolved, or backported.

Do not remove your KDE/Plasma holds until you review the upstream report and confirm the fix applies to this release.

Upstream report:
$UPSTREAM_URL"

    printf '%s\n' "$AVAILABLE_KWIN" > "$STATE_FILE"
fi

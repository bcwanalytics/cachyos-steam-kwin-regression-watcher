# cachyos-steam-kwin-regression-watcher

Monitors CachyOS/KWin releases and upstream KDE reports for fixes to the Steam/Wayland fullscreen window regression introduced around KWin 6.7.5.

## Requirements

- CachyOS or another Arch-based distribution
- KDE Plasma
- KWin
- `curl`
- `kdialog`
- `pacman-contrib`

## Installation

Clone the repository:

```bash
gh repo clone bcwanalytics/cachyos-steam-wayland-kwin-fixed-watcher
cd cachyos-steam-wayland-kwin-fixed-watcher
```

Install the watcher script:

```bash
mkdir -p ~/.local/bin
cp scripts/watch-kde-fix.sh ~/.local/bin/watch-kde-fix.sh
chmod +x ~/.local/bin/watch-kde-fix.sh
```

Install the systemd user service and timer:

```bash
mkdir -p ~/.config/systemd/user
cp systemd/watch-kde-fix.service ~/.config/systemd/user/
cp systemd/watch-kde-fix.timer ~/.config/systemd/user/
```

Reload systemd and enable the timer:

```bash
systemctl --user daemon-reload
systemctl --user enable --now watch-kde-fix.timer
```

## Usage

The watcher compares the installed KWin version with the version available in the CachyOS repositories.

When a KWin version newer than `6.7.5-1.1` becomes available, the script checks the upstream KDE report for indications that the Steam/Wayland fullscreen regression has been fixed, merged, resolved, or backported.

If the conditions are met, a persistent KDE dialog is displayed.

The watcher does not automatically install or upgrade any packages.

## Verify Timer

Check that the systemd timer is active:

```bash
systemctl --user list-timers | grep watch-kde-fix
```

You can also check its status directly:

```bash
systemctl --user status watch-kde-fix.timer
```

## Manual Test

Run the watcher manually:

```bash
~/.local/bin/watch-kde-fix.sh
```

If the repository version is still `6.7.5-1.1` or older, the script exits without displaying a dialog.

## Files

The repository contains:

```text
cachyos-steam-wayland-kwin-fixed-watcher/
├── README.md
├── scripts/
│   └── watch-kde-fix.sh
└── systemd/
    ├── watch-kde-fix.service
    └── watch-kde-fix.timer
```

## Uninstall

Disable the timer:

```bash
systemctl --user disable --now watch-kde-fix.timer
```

Remove the installed files:

```bash
rm -f ~/.local/bin/watch-kde-fix.sh
rm -f ~/.config/systemd/user/watch-kde-fix.service
rm -f ~/.config/systemd/user/watch-kde-fix.timer
systemctl --user daemon-reload
```

Optionally remove the watcher's saved state:

```bash
rm -rf ~/.local/state/watch-kde-fix
```

## Copyright and Usage

Copyright © 2026 Brandon Walker.

This repository is publicly viewable and may be used for personal reference or personal use.

Modification, redistribution, republishing, or creation of derivative works is not permitted without prior written permission from the copyright holder.

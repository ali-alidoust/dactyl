#!/bin/sh
unset LD_PRELOAD
SCRIPT_PATH=$(realpath $0)
export DACTYL_DIR=$(dirname $SCRIPT_PATH)
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
# Make sure nix-daemon can be started
sudo /usr/bin/systemctl start nix-daemon.socket >/dev/null 2>&1
dbus-update-activation-environment WAYLAND_DISPLAY=wayland-1 XDG_CURRENT_DESKTOP=sway
nixGL nix-shell --argstr dactylDir "$DACTYL_DIR" dactyl.nix

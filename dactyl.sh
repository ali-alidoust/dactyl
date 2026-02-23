#!/bin/sh
unset LD_PRELOAD
SCRIPT_PATH=$(realpath $0)
export DACTYL_DIR=$(dirname $SCRIPT_PATH)
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
dbus-run-session nixGL nix-shell --argstr dactylDir "$DACTYL_DIR" dactyl.nix

{ pkgs ? import <nixpkgs> {}, dactylDir }:

let
  kando_src = pkgs.appimageTools.extractType2 {
    pname = "kando-src";
    version = "latest";
    src = pkgs.fetchurl {
      url = "https://github.com/kando-menu/kando/releases/download/v2.2.0/Kando-2.2.0-x86_64.AppImage";
      hash = "sha256-GS3a9KpihBJ/RN7Ke8LLGNRC+c9Do3yOpKwHnYbysM0=";
    };
  };

  latestKando = pkgs.stdenv.mkDerivation {
    pname = "kando";
    version = "latest";

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/opt/kando
      cp -r ${kando_src}/* $out/opt/kando/

      cat > $out/opt/kando/portableMode.json <<EOF
      { "configDirectory" : "${dactylDir}/config/kando" }
      EOF

      mkdir -p $out/bin
      ln -s $out/opt/kando/kando $out/bin/kando

      cat > $out/bin/kando-trigger <<EOF
      #!/usr/bin/env bash
      SOCKET=\$(lsof -a -U -p \$(pgrep kando | head -n 1) | grep -o '/.*SingletonSocket' | head -n 1)
      printf "START\0\$(pwd)\0\00024\0\377\23\377\17o\"\7trigger\"\6\$1{\1" | socat - UNIX-CONNECT:\$SOCKET &>/dev/null
      EOF
      chmod +x $out/bin/kando-trigger
    '';
  };

  runPortals = pkgs.writeShellScriptBin "run-portals" ''
    # Define the absolute path from Nix
    PORTAL_BIN="${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal"

    while true; do
        dbus-update-activation-environment --all
        echo "[Supervisor] Starting xdg-desktop-portal..."
        # -r ensures it takes over the D-Bus name
        $PORTAL_BIN -r &
        PORTAL_PID=$!

        # Wait for the backend to register on D-Bus
        sleep 2

        echo "[Supervisor] Portals are running. Monitoring PIDs: $PORTAL_PID"

        # wait -n waits for the FIRST of the processes to exit/crash
        wait -n $PORTAL_PID

        echo "[Supervisor] Portal crashed or exited. Restarting..."

        # Kill the survivor
        kill $PORTAL_PID 2>/dev/null
        sleep 1
    done
  '';

  runSway = pkgs.writeShellScriptBin "run-sway" ''
    sleep 1
    sway --config "${dactylDir}/config/sway.conf"
  '';

  dactylPortalService = pkgs.stdenv.mkDerivation {
    pname = "xdg-desktop-portal-dactyl";
    version = "1.0";

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/dbus-1/services
      cat > $out/share/dbus-1/services/org.freedesktop.impl.portal.desktop.dactyl.service <<EOF
      [D-BUS Service]
      Name=org.freedesktop.impl.portal.desktop.dactyl
      Exec=${dactylDir}/bin/xdg-desktop-portal-dactyl.py
      EOF
    '';
  };
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    dactylPortalService
    runPortals
  ];

  packages = with pkgs; [
    swayfx
    fuzzel
    wtype
    (lib.hiPrio (writeShellScriptBin "kando" ''
      exec env XDG_CURRENT_DESKTOP=hyprland ${latestKando}/bin/kando --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
    ''))
    (lib.hiPrio (writeShellScriptBin "kando-trigger" ''
      exec ${latestKando}/bin/kando-trigger "$@"
    ''))
    dunst
    eww
    xdg-desktop-portal
  ];

  shellHook = ''
    export QT_QPA_PLATFORMTHEME=kde
    export GTK_THEME=Breeze-Dark
    export QT_STYLE_OVERRIDE=Breeze
    export EWW_ARGS="--force-wayland --config $DACTYL_DIR/config/eww"
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_TYPE=wayland
    export XDG_DATA_DIRS="$DACTYL_DIR/config:${pkgs.xdg-desktop-portal}:${dactylPortalService}/share:$DACTYL_DIR/config/xdg-desktop-portal-dactyl:$XDG_DATA_DIRS"
    # IMPORTANT: xdg-desktop-portal worn't check XDG_DATA_DIRS if XDG_DESKTOP_PORTAL_DIR is set
    unset XDG_DESKTOP_PORTAL_DIR
    dbus-run-session ${runSway}/bin/run-sway
  '';
}

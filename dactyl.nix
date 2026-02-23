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
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Nothing for now
  ];
#XDG_CURRENT_DESKTOP= XDG_SESSION_TYPE=tty
#
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
  ];

  shellHook = ''
    export QT_QPA_PLATFORMTHEME=kde
    export GTK_THEME=Breeze-Dark
    export QT_STYLE_OVERRIDE=Breeze
    export EWW_ARGS="--force-wayland --config $DACTYL_DIR/config/eww"
    sway --config $DACTYL_DIR/config/sway.conf
  '';
}

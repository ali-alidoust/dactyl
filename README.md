# Dactyl

## Installation
1. Clone this repository
  ```bash
  git clone https://github.com/ali-alidoust/dactyl.git
  ```
  
1. Install nix:

  ```bash
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
  ```

1. Make sure nix daemon starts automatically:

  ```bash
  sudo systemctl enable nix-daemon
  ```

1. Install nixGL:

  ```bash
  nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl && nix-channel --update
  nix-env -iA nixgl.auto.nixGLDefault
  ```

1. Add `dactyl.sh` as a non-steam game.

1. Close Steam completely.

1. Copy `config/steam_input/controller_neptune.vdf` to the following location (create `Dactyl` directory if needed):
```
/home/deck/.local/share/Steam/steamapps/common/Steam Controller Configs/<your-user-id>/config/Dactyl/controller_neptune.vdf
```
1. Start steam

1. Go to game mode and start Dactyl

1. Hold Options button to see key bindings.
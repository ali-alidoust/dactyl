# Dactyl

## Installation
1. Install nix:

  ```bash
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
  ```

2. Make sure nix daemon starts automatically:

  ```bash
  sudo systemctl enable nix-daemon
  ```

3. Install nixGL:

  ```bash
  nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl && nix-channel --update
  nix-env -iA nixgl.auto.nixGLDefault
  ```

4. Add `dactyl.sh` as a non-steam game.

5. Close Steam completely.

6. Copy `config/steam_input/controller_neptune.vdf` to the following location (create `Dactyl` directory if needed):
```
/home/deck/.local/share/Steam/steamapps/common/Steam Controller Configs/<your-user-id>/config/Dactyl/controller_neptune.vdf
```
7. Start steam

8. Go to game mode and start Dactyl

9. Hold Options button to see key bindings.
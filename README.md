# Dactyl

## Installation
1. Clone this repository
  ```bash
  git clone https://github.com/ali-alidoust/dactyl.git
  ```
2. Install nix:

  ```bash
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
  ```

3. Make sure nix daemon starts automatically:

  ```bash
  sudo systemctl enable nix-daemon.socket
  echo "deck ALL=(ALL) NOPASSWD: /usr/bin/systemctl start nix-daemon.socket" | sudo tee /etc/sudoers.d/zz-nix-startup
  ```

4. Install nixGL:

  ```bash
  nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl && nix-channel --update
  nix-env -iA nixgl.auto.nixGLDefault
  ```

5. Add `dactyl.sh` as a non-steam game.

6. Close Steam completely.

7. Copy `config/steam_input/controller_neptune.vdf` to the following location (create `Dactyl` directory if needed):
```
/home/deck/.local/share/Steam/steamapps/common/Steam Controller Configs/<your-user-id>/config/Dactyl/controller_neptune.vdf
```
8. Start steam

9. Go to game mode and start Dactyl

10. Hold Options button to see key bindings.
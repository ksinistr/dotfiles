# Dotfiles

Home Manager config and Make targets for Debian and macOS. `make` (or `make help`) prints the install order in short.

## Layers

Everything installs bottom-up; each layer needs the one below it. Which package goes where: [AGENTS.md](AGENTS.md).

| Layer | What | Command |
|---|---|---|
| 1. OS | compilers, runtimes, native libraries, apps | `make debian` / `make macos-brew` |
| 2. Home Manager | configs, CLI tools, `uv`, `fnm`, PATH | `make nix-linux` / `make nix-macos` |
| 3. Toolchains | Rust, Node, Python/Go tools | `make toolchains` |

Layer 3 needs a new zsh session after layer 2: Home Manager sets PATH and environment only when a shell starts. On Debian the login shell is bash, so open kitty (it starts zsh) or run `zsh -l`.

## Fresh install

### Debian

1. As root (`su -`): `apt-get install -y sudo git make curl && usermod -aG sudo anasyrov`, then log out and back in.
2. `git clone https://github.com/ksinistr/dotfiles.git ~/dotfiles && cd ~/dotfiles`
3. `make debian`: APT packages, Flatpak apps, Crystal, Go. Optionally `make debian-keyd`; on a ThinkPad T480 `make debian-t480-tlp`.
4. Install kitty following the official guide, including its desktop integration step: https://sw.kovidgoyal.net/kitty/binary/. Ghostty comes from a `.deb` installed by hand.
5. Install Nix: `sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon`, then open a new terminal.
6. `make nix-linux`
7. Log out and back in, open kitty.
8. `make toolchains`
9. Open `nvim` and let Mason install the language servers.
10. Optionally `make claude codex ghostty vim`.

### macOS

1. `xcode-select --install`
2. Install Homebrew (https://brew.sh) and add `eval "$(/opt/homebrew/bin/brew shellenv)"` to `~/.zprofile`.
3. `git clone https://github.com/ksinistr/dotfiles.git ~/dotfiles && cd ~/dotfiles`
4. `make macos-brew`
5. Install kitty following the official guide: https://sw.kovidgoyal.net/kitty/binary/
6. Install Nix: `sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)`, then open a new terminal.
7. `make nix-macos`
8. Open a new terminal window.
9. `make toolchains`
10. Open `nvim` and let Mason install the language servers.
11. Optionally `make claude codex ghostty vim`.

## Migrating a machine that had toolchains in Nix

One-off; delete this section, and its block in `make help`, once both machines are migrated. Native versions go in first, while the Nix ones still work; toolchains go last, from a fresh shell.

### Debian

1. `make debian-apt debian-crystal debian-go`
2. `make nix-linux`
3. Open a new kitty window. `echo $GOROOT` must print nothing and `which go` must show `/usr/local/go/bin/go`; otherwise log out and back in.
4. `make toolchains`
5. Open `nvim` and let Mason install pylsp.

### macOS

1. `make macos-brew-diff` compares the `Brewfile` with what is installed (`macos-brew-missing` and `macos-brew-extra` run each half). It only lists; `brew bundle cleanup --force --file=Brewfile` removes the extras. Delete the lines you don't want, add what you keep.
2. `make macos-brew`
3. `make nix-macos`
4. Close every terminal window and IDE: they keep `GOROOT` from the Nix Go and break the Homebrew one. Open a new terminal window. `echo $GOROOT` must print nothing and `which go python3.13` must point into `/opt/homebrew/bin`.
5. `make toolchains`
6. Open `nvim` and let Mason install pylsp.

### Both

- `sort -u -o ~/.config/nix/nix.conf ~/.config/nix/nix.conf`: the old `make nix` appended a duplicate line on every run.
- Drop `export PATH="$HOME/.cargo/bin:$PATH"` from `~/.zprofile` if it is there: `home.nix` sets it now.
- Python libraries that used to come from Nix (matplotlib, pillow, pymupdf, pytesseract) belong in project environments now: `uv add …`.

## Inspiration

- https://github.com/mokevnin/dotfiles
- https://github.com/ibhagwan/nvim-lua
- https://github.com/bushblade/nvim

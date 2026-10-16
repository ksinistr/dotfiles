.DEFAULT_GOAL := help

define HELP
Install order: OS layer -> Home Manager -> new zsh shell -> toolchains.
Details and manual steps: README.md

Fresh Debian
  1. as root: apt-get install -y sudo git make curl && usermod -aG sudo anasyrov; re-login
  2. make debian                        APT, gh, Flatpak, Crystal, Go
  3. kitty: https://sw.kovidgoyal.net/kitty/binary/
  4. Nix:   sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
  5. make nix-linux                     Home Manager
  6. re-login, open kitty               zsh picks up the new PATH
  7. make toolchains                    Rust, Node, Python/Go tools
  8. nvim                               Mason installs language servers

Fresh macOS
  1. xcode-select --install; Homebrew: https://brew.sh
  2. make macos-brew                    Brewfile
  3. kitty: https://sw.kovidgoyal.net/kitty/binary/
  4. Nix:   sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
  5. make nix-macos                     Home Manager
  6. new terminal window
  7. make toolchains
  8. nvim

Migrating a machine that had toolchains in Nix (one-off)
  Debian: make debian-apt debian-gh debian-crystal debian-go
          make nix-linux, new kitty window, make toolchains
  macOS:  make macos-brew-diff, fix Brewfile, make macos-brew
          make nix-macos, new terminal window, make toolchains

Optional: make claude codex ghostty vim debian-keyd debian-kmscon debian-zsh-login-shell debian-t480-tlp
endef
export HELP

.PHONY: help
help:
	@printf '%s\n' "$$HELP"

.PHONY: vim
vim:
	ln -sf $(PWD)/.vimrc ~/.vimrc

.PHONY: ghostty
ghostty:
	mkdir -p ~/.config/ghostty
	ln -sf $(PWD)/ghostty/config ~/.config/ghostty/config

.PHONY: debian-sudo
debian-sudo:
	echo "su -"
	echo "usermod -aG sudo anasyrov"
	echo "reboot"

# keyd config that make Meta+C like in macos
.PHONY: debian-keyd
debian-keyd:
	sudo mkdir -p /etc/keyd
	sudo cp $(PWD)/keyd/default.conf /etc/keyd/default.conf
	sudo apt-get install -y keyd
	sudo systemctl enable keyd
	sudo systemctl restart keyd

# Nerd Fonts are not packaged for Debian; system-wide copy from the release tarball (same version as nixpkgs).
# For root services like kmscon, which don't see Home Manager fonts.
NERD_FONTS_VERSION ?= 3.4.0
.PHONY: debian-nerd-fonts
debian-nerd-fonts:
	curl -fsSLo /tmp/IosevkaTerm.tar.xz "https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONTS_VERSION)/IosevkaTerm.tar.xz"
	sudo rm -rf /usr/local/share/fonts/IosevkaTerm
	sudo mkdir -p /usr/local/share/fonts/IosevkaTerm
	sudo tar -C /usr/local/share/fonts/IosevkaTerm -xJf /tmp/IosevkaTerm.tar.xz --wildcards 'IosevkaTermNerdFontMono-*.ttf'
	rm /tmp/IosevkaTerm.tar.xz
	sudo fc-cache -f /usr/local/share/fonts

# kmscon replaces getty on the text console: TTF fonts via fontconfig (IosevkaTerm Nerd Font Mono).
.PHONY: debian-kmscon
debian-kmscon: debian-nerd-fonts
	sudo apt-get install -y extrepo
	sudo extrepo enable debian_backports
	sudo apt-get update
	sudo apt-get install -y -t $$(. /etc/os-release && echo $$VERSION_CODENAME)-backports kmscon
	sudo mkdir -p /etc/kmscon
	sudo cp $(PWD)/kmscon/kmscon.conf /etc/kmscon/kmscon.conf
	sudo ln -sf /usr/lib/systemd/system/kmsconvt@.service /etc/systemd/system/autovt@.service
	sudo systemctl enable kmsconvt@tty1
	@echo "Apply with: sudo systemctl restart kmsconvt@tty1 (ends the tty1 session)"

# Home Manager zsh as login shell (login(1) from kmscon/getty/ssh starts it). Run after make nix-linux.
# The ~/.nix-profile symlink survives HM switches and GC, unlike a /nix/store path.
# Recovery if Nix breaks: log in as root on another VT, chsh -s /bin/bash anasyrov
ZSH_LOGIN_SHELL := $(HOME)/.nix-profile/bin/zsh
.PHONY: debian-zsh-login-shell
debian-zsh-login-shell:
	test -x $(ZSH_LOGIN_SHELL)
	grep -qxF $(ZSH_LOGIN_SHELL) /etc/shells || echo $(ZSH_LOGIN_SHELL) | sudo tee -a /etc/shells
	[ "$$(getent passwd $$(id -un) | cut -d: -f7)" = $(ZSH_LOGIN_SHELL) ] || chsh -s $(ZSH_LOGIN_SHELL)
	@echo "Applies on next login"

# TLP saves more power than KDE's power-profiles-daemon on T480: ppd only tunes CPU EPP there,
# TLP also powers down PCIe, USB, NVMe, Wi-Fi and audio. apt removes power-profiles-daemon (conflict).
.PHONY: debian-t480-tlp
debian-t480-tlp:
	sudo apt-get install -y tlp tlp-rdw
	sudo systemctl enable --now tlp

.PHONY: debian-apt
debian-apt:
	sudo apt-get update && sudo apt-get install -y \
		curl \
		keyd \
		alacritty \
		transmission \
		vlc \
		keepassxc \
		libsecret-tools \
		calibre \
		firefox-esr \
		chromium \
		flatpak \
		build-essential \
		pkg-config \
		libsystemd-dev \
		libglib2.0-dev \
		libgtk-3-dev \
		libsoup-3.0-dev \
		libwebkit2gtk-4.1-dev \
		libpcre2-dev \
		libffi-dev \
		libfontconfig1-dev \
		libxcb1-dev \
		libxkbcommon-dev \
		libxkbcommon-x11-dev \
		libwayland-dev \
		libx11-xcb-dev \
		libxau-dev \
		libxdmcp-dev \
		zlib1g-dev \
		libgmp-dev \
		libssl-dev \
		libyaml-dev \
		cmake \
		ninja-build \
		python3 \
		python3-venv \
		python3-dev \
		python3-tk \
		tesseract-ocr \
		ghostscript \
		erlang-nox \
		rebar3 \
		rustup \
		plasma-discover-backend-flatpak

.PHONY: debian-gh
debian-gh:
	sudo mkdir -p -m 755 /etc/apt/keyrings
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
	sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
	sudo apt-get update && sudo apt-get install -y gh

.PHONY: debian-crystal
debian-crystal:
	curl -fsSL https://crystal-lang.org/install.sh | sudo bash
	mkdir -p ~/.local/bin
	curl -fsSL https://github.com/elbywan/crystalline/releases/latest/download/crystalline_x86_64-unknown-linux-musl.gz | gunzip > ~/.local/bin/crystalline
	chmod +x ~/.local/bin/crystalline

GO_VERSION ?= 1.25.9

.PHONY: debian-go
debian-go:
	curl -fsSLo /tmp/go$(GO_VERSION).tar.gz "https://go.dev/dl/go$(GO_VERSION).linux-$$(dpkg --print-architecture).tar.gz"
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf /tmp/go$(GO_VERSION).tar.gz
	rm /tmp/go$(GO_VERSION).tar.gz

.PHONY: debian-flatpak
debian-flatpak:
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
	flatpak install -y flathub \
		org.telegram.desktop \
		io.dbeaver.DBeaverCommunity \
		com.getpostman.Postman

RUST_TOOLCHAIN ?= 1.95.0

.PHONY: rust-toolchain
rust-toolchain:
	rustup toolchain install $(RUST_TOOLCHAIN)
	rustup default $(RUST_TOOLCHAIN)
	rustup target add --toolchain $(RUST_TOOLCHAIN) thumbv6m-none-eabi

NODE_VERSION ?= 24

.PHONY: node
node:
	command -v fnm >/dev/null || { echo "fnm is required"; exit 1; }
	fnm install $(NODE_VERSION)
	fnm default $(NODE_VERSION)

.PHONY: python-tools
python-tools:
	command -v uv >/dev/null || { echo "uv is required"; exit 1; }
	uv tool install --upgrade ruff
	uv tool install --upgrade llm --with llm-anthropic
	[ "$$(uname)" != Darwin ] || PIP_REQUIRE_VIRTUALENV=0 /usr/bin/python3 -m pip install --user --upgrade pyyaml

.PHONY: go-tools
go-tools:
	command -v go >/dev/null || { echo "go is required"; exit 1; }
	go install golang.org/x/tools/gopls@latest
	go install mvdan.cc/gofumpt@latest
	go install github.com/daixiang0/gci@latest
	go install github.com/segmentio/golines@latest
	go install github.com/google/yamlfmt/cmd/yamlfmt@latest
	go install github.com/nametake/golangci-lint-langserver@latest
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest

.PHONY: toolchains
toolchains: rust-toolchain node python-tools go-tools

.PHONY: debian
debian: debian-sudo debian-apt debian-gh debian-flatpak debian-crystal debian-go

.PHONY: macos-brew
macos-brew:
	brew bundle --file=$(PWD)/Brewfile

.PHONY: macos-brew-missing
macos-brew-missing:
	@echo "== In Brewfile, not installed:"
	brew bundle check --verbose --file=$(PWD)/Brewfile || true

.PHONY: macos-brew-extra
macos-brew-extra:
	@echo "== Installed, not in Brewfile (dry run, nothing is removed):"
	brew bundle cleanup --file=$(PWD)/Brewfile </dev/null || true

.PHONY: macos-brew-diff
macos-brew-diff: macos-brew-missing macos-brew-extra

# Multi-user Nix install (nix-daemon via systemd); skipped if nix is already installed
.PHONY: debian-nix-install
debian-nix-install:
	@if [ -x /nix/var/nix/profiles/default/bin/nix ]; then \
		echo "nix is already installed"; \
	else \
		sudo apt-get install -y curl xz-utils && \
		curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes; \
	fi
	@echo "Open a new shell (or: . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh), then run: make nix-linux"

.PHONY: nix
nix:
	mkdir -p ~/.config/nix/
	grep -qsx "experimental-features = nix-command flakes" ~/.config/nix/nix.conf || echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

.PHONY: nix-linux
nix-linux: nix
	nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#artur-linux

.PHONY: nix-macos
nix-macos: nix
	nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#artur-macos

.PHONY: claude
claude:
	command -v jq >/dev/null || { echo "jq is required"; exit 1; }
	mkdir -p ~/.claude/hooks
	for f in $(PWD)/claude/hooks/*; do ln -sf "$$f" ~/.claude/hooks/; done
	[ -f ~/.claude/settings.json ] || echo '{}' > ~/.claude/settings.json
	cp ~/.claude/settings.json ~/.claude/settings.json.bak
	ln -sf $(PWD)/claude/statusline-command.sh ~/.claude/statusline-command.sh
	jq -s '.[0] + .[1]' ~/.claude/settings.json.bak $(PWD)/claude/settings.json > ~/.claude/settings.json

CODEX_DIR ?= $(if $(CODEX_HOME),$(CODEX_HOME),$(HOME)/.codex)

.PHONY: codex
codex:
	command -v jq >/dev/null || { echo "jq is required"; exit 1; }
	command -v codex >/dev/null || { echo "codex is required"; exit 1; }
	command -v perl >/dev/null || { echo "perl is required"; exit 1; }
	mkdir -p "$(CODEX_DIR)/hooks"
	for f in "$(PWD)"/codex/hooks/*.sh; do ln -sf "$$f" "$(CODEX_DIR)/hooks/"; done
	[ -f "$(CODEX_DIR)/hooks.json" ] || echo '{}' > "$(CODEX_DIR)/hooks.json"
	cp "$(CODEX_DIR)/hooks.json" "$(CODEX_DIR)/hooks.json.bak"
	jq -s '.[0] * .[1]' "$(CODEX_DIR)/hooks.json.bak" "$(PWD)/codex/hooks.json" > "$(CODEX_DIR)/hooks.json"

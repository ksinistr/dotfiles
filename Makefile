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

.PHONY: debian-apt
debian-apt:
	sudo apt-get update && sudo apt-get install -y \
		curl \
		keyd \
		alacritty \
		transmission \
		vlc \
		keepassxc \
		calibre \
		firefox-esr \
		chromium \
		flatpak \
		plasma-discover-backend-flatpak 

.PHONY: debian-flatpak
debian-flatpak:
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
	flatpak install -y flathub \
		org.telegram.desktop \
		io.dbeaver.DBeaverCommunity \
		com.getpostman.Postman

.PHONY: debian
debian: debian-sudo debian-apt debian-flatpak

.PHONE: nix
nix:
	mkdir -p ~/.config/nix/
	echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

.PHONY: nix-linux
nix-linux: nix
	nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#artur-linux

.PHONY: nix-macos
nix-macos: nix
	nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#artur-macos

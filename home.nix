{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}:

let
  user = "anasyrov";
  homeDir = "/home/${user}";
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
  terminalFontName = "IosevkaTerm Nerd Font Mono";
  terminalFontSize = if pkgs.stdenv.isLinux then 14.0 else 16.0;
  zshShell = "${pkgs.zsh}/bin/zsh";
  zshLoginShell = "${zshShell} --login";

  # Overlay for custom Go packages
  go-overlay = self: super: {
    go_1_25 = unstablePkgs.go_1_25;
    golangci-lint =
      let
        version = "2.5.0";
        platform =
          if super.stdenv.hostPlatform.system == "aarch64-darwin" then "darwin-arm64"
          else if super.stdenv.hostPlatform.system == "x86_64-darwin" then "darwin-amd64"
          else if super.stdenv.hostPlatform.system == "aarch64-linux" then "linux-arm64"
          else "linux-amd64";
        hashes = {
          "darwin-arm64" = "sha256-Czy9wqJHL2C1OOvMsbLhrl2TigUcAQWRqmjG79NwZnI=";
          "darwin-amd64" = "sha256-p+aEhysAY31kLQiN3ng8G4cRYakmePzxPQer5rXDLjY=";
          "linux-arm64"  = "sha256-SGk6mKf0VW0RFzAKriQND+SD341vNt+rpWUEYmEBpm4=";
          "linux-amd64"  = "sha256-x3MTp34ZsGEjlixBHZlDzA0JK77Ha5VhBNGJZOJ0kC4=";
        };
      in
      super.stdenv.mkDerivation {
        pname = "golangci-lint";
        inherit version;
        src = super.fetchurl {
          url = "https://github.com/golangci/golangci-lint/releases/download/v${version}/golangci-lint-${version}-${platform}.tar.gz";
          hash = hashes.${platform};
        };
        sourceRoot = "golangci-lint-${version}-${platform}";
        installPhase = ''
          mkdir -p $out/bin
          cp golangci-lint $out/bin/
        '';
        meta = with super.lib; {
          description = "Fast linters runner for Go";
          homepage = "https://golangci-lint.run/";
          license = licenses.gpl3Only;
        };
      };
  };

  # Apply the overlay
  customPkgs = pkgs.extend go-overlay;
  rustToolchain = pkgs.rust-bin.stable.latest.default;
in
lib.mkMerge [
  {
    # Tie to HM version we started with
    home.stateVersion = "25.05";

    home.username = lib.mkDefault user;
    home.homeDirectory = lib.mkDefault homeDir;

    # Allow proprietary packages (Postman, Chrome, etc.)
    nixpkgs.config.allowUnfree = false;

    programs.home-manager.enable = true;

    ############################################
    # Shell / Zsh
    ############################################
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        vi = "nvim";
        vim = "nvim";
        k = "kubectl";
        l = "eza";
        la = "eza -a";
        ll = "eza -lah";
        ls = "eza --color=auto";
        s = "kitten ssh";
      };

      initContent = ''
        # Ensure .zprofile is always sourced, even in non-login shells
        if [ -f "$HOME/.zprofile" ]; then
          source "$HOME/.zprofile"
        fi

        # Enable zsh-git-prompt
        source ${pkgs.zsh-git-prompt}/share/zsh-git-prompt/zshrc.sh
        ZSH_GIT_PROMPT_FORCE_BLANK=1

        # Set the prompt
        # export PROMPT='%n@%m:%~ $(git_super_status)%# '
        PROMPT='%n@%m:%1~ $(git_super_status)%# '

        # kubectl completion for zsh
        if command -v kubectl >/dev/null 2>&1; then
          source <(kubectl completion zsh)
          alias k=kubectl
          compdef _kubectl k
        fi

        # History
        setopt hist_ignore_all_dups
        setopt hist_save_no_dups
        setopt hist_ignore_dups
        export HISTSIZE=1000000
        export SAVEHIST=1000000
        export HISTTIMEFORMAT="%F %T "

        setopt extended_history          # save timestamp & duration
        setopt inc_append_history        # write as you go
        setopt share_history             # share across sessions
        setopt hist_ignore_all_dups
        setopt hist_save_no_dups
        setopt hist_ignore_dups
        setopt hist_ignore_space         # commands starting with space aren't saved
        setopt hist_reduce_blanks
        setopt hist_verify               # don't auto-execute from history

        # ---------- Small QoL ----------
        setopt auto_cd                   # `..` or a path jumps there
        setopt no_beep
        setopt interactive_comments      # allow comments in interactive shell
        setopt no_nomatch                # wildcards that match nothing don't error

        # Optional: bind Ctrl-Backspace to delete-word (often handy)
        bindkey '^H' backward-kill-word
        bindkey "^A" vi-beginning-of-line
        bindkey "^E" vi-end-of-line

        # llm -s "respond with 3 choices that can be ran directly on command line, no formatting" --save cli
        # llm_cli(){
        #     emulate -L zsh
        #     zle -M "$(uvx --with llm-anthropic llm --key $ANTHROPIC_API_KEY -m claude-3.5-sonnet -t cli $BUFFER)"
        # }
        # zle -N llm_cli
        # bindkey '^[l' llm_cli   # ^[ is ESC, so Meta-l
        export PATH="$HOME/.local/bin:$PATH"
        export PATH="$HOME/.opencode/bin:$PATH"
      '';
    };

    ############################################
    # Global environment variables
    ############################################
    home.sessionVariables = {
      EDITOR = "nvim";
      PAGER = "less -FRX";
      LANG = "en_US.UTF-8";

      PATH = "$PATH:$GOPATH/bin:$GOROOT/bin";
      FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --glob '!.git'";
      KUBECONFIG = "$HOME/.kube/config";
      NPM_CONFIG_PREFIX = npmGlobal;
      NPM_CONFIG_CACHE = "${config.home.homeDirectory}/.npm-cache";
    };

    ############################################
    # Tools and programs
    ############################################
    programs.git = {
      enable = true;
      userName = "Artur Nasyrov";
      userEmail = builtins.getEnv "GIT_AUTHOR_EMAIL";
      extraConfig = {
        init.defaultBranch = "main";
        core.editor = "nvim";
      };
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
      # Plugins can be added through flakes/xdg.configFile, keeping base setup
    };

    programs.worktrunk = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true; # ^R history / ^T files / Alt-C cd
    };

    programs.bat.enable = true;
    programs.eza.enable = true;

    # direnv (if you use it)
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    ############################################
    # User packages (profile)
    ############################################
    home.packages =
      with pkgs;
      [
        # Build tools
        git
        cmake
        unzip
        wget
        gnumake
        ninja
        pkg-config

        # Python (24.05: python311Packages available)
        uv
        python3
        python311Packages.pip
        python311Packages.virtualenv
        python311Packages.pytest
        python311Packages.pynvim
        python311Packages.python-lsp-server
        python311Packages.black
        python311Packages.flake8
        python311Packages.pylint
        python311Packages.llm
        python311Packages.llm-anthropic

        # Node
        nodejs_24
        nodePackages.typescript
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.yaml-language-server
        nodePackages.yarn
        nodePackages.prettier

        # Go and tools (some tools may be missing in 24.05)
        (customPkgs.go_1_25)
        customPkgs.golangci-lint
        (pkgs.golangci-lint-langserver.overrideAttrs { doCheck = false; })
        gopls
        gofumpt
        gci
        golines
        yamlfmt

        # Rust
        rustToolchain
        stylua

        # Dev tools
        protobuf
        kubectl
        kubernetes-helm
        nixfmt-rfc-style
        nil
        openjdk
        plantuml
        graphviz

        # Fonts (nerdfonts option)
        nerd-fonts.iosevka-term

        # Zsh git prompt
        zsh-git-prompt

        k9s
        ripgrep
        mods
        tree-sitter # tree-sitter-cli for nvim-treesitter
      ]
      # ++ [ unstablePkgs.vectorcode ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        # Only Linux specific (if you want to separate)
        # pipewire — system service, NOT installed in user profile
        # flatpak/gnome-software-plugin-flatpak — better at system level
        gcc
        wl-clipboard # Linux+Wayland
        xclip
      ];

    home.sessionPath = [ "${npmGlobal}/bin" ];

    # do the install with an explicit prefix so it never touches /nix/store
    # home.activation.installClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   mkdir -p "${npmGlobal}"
    #   rm -rf "${npmGlobal}/lib/node_modules/@anthropic-ai/claude-code"
    #   "${pkgs.nodejs}/bin/npm" --userconfig "$HOME/.npmrc" \
    #     --prefix "${npmGlobal}" -g install @anthropic-ai/claude-code
    # '';

    ############################################
    # Configs (XDG)
    ############################################
    xdg.enable = true;
    xdg.configFile = {
      # Your Neovim config, if stored next to the flake
      "nvim".source = ./nvim;
      # Example: alacritty.yml, if not using HM module for alacritty
      # Manage alacritty config via xdg.configFile to avoid conflicts
      "kitty/kitty.conf".text = ''
        font_family family="${terminalFontName}"
        font_size ${toString terminalFontSize}
        paste_actions no-op
        background_opacity 1.0
        confirm_os_window_close 0
        copy_on_select clipboard
        enable_audio_bell no
        shell ${zshLoginShell}
        tab_bar_edge top
        tab_bar_min_tabs 1
        tab_bar_style slant
        window_padding_width 5
        map ctrl+shift+c copy_to_clipboard
        map ctrl+shift+v paste_from_clipboard
        map super+c copy_to_clipboard
        map super+v paste_from_clipboard
        include current-theme.conf
      '' + lib.optionalString pkgs.stdenv.isLinux ''
        map ctrl+insert copy_to_clipboard
        map shift+insert paste_from_clipboard
      '';
      "kitty/current-theme.conf".source = ./kitty/current-theme.conf;
      "alacritty/alacritty.toml".source = (pkgs.formats.toml { }).generate "alacritty.toml" {
        env = {
          TERM = "xterm-256color";
          WINIT_UNIX_BACKEND = "wayland"; # Force Wayland backend if available
        };
        keyboard = {
          bindings = [
              # macOS-like (Super mapped by keyd to send Insert variants)
              { key = "Insert"; mods = "Control"; action = "Copy"; }   # Super+C (keyd -> Ctrl+Insert)
              { key = "Insert"; mods = "Shift";   action = "Paste"; }  # Super+V (keyd -> Shift+Insert) use CLIPBOARD now
              # Optional: keep legacy PRIMARY access
              { key = "Y";      mods = "Control|Shift"; action = "PasteSelection"; } # Explicit primary if needed
              # Standard terminal shortcuts (still available)
              { key = "C"; mods = "Control|Shift"; action = "Copy"; }
              { key = "V"; mods = "Control|Shift"; action = "Paste"; }
              # (Super variants directly, if you also press them without keyd translation)
              { key = "C"; mods = "Super"; action = "Copy"; }
              { key = "V"; mods = "Super"; action = "Paste"; }
          ];
        };
        terminal = {
          shell = {
            program = zshShell;
            args = [ "-l" ];
          };
        };
        selection = {
          save_to_clipboard = true;
        };
        window = {
          opacity = 1.0;
          padding = {
            x = 5;
            y = 5;
          };
          dynamic_padding = true;
          startup_mode = "Windowed";
          decorations = "Full";
          resize_increments = true;
        };
        font = {
          size = terminalFontSize;
          bold = {
            family = terminalFontName;
            style = "Bold";
          };
          normal = {
            family = terminalFontName;
            style = "Regular";
          };
        };
      };
    };
  }

  # Linux specific:
  (lib.mkIf pkgs.stdenv.isLinux {
    fonts.fontconfig.enable = true;

    # example:
    # home.packages = [ pkgs.wl-clipboard ];
    xdg.configFile = {
      "keyd/default.conf".source = ./keyd/default.conf;
      "xdg-terminals.list".text = ''
        kitty.desktop
      '';
      # XKB option: CapsLock becomes Ctrl
      "kxkbrc".text = ''
        [Layout]
        Options=ctrl:nocaps
        ResetOldOptions=true
        LayoutList=us,ru
      '';
      # Key repeat: delay (ms) and rate (chars/sec)
      "kcminputrc".text = ''
        [Keyboard]
        RepeatDelay=250
        RepeatRate=40
      '';
    };

    home.sessionVariables = {
      GOPATH = "${config.home.homeDirectory}/go";
      GOMODCACHE = "${config.home.homeDirectory}/go/pkg/mod";
      GOROOT = "${customPkgs.go_1_25}/share/go";
      GOBIN = "${config.home.homeDirectory}/go/bin";
      GOCACHE = "${config.home.homeDirectory}/.cache/go-build";

      UV_PYTHON = "/usr/bin/python3.13";
      # Optional safety: don't allow pip outside a venv
      PIP_REQUIRE_VIRTUALENV = "1";
      TERMINAL = "kitty";
    };
  })

  # macOS specific:
  (lib.mkIf pkgs.stdenv.isDarwin {
    # example:
    # home.sessionVariables.PATH = "$PATH:/opt/homebrew/bin";
    home.sessionVariables = {
      GOPATH = "$HOME/go";
      GOMODCACHE = "$HOME/Library/Caches/go/mod";
      GOROOT = "${customPkgs.go_1_25}/share/go";
      GOBIN = "$HOME/go/bin";
      GOCACHE = "$HOME/Library/Caches/go-build";
      LD = "/usr/bin/ld";
    };
  })
]

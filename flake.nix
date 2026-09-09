{
  description = "Home Manager configs for Linux (x86_64) and macOS (Apple Silicon) with a shared home.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    worktrunk.url = "github:max-sixty/worktrunk";
  };

  outputs =
    {
      self,
      nixpkgs,
      unstable,
      rust-overlay,
      home-manager,
      worktrunk,
      ...
    }:
    let
      # Overlay to provide a specific version of golangci-lint
      overlay-golangci-lint = final: prev: {
        golangci-lint = prev.buildGoModule {
          pname = "golangci-lint";
          version = "1.64.4";

          src = prev.fetchFromGitHub {
            owner = "golangci";
            repo = "golangci-lint";
            rev = "v${final.golangci-lint.version}";
            # Placeholder hash. The build will fail and give you the correct one.
            hash = "sha256-BrkBIf4WP3COAac/5vre8fHLgDneg5Gm31nNq8sXzEE=";
          };

          # Placeholder vendor hash. The build will fail and give you the correct one.
          vendorHash = "sha256-xUKse9yTAVuysmPwmX4EXdlpg6NYKfT5QB1RgmBQvhk=";

          subPackages = [ "cmd/golangci-lint" ];

          ldflags = [
            "-s"
            "-w"
            "-X main.version=${final.golangci-lint.version}"
            "-X main.commit=${final.golangci-lint.src.rev}"
            "-X main.date=${builtins.substring 0 8 (final.golangci-lint.src.lastModifiedDate or "19700101")}"
          ];

          # Disable CGO for a static build
          env.CGO_ENABLED = 0;

          meta = with prev.lib; {
            description = "Fast linters runner for Go";
            homepage = "https://golangci-lint.run/";
            license = licenses.gpl3Only;
            maintainers = [ ];
          };
        };
      };

      mkHome =
        system: username:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              overlay-golangci-lint
              rust-overlay.overlays.default
            ];
          };
          unstablePkgs = import unstable { inherit system; };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          # Make pkgs2505 available to modules (e.g., to use newer packages)
          extraSpecialArgs = {
            inherit unstablePkgs;
            worktrunk-pkgs = worktrunk.packages.${system};
          };
          modules = [
            worktrunk.homeModules.default
            (
              { ... }:
              {
                programs.neovim = {
                  enable = true;
                  package = unstablePkgs.neovim-unwrapped;
                  viAlias = true;
                  vimAlias = true;
                  withNodeJs = true;
                  withPython3 = true;
                };
              }
            )
            (
              { pkgs, ... }:
              {
                targets.genericLinux.enable = pkgs.stdenv.isLinux;
              }
            )
            ./home.nix
            (
              { config, pkgs, ... }:
              {
                # Set your username and home directory per OS
                home.username = username;
                home.homeDirectory =
                  if system == "aarch64-darwin" then "/Users/${username}" else "/home/${username}";
              }
            )
          ];
        };
    in
    {
      homeConfigurations = {
        # Pick one of these when running `home-manager switch --flake .#<name>`
        artur-linux = mkHome "x86_64-linux" "anasyrov";
        artur-macos = mkHome "aarch64-darwin" "artur.nasyrov";
      };
    };
}

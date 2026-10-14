{
  description = "Home Manager configs for Linux (x86_64) and macOS (Apple Silicon) with a shared home.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-nvim.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    latest.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    worktrunk.url = "github:max-sixty/worktrunk";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-nvim,
      latest,
      home-manager,
      worktrunk,
      ...
    }:
    let
      mkHome =
        system: username:
        let
          pkgs = import nixpkgs { inherit system; };
          nvimPkgs = import nixpkgs-nvim { inherit system; };
          latestPkgs = import latest { inherit system; };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          # Make pkgs2505 available to modules (e.g., to use newer packages)
          extraSpecialArgs = {
            inherit latestPkgs;
            worktrunk-pkgs = worktrunk.packages.${system};
          };
          modules = [
            worktrunk.homeModules.default
            (
              { ... }:
              {
                programs.neovim = {
                  enable = true;
                  package = nvimPkgs.neovim-unwrapped;
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

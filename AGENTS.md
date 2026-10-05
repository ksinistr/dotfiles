# Dotfiles Agent Instructions

## Debian System Dependencies

- Install native build tools and system libraries through APT and record recurring packages in the `debian-apt` Make target.
- Use Home Manager for user applications and platform-independent CLI tools. Use `rustup` for Rust toolchains.
- Keep native development libraries out of Nix/Home Manager package lists. Do not create global `PKG_CONFIG_PATH`, `LIBRARY_PATH`, or `LD_LIBRARY_PATH` entries for them.

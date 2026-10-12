# Dotfiles Agent Instructions

## Where packages go

Each package lives in exactly one layer:

- **OS layer**: compilers, interpreters, runtimes, native libraries and headers, GUI apps, and `rustup` itself. On Debian, record APT packages in the `debian-apt` Make target; anything from a third-party repo or tarball gets its own `debian-*` target. On macOS, record them in `Brewfile`, together with tools that need system services or root daemons (colima, docker, podman, telepresence), unfree tools (`allowUnfree = false`, e.g. boundary) and GNU coreutils and grep (Homebrew installs them `g`-prefixed, so they don't shadow the BSD tools).
- **Toolchain managers** (`uv`, `fnm`, `rustup`, `go install`): language versions and language-specific tools, recorded in the `toolchains` and `rust-toolchain` Make targets.
- **Home Manager** (`home.nix`): configs and self-contained CLI tools, including `uv` and `fnm`.

Why: on non-NixOS, Nix-built compilers and interpreters cannot see system libraries, so anything that links against or builds native code belongs to the OS layer. Nix's rustup patches the toolchains it downloads to run against Nix's libraries, so `rustup` stays in the OS layer on both systems. Native libraries resolve through OS defaults; keep `PKG_CONFIG_PATH`, `LIBRARY_PATH` and `LD_LIBRARY_PATH` unset globally.

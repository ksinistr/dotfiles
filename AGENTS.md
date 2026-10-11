# Dotfiles Agent Instructions

## Where packages go

Each package lives in exactly one layer:

- **OS layer**: compilers, interpreters, runtimes, native libraries and headers, GUI apps. On Debian, record APT packages in the `debian-apt` Make target; anything from a third-party repo or tarball gets its own `debian-*` target. On macOS, record them in `Brewfile`.
- **Toolchain managers** (`uv`, `fnm`, `rustup`, `go install`): language versions and language-specific tools, recorded in the `toolchains` and `rust-toolchain` Make targets.
- **Home Manager** (`home.nix`): configs and self-contained CLI tools, including the toolchain managers themselves.

Why: on non-NixOS, Nix-built compilers and interpreters cannot see system libraries, so anything that links against or builds native code belongs to the OS layer. Native libraries resolve through OS defaults; keep `PKG_CONFIG_PATH`, `LIBRARY_PATH` and `LD_LIBRARY_PATH` unset globally.

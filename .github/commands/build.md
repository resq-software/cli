---
name: build
description: Build the full CLI workspace or a specific binary in release mode.
---

# /build

Build the ResQ CLI workspace.

## Usage

```
/build [binary]
```

## Steps

1. Run `cargo build --workspace --release` (or `cargo build -p <binary> --release` if a binary name is given).
2. Report any compiler warnings as actionable items.
3. Confirm output artifacts in `target/release/`.
4. If build fails, identify root cause and suggest fix — do NOT retry blindly.

## Examples

```
/build               # build all 9 binaries
/build resq-tui      # build only the TUI binary
```

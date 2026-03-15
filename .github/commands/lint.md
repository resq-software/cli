---
name: lint
description: Run Clippy with strict settings and rustfmt check across the full workspace.
---

# /lint

Lint and format-check the ResQ CLI workspace.

## Steps

1. Run `cargo clippy --workspace --all-targets -- -D warnings`.
2. Run `cargo fmt --all -- --check`.
3. Report all warnings and errors with file:line and suggested fix.
4. Do NOT auto-apply fixes without user confirmation — show the diff first.

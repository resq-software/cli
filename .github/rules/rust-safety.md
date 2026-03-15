---
name: rust-safety
description: Rust safety and correctness rules for the ResQ CLI workspace. Applied to all Rust source files.
---

# Rust Safety Rules

## Error Handling

- Never use `.unwrap()` or `.expect()` in non-test code unless the invariant is proven and documented with a comment.
- All fallible operations must propagate errors via `?` or handle them explicitly.
- Use `thiserror` for library-style errors, `anyhow` for binary-entry-point errors.

## Async

- Never call blocking I/O (`std::fs`, `std::net`, `std::thread::sleep`) in an async context. Use `tokio::fs`, `tokio::time`, etc.
- Never hold a `std::sync::Mutex` guard across an `.await` point. Use `tokio::sync::Mutex` when needed.
- Spawn background tasks with `tokio::spawn` — always capture the `JoinHandle` and await it on shutdown.

## Security

- Never log, print, or include API keys/tokens in error messages.
- Validate and canonicalize all user-supplied file paths before use.
- Never pass user-supplied strings directly to `Command::arg` without shell-escaping or validation.
- `reqwest::ClientBuilder` must not call `.danger_accept_invalid_certs(true)` in production.

## Code Style

- All public API items must have `///` doc comments.
- Prefer `PathBuf` over `String` for filesystem paths.
- Prefer `Vec<u8>` over `String` for binary data.
- Use `clap` derive macros — no manual `App::new()` construction.
- Keep individual binary `main.rs` files thin — business logic lives in library crates.

## Releases

- All release builds go through `cargo audit` before publication.
- Cross-compilation to `x86_64-unknown-linux-musl` must succeed for the `resq` binary.
- Semantic versioning via `release-plz` — no manual version bumps in `Cargo.toml`.

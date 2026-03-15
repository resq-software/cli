---
name: testing
description: Testing rules for the ResQ CLI workspace.
---

# Testing Rules

## Structure

- Unit tests live in `#[cfg(test)]` modules within the source file they test.
- Integration tests live in `tests/` at the crate root.
- Use `cargo-nextest` as the test runner — CI uses `cargo nextest run`.

## Mocking

- Mock HTTP calls with `wiremock` — never make real network calls in tests.
- Mock filesystem with `tempfile::TempDir` — never write to real user directories in tests.
- Use `std::env::set_var` sparingly and only in tests that are `#[serial]` (via `serial_test` crate) to avoid env-var pollution.

## Coverage

- New commands and subcommands must have at least one integration test covering the happy path.
- Error paths (invalid args, network failure, missing config) must have unit tests.

## CI

- `cargo nextest run --workspace` must pass before any PR merges.
- `cargo clippy --workspace --all-targets -- -D warnings` must pass.
- `cargo fmt --all -- --check` must pass.

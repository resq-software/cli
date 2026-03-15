---
name: test
description: Run the full test suite with cargo-nextest, or a specific test filter.
---

# /test

Run tests for the ResQ CLI workspace.

## Usage

```
/test [filter]
```

## Steps

1. Run `cargo nextest run --workspace` (or `cargo nextest run -E 'test(~<filter>)'` if a filter is given).
2. Report failures with file, test name, and failure reason.
3. On `cargo-nextest` not found, fall back to `cargo test --workspace` and note the degraded experience.
4. If a test fails due to a missing environment variable (e.g. `RESQ_API_KEY`), note it clearly — do NOT treat it as a code bug.

## Examples

```
/test                  # run all tests
/test deploy           # run tests matching "deploy"
```

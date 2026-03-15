---
name: audit
description: Run cargo audit to check for known vulnerabilities in dependencies.
---

# /audit

Run supply-chain security audit for the ResQ CLI workspace.

## Steps

1. Run `cargo audit`.
2. For each advisory found, report: crate, version, advisory ID, severity, and recommended action.
3. If `cargo-audit` is not installed, run `cargo install cargo-audit --locked` first.
4. Flag any CRITICAL or HIGH advisories as blocking — they must be resolved before release.

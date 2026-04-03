# ResQ CLI — Monorepo Agent Guide

## Mission
Developer tooling for the ResQ platform. This monorepo contains a suite of CLI and TUI tools for auditing, deployment, performance monitoring, and repository maintenance.

## Workspace Layout
- `resq-dsa/` — Data structures and algorithms library (zero dependencies, `no_std`-compatible).
- `cli/` — The main `resq` CLI tool (entry point).
- `resq-tui/` — Shared component library for all TUI tools.
- `bin-explorer/` — Machine code and binary analyzer (`resq-bin`).
- `cleanup/` — Workspace cleaner (`resq-clean`).
- `deploy-cli/` — Environment manager (`resq-deploy`).
- `flame-graph/` — CPU profiler (`resq-flame`).
- `health-checker/` — Service health monitor (`resq-health`).
- `log-viewer/` — Log aggregator (`resq-logs`).
- `perf-monitor/` — Performance dashboard (`resq-perf`).

## Shared Standards
- **Runtime**: Rust (latest stable).
- **UI Architecture**: Ratatui with a shared `resq-tui` theme and header/footer components.
- **CLI Framework**: Clap v4 (derive mode).
- **Safety**: Tools must be read-only by default (except `cleanup` and `copyright`).
- **Sync**: Always keep `AGENTS.md` and `CLAUDE.md` in sync using `./agent-sync.sh`.

## Global Commands
```bash
cargo build                  # Build all tools
cargo test                   # Run all tests
./agent-sync.sh --check      # Verify all agent guides are in sync
```

## Repository Rules
- Do not commit `target/` or generated binaries.
- All new source files must include the Apache-2.0 license header (managed by `resq copyright`).
- Keep binary names consistent: `resq-<name>`.

## References
- [Root README](README.md)
- [Individual Crate READMEs](cli/README.md, resq-tui/README.md, etc.)

<!--
  Copyright 2026 ResQ

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

<h1 align="center">resq CLI</h1>

<p align="center">
  Developer and operations tooling for the ResQ autonomous drone platform — a unified CLI and suite of TUI tools.
</p>

<p align="center">
  <a href="https://github.com/resq-software/cli/actions/workflows/ci.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/resq-software/cli/ci.yml?branch=main&label=ci&style=flat-square" alt="CI" />
  </a>
  <a href="https://crates.io/crates/resq-cli">
    <img src="https://img.shields.io/crates/v/resq-cli?style=flat-square" alt="crates.io" />
  </a>
  <a href="https://codecov.io/gh/resq-software/cli">
    <img src="https://codecov.io/gh/resq-software/cli/graph/badge.svg" alt="Coverage" />
  </a>
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/license-Apache--2.0-blue.svg?style=flat-square" alt="License: Apache-2.0" />
  </a>
</p>

---

## Table of Contents

- [Overview](#overview)
- [Tools](#tools)
- [Install](#install)
- [Quick Start](#quick-start)
- [Commands](#commands)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

---

## Overview

`resq` is a Rust workspace of developer-facing CLI and TUI tools for the [ResQ platform](https://resq.software). It automates the workflows that slow teams down: copyright enforcement, secret scanning, health diagnostics, performance profiling, structured log viewing, and deployment orchestration — all from a single entry point.

**Related projects:**

| Repo | Description |
|------|-------------|
| [resq-software/resQ](https://github.com/resq-software/resQ) | Core platform monorepo |
| [resq-software/mcp](https://github.com/resq-software/mcp) | MCP server |
| [resq-software/ui](https://github.com/resq-software/ui) | Shared component library |
| [resq-software/dotnet-sdk](https://github.com/resq-software/dotnet-sdk) | .NET SDK |

---

## Tools

| Crate | Binary | Description |
|-------|--------|-------------|
| `resq-cli` | `resq` | Unified entry point — copyright, secrets, audit, versioning, pre-commit TUI |
| `deploy-cli` | `resq-deploy` | Deployment orchestration TUI for Docker Compose and Kubernetes |
| `health-checker` | `resq-health` | Service and dependency health diagnostic dashboard |
| `log-viewer` | `resq-logs` | Multi-source structured log aggregator |
| `perf-monitor` | `resq-perf` | Real-time CPU and memory metrics TUI |
| `flame-graph` | `resq-flame` | SVG CPU flame graph generator for polyglot services |
| `bin-explorer` | `bin_explorer` | Binary and machine-code analyser |
| `cleanup` | `resq-clean` | `.gitignore`-aware workspace cleaner |
| `resq-tui` | `resq-tui` | Shared Ratatui component library used across all tools |

---

## Install

### From crates.io

```sh
cargo install resq-cli
```

### From source

```sh
git clone https://github.com/resq-software/cli.git
cd cli
cargo build --release --workspace
# Binaries land in ./target/release/
```

### Docker

```sh
docker build -t resq-cli .
docker run --rm resq-cli --help
```

### Dev environment (Nix)

```sh
nix develop        # Rust stable, cargo-watch, cargo-nextest, openssl
# or:
./scripts/setup.sh # installs Nix + Docker; configures git hooks
```

---

## Quick Start

```sh
# Check copyright headers across the repo
resq copyright --check

# Scan for leaked secrets
resq secrets

# Run pre-commit checks interactively
resq pre-commit
```

---

## Commands

| Command | Description |
|---------|-------------|
| `resq copyright` | Check and fix copyright headers across the workspace |
| `resq secrets` | Scan for leaked credentials and secrets |
| `resq audit` | Audit blockchain events |
| `resq cost` | Estimate cloud resource costs |
| `resq lqip` | Generate low-quality image placeholders |
| `resq tree-shake` | Remove unused exports (`tsr` wrapper) |
| `resq dev` | Start the development server |
| `resq pre-commit` | Run pre-commit checks (TUI) |
| `resq version` | Manage versions and changesets |
| `resq docs` | Export and publish documentation |
| `resq explore` | Launch Perf-Explorer TUI |
| `resq logs` | Launch Log-Explorer TUI |
| `resq health` | Launch Health-Explorer TUI |
| `resq deploy` | Launch Deploy-Explorer TUI |
| `resq clean` | Launch Cleanup-Explorer TUI (`--dry-run` supported) |
| `resq asm` | Launch Asm-Explorer for machine code analysis |

---

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `GIT_HOOKS_SKIP` | unset | Set to any value to bypass pre-commit hooks |
| `RESQ_NIX_RECURSION` | unset | Internal guard preventing infinite re-exec inside `nix develop` |

---

## Contributing

We welcome contributions. Please read [`CONTRIBUTING.md`](./CONTRIBUTING.md) before opening a PR.

**Local setup:**

```sh
git clone https://github.com/resq-software/cli.git
cd cli
./scripts/setup.sh   # installs Nix + Docker; enters nix develop; configures .git-hooks/
```

**Run tests:**

```sh
cargo nextest run
```

**Commit convention:** This project uses [Conventional Commits](https://www.conventionalcommits.org/).
All PRs must follow the `type(scope): subject` format — see the table below.

| Prefix | Effect on version |
|--------|------------------|
| `feat:` | Minor bump (`0.x.0`) |
| `fix:` / `perf:` | Patch bump (`0.0.x`) |
| `BREAKING CHANGE` footer or `!` suffix | Major bump (`x.0.0`) |
| `docs:` `style:` `refactor:` `test:` `chore:` | No version bump |

Releases are automated via [release-plz](https://release-plz.dev) on merge to `main`.

---

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for the full release history.

---

## License

Copyright 2026 ResQ

Licensed under the [Apache License, Version 2.0](./LICENSE).

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

# Rust Workspace Optimization Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the `cli` workspace closer to the Rust ergonomics used in `~/github/wrk/resQ` by adding root Cargo toolchain/config support, normalizing obvious manifest drift, and updating docs to match the resulting workflow.

**Architecture:** The workspace root becomes the source of truth for toolchain selection, cargo aliases, shared dependency versions, and build profiles. Member manifests inherit more from the workspace where the dependency/features are already compatible, while docs are updated to advertise the new root workflow rather than scattered one-off commands.

**Tech Stack:** Rust stable, Cargo workspace configuration, Clap v4, Ratatui, Markdown documentation, GitHub Actions-compatible verification commands.

---

## File Map

- Create: `rust-toolchain.toml`
- Create: `.cargo/config.toml`
- Modify: `Cargo.toml`
- Modify: `README.md`
- Modify: `cli/README.md`
- Modify: `resq-tui/Cargo.toml`
- Modify: `cli/Cargo.toml`
- Modify: `cleanup/Cargo.toml`
- Modify: `bin-explorer/Cargo.toml`
- Modify: `health-checker/Cargo.toml`
- Modify: `log-viewer/Cargo.toml`
- Modify: `perf-monitor/Cargo.toml`
- Modify: `flame-graph/Cargo.toml`
- Modify: `deploy-cli/Cargo.toml`
- Reference spec: `docs/superpowers/specs/2026-03-17-rust-workspace-optimization-design.md`

## Chunk 1: Root Rust Ergonomics

### Task 1: Add a pinned Rust toolchain file

**Files:**
- Create: `rust-toolchain.toml`

- [ ] **Step 1: Verify the repo currently has no pinned toolchain**

Run: `test -f rust-toolchain.toml`
Expected: non-zero exit status

- [ ] **Step 2: Create `rust-toolchain.toml` with stable + required components**

```toml
[toolchain]
channel = "stable"
components = ["rustfmt", "clippy"]
```

- [ ] **Step 3: Verify the file exists and is parseable**

Run: `sed -n '1,40p' rust-toolchain.toml`
Expected: the `[toolchain]` table with `stable`, `rustfmt`, and `clippy`

- [ ] **Step 4: Commit**

```bash
git add rust-toolchain.toml
git commit -m "build: pin rust toolchain"
```

### Task 2: Add workspace Cargo aliases and developer defaults

**Files:**
- Create: `.cargo/config.toml`

- [ ] **Step 1: Prove the alias set does not exist yet**

Run: `cargo check-all`
Expected: FAIL with `no such command: check-all`

- [ ] **Step 2: Create `.cargo/config.toml` with focused aliases**

```toml
[alias]
t = "test --workspace"
c = "clippy --workspace --all-targets -- -D warnings"
check-all = "check --workspace --all-targets"
resq = "run -p resq-cli --"
health = "run -p resq-health-checker --"
logs = "run -p resq-log-viewer --"
perf = "run -p resq-perf-monitor --"
deploy = "run -p resq-deploy-cli --"
cleanup = "run -p resq-cleanup --"
bin = "run -p resq-bin-explorer --"
flame = "run -p resq-flamegraph --"

[env]
CARGO_TERM_COLOR = "always"
RUST_BACKTRACE = "1"

[term]
progress.when = "always"
progress.width = 100
```

- [ ] **Step 3: Verify the alias file content**

Run: `sed -n '1,200p' .cargo/config.toml`
Expected: alias, env, and term sections match the intended workflow

- [ ] **Step 4: Commit**

```bash
git add .cargo/config.toml
git commit -m "build: add cargo workspace aliases"
```

### Task 3: Add root profiles, a small lint upgrade, and shared internal dependency entries

**Files:**
- Modify: `Cargo.toml`

- [ ] **Step 1: Update root workspace dependency definitions**

Add or adjust the following entries so downstream crates can inherit them safely:

```toml
[workspace.dependencies]
clap = { version = "4.5", features = ["derive", "env"] }
reqwest = { version = "0.13.2", features = ["json", "rustls", "multipart", "stream", "blocking"] }
resq-tui = { path = "resq-tui", version = "0.1.2" }
```

- [ ] **Step 2: Add the missing workspace lint and build profiles**

```toml
[workspace.lints.rust]
missing_docs = "warn"
unsafe_code = "forbid"
unreachable_pub = "warn"

[profile.dev]
opt-level = 1

[profile.dev.package."*"]
opt-level = 3

[profile.release]
lto = true
codegen-units = 1
strip = true
```

- [ ] **Step 3: Run a workspace parse/build smoke test**

Run: `cargo check --workspace`
Expected: PASS with no manifest parsing errors

- [ ] **Step 4: Commit**

```bash
git add Cargo.toml
git commit -m "build: add workspace cargo profiles and shared deps"
```

## Chunk 2: Manifest Normalization

### Task 4: Normalize internal `resq-tui` dependency usage across workspace crates

**Files:**
- Modify: `cli/Cargo.toml`
- Modify: `cleanup/Cargo.toml`
- Modify: `bin-explorer/Cargo.toml`
- Modify: `health-checker/Cargo.toml`
- Modify: `log-viewer/Cargo.toml`
- Modify: `perf-monitor/Cargo.toml`
- Modify: `flame-graph/Cargo.toml`
- Modify: `deploy-cli/Cargo.toml`

- [ ] **Step 1: Confirm the current workspace mixes `resq-tui` version styles**

Run: `rg -n 'resq-tui = ' -g 'Cargo.toml' .`
Expected: a mix of `version = "0.1"` and `version = "0.1.2"`

- [ ] **Step 2: Replace each local `resq-tui` path dependency with workspace inheritance**

Use:

```toml
resq-tui = { workspace = true }
```

- [ ] **Step 3: Run a workspace check after the internal dependency change**

Run: `cargo check --workspace`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add cli/Cargo.toml cleanup/Cargo.toml bin-explorer/Cargo.toml health-checker/Cargo.toml log-viewer/Cargo.toml perf-monitor/Cargo.toml flame-graph/Cargo.toml deploy-cli/Cargo.toml
git commit -m "refactor: normalize shared resq-tui dependency"
```

### Task 5: Move obvious shared dependencies back to the workspace

**Files:**
- Modify: `deploy-cli/Cargo.toml`
- Modify: `flame-graph/Cargo.toml`
- Modify: `log-viewer/Cargo.toml`
- Modify: `perf-monitor/Cargo.toml`
- Modify: `resq-tui/Cargo.toml`

- [ ] **Step 1: Convert member crates from local versions to workspace dependencies where features already match**

Apply these patterns:

```toml
tokio = { workspace = true, features = ["full"] }
serde = { workspace = true }
serde_json = { workspace = true }
clap = { workspace = true }
chrono = { workspace = true }
regex = { workspace = true }
glob = { workspace = true }
```

For `perf-monitor`, keep the crate-local dependency only if the new root `reqwest` features are insufficient. Prefer:

```toml
reqwest = { workspace = true }
```

- [ ] **Step 2: Run targeted package checks for the crates that changed the most**

Run: `cargo check -p resq-log-viewer -p resq-perf-monitor -p resq-deploy-cli -p resq-flamegraph -p resq-tui`
Expected: PASS

- [ ] **Step 3: Run the full workspace check**

Run: `cargo check --workspace`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add deploy-cli/Cargo.toml flame-graph/Cargo.toml log-viewer/Cargo.toml perf-monitor/Cargo.toml resq-tui/Cargo.toml Cargo.toml
git commit -m "refactor: align crate manifests with workspace deps"
```

## Chunk 3: Docs and Verification

### Task 6: Update docs to advertise the new root workflow

**Files:**
- Modify: `README.md`
- Modify: `cli/README.md`

- [ ] **Step 1: Identify the stale workflow guidance**

Review these sections before editing:
- root install/build/development commands in `README.md`
- build/install commands in `cli/README.md`

Expected findings:
- no mention of `rust-toolchain.toml`
- no mention of cargo aliases
- no single recommended root workflow

- [ ] **Step 2: Update `README.md` to document the preferred Rust workflow**

Cover:
- pinned stable toolchain with `rustfmt` and `clippy`
- root aliases such as `cargo check-all`, `cargo t`, `cargo c`, `cargo resq -- --help`
- build-from-source guidance that matches the repo layout

- [ ] **Step 3: Update `cli/README.md` to acknowledge the new root workflow**

Keep crate-specific install guidance, but add a short note that the preferred day-to-day developer flow now lives at the workspace root via cargo aliases.

- [ ] **Step 4: Verify the user-facing commands**

Run:
- `cargo resq -- --help`
- `cargo check-all`

Expected:
- CLI help renders successfully
- workspace check passes via the new alias

- [ ] **Step 5: Commit**

```bash
git add README.md cli/README.md
git commit -m "docs: align rust workflow guidance"
```

### Task 7: Run final verification before closing the work

**Files:**
- No file changes; verification only

- [ ] **Step 1: Check formatting**

Run: `cargo fmt --all --check`
Expected: PASS

- [ ] **Step 2: Run the workspace check alias**

Run: `cargo check-all`
Expected: PASS

- [ ] **Step 3: Run the workspace test alias**

Run: `cargo t`
Expected: PASS

- [ ] **Step 4: Run the workspace clippy alias**

Run: `cargo c`
Expected: PASS

- [ ] **Step 5: Build the main binary in release mode**

Run: `cargo build --release -p resq-cli`
Expected: PASS and `target/release/resq` exists

- [ ] **Step 6: Review the final diff footprint**

Run: `git diff --stat HEAD~1..HEAD || git diff --stat`
Expected: only the planned root config, manifest, and doc files changed

- [ ] **Step 7: Commit the implementation**

```bash
git add Cargo.toml rust-toolchain.toml .cargo/config.toml README.md cli/README.md resq-tui/Cargo.toml cli/Cargo.toml cleanup/Cargo.toml bin-explorer/Cargo.toml health-checker/Cargo.toml log-viewer/Cargo.toml perf-monitor/Cargo.toml flame-graph/Cargo.toml deploy-cli/Cargo.toml
git commit -m "build: optimize rust workspace configuration"
```

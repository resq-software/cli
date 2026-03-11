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

# resq — Developer CLI

Rust developer tooling CLI for the ResQ monorepo. Handles license headers, image placeholders, security audits, dependency cost analysis, secret scanning, and TypeScript tree-shaking.

## Build & Install

```bash
cargo build --release --manifest-path tools/Cargo.toml -p resq-cli

# Optional: install globally
cargo install --path tools/cli
```

Binary: `tools/cli/target/release/resq`

## Commands

### `copyright` — License Header Management

Adds or checks copyright headers across every source file in the repo.

**Supported formats**: C-style block (`/** */`), XML/HTML (`<!-- -->`), hash-line (`#`), double-dash (`--`), Elisp (`;;`), AsciiDoc (`////`). Shebangs (`#!/...`) are always preserved at line 0.

**Licenses**: `mit` (default), `apache-2.0`, `gpl-3.0`, `bsd-3-clause`

```bash
# Check all tracked files (CI — exits 1 if any missing)
resq copyright --check

# Preview what would be added without writing
resq copyright --dry-run

# Add headers to all files missing them
resq copyright

# Overwrite existing headers (e.g. change license or author)
resq copyright --force --license apache-2.0 --author "Acme Corp" --year 2026

# Scope to specific file types
resq copyright --ext rs,ts,py

# Use explicit glob patterns instead of git ls-files
resq copyright --glob "services/**/*.rs" --glob "libs/**/*.rs"

# Exclude paths
resq copyright --exclude target --exclude node_modules
```

**File discovery** (in priority order):
1. `--glob` patterns if provided
2. `git ls-files` + untracked non-ignored files
3. Directory walk from project root (fallback when git unavailable)

Gitignore patterns are always applied on top of whichever source is used.

**Flags**:

| Flag | Default | Description |
|------|---------|-------------|
| `--license` | `mit` | License type |
| `--author` | `ResQ` | Copyright holder |
| `--year` | current year | Copyright year |
| `--force` | off | Overwrite existing headers |
| `--dry-run` | off | Print paths without writing |
| `--check` | off | CI mode — exit 1 if any file missing |
| `--verbose` / `-v` | off | Show per-file decisions |
| `--glob` | — | Glob patterns to match files |
| `--ext` | — | Comma-separated extensions to include |
| `--exclude` / `-e` | — | Path substrings to exclude |

---

### `lqip` — Low-Quality Image Placeholders

Generates tiny base64-encoded data URIs from images for use as blur-up placeholders in the web dashboard.

```bash
# Single image → prints data URI
resq lqip --target services/web-dashboard/public/hero.jpg

# Directory of images → text list
resq lqip --target services/web-dashboard/public/

# Recursive with JSON output (for import into JS)
resq lqip --target services/web-dashboard/public/ --recursive --format json

# Custom placeholder dimensions (default 20×15)
resq lqip --target image.png --width 32 --height 24
```

Output (text mode):
```
File: "hero.jpg"
LQIP: data:image/jpeg;base64,/9j/4AAQSkZ...
```

Output (JSON mode):
```json
[
  { "src": "hero", "path": "public/hero.jpg", "lqip": "data:image/jpeg;base64,..." }
]
```

Supported input formats: `jpg`, `jpeg`, `png`, `webp`. Output format matches input.

**Flags**:

| Flag | Default | Description |
|------|---------|-------------|
| `--target` / `-t` | — | File or directory to process |
| `--width` | `20` | Placeholder width in pixels |
| `--height` | `15` | Placeholder height in pixels |
| `--recursive` / `-r` | off | Recurse into subdirectories |
| `--format` | `text` | Output format: `text` or `json` |

---

### `audit` — Security & Quality Audit

Three-pass security and quality sweep covering all language ecosystems in the monorepo.

```bash
# Full audit (all three passes)
resq audit

# Scope to a specific subtree
resq audit --root services/infrastructure-api

# Run only the OSV Scanner pass
resq audit --skip-npm --skip-react

# Run only npm audit-ci
resq audit --skip-osv --skip-react

# Run only React Doctor
resq audit --skip-osv --skip-npm

# CI mode — fail on high+ npm severity, require score ≥ 80
resq audit --level high --react-min-score 80

# Scan only files changed since main (React Doctor)
resq audit --react-diff main

# Use SARIF output for OSV (e.g. upload to GitHub Code Scanning)
resq audit --osv-format sarif
```

**Pass 1 — OSV Scanner** (cross-ecosystem)

Runs `osv-scanner scan source -r <root>` against all lock files in the tree: `Cargo.lock`, `package-lock.json`, `yarn.lock`, `requirements.txt`, `*.csproj`, and more. Covers Rust, npm, Python, .NET, C/C++ via the [OSV.dev](https://osv.dev) vulnerability database.

Gracefully skips with an install hint if `osv-scanner` is not on `$PATH`:
```
Install: go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest
```

**Pass 2 — npm audit-ci**

Reads `package.json` workspace globs, then for each workspace:
1. Runs `bun install --yarn` to generate `yarn.lock` (required by audit-ci)
2. Runs `bunx audit-ci@^7.1.0 --<level> --report-type <type>`

**Pass 3 — React Doctor** (web dashboard)

Runs [`react-doctor`](https://github.com/millionco/react-doctor) against `services/web-dashboard` (or `--react-target`). Two phases:
1. **Diagnostic**: full `--verbose` run streamed to the terminal (60+ lint rules, dead code, bundle analysis)
2. **Score check**: separate `--score` invocation; fails if the 0–100 health score is below `--react-min-score`

All three passes run unconditionally; failures accumulate and a summary is printed at the end. Exits non-zero if any pass failed.

**Flags**:

| Flag | Default | Description |
|------|---------|-------------|
| `--root` | `.` | Root directory to scan |
| **npm audit-ci** | | |
| `--level` | `critical` | Minimum severity: `critical`, `high`, `moderate`, `low` |
| `--report-type` | `important` | Report verbosity: `important`, `full`, `summary` |
| `--skip-prepare` | off | Skip `bun install --yarn` step |
| `--skip-npm` | off | Skip the npm audit-ci pass entirely |
| **OSV Scanner** | | |
| `--skip-osv` | off | Skip the OSV Scanner pass |
| `--osv-format` | `table` | Output format: `table`, `json`, `sarif`, `gh-annotations` |
| **React Doctor** | | |
| `--skip-react` | off | Skip the React Doctor pass |
| `--react-target` | `<root>/services/web-dashboard` | Path to the React/Next.js project |
| `--react-diff` | — | Only scan files changed vs this base branch (e.g. `main`) |
| `--react-min-score` | `75` | Minimum health score to pass (0–100) |

---

### `cost` — Dependency Size Analysis

Fetches package sizes from registries (npm, crates.io, PyPI) and categorizes dependencies by download footprint. Useful for identifying bloated dependencies before they enter the repo.

```bash
# Auto-detect project type and analyze
resq cost

# Specific project
resq cost --root services/coordination-hce

# Force project type
resq cost --root services/infrastructure-api --project-type rust

# Custom output directory
resq cost --output reports/dependency-sizes
```

**Project type detection** (auto):
- `Cargo.toml` → Rust (queries crates.io)
- `package.json` → Node (queries npm registry)
- `pyproject.toml` / `requirements.txt` → Python (queries PyPI)

**Output**: Three JSON files written to `scripts/out/` (or `--output`):
- `high.json` — packages > 10 MB
- `medium.json` — packages 1–10 MB
- `low.json` — packages < 1 MB

Console summary:
```
📦 Package Size Summary:
   🔴 High (> 10 MB): 2 packages
   🟡 Medium (1-10 MB): 8 packages
   🟢 Low (< 1 MB): 34 packages

📊 Total size: 127.45 MB
```

Up to 10 registry requests run concurrently.

**Flags**:

| Flag | Default | Description |
|------|---------|-------------|
| `--root` | `.` | Directory with project manifest |
| `--output` | `scripts/out` | Output directory for JSON reports |
| `--project-type` | auto-detect | Force: `node`, `rust`, `python` |

---

### `secrets` — Secret Scanner

Scans source files for hardcoded credentials, API keys, private keys, tokens, and high-entropy strings. Designed to run as a pre-commit hook or in CI.

```bash
# Scan all git-tracked files (default)
resq secrets

# Only scan staged changes (pre-commit hook)
resq secrets --staged

# Show matched content in output (partially redacted)
resq secrets --verbose

# Scan all files, not just git-tracked
resq secrets --git-only false

# Load allowlist from custom path
resq secrets --allowlist .secretsignore
```

**Detected patterns** (26 rules):
- Cloud providers: AWS access/secret keys, GCP API keys, GCP service accounts
- Source control: GitHub PATs (classic, fine-grained, OAuth, App tokens)
- AI/APIs: OpenAI, Anthropic, Stripe, Slack, Twilio, SendGrid, Mailgun
- Infrastructure: database connection strings (`postgres://`, `mongodb://`, etc.)
- Private keys: RSA, DSA, EC, OpenSSH, PGP
- Generic: bearer tokens, JWT tokens, `api_key=`/`secret=` assignments
- High-entropy: hex strings ≥ 40 chars with Shannon entropy > 4.5

**Allowlist**: Create `.secretsignore` at project root (one pattern per line, `#` for comments). Findings whose content or file path contains a pattern are suppressed.

**Pre-commit hook** integration:
```bash
# .git/hooks/pre-commit
resq secrets --staged
```

Exits 0 if clean, 1 if secrets found.

**Flags**:

| Flag | Default | Description |
|------|---------|-------------|
| `--root` | `.` | Directory to scan |
| `--git-only` | `true` | Only scan git-tracked + untracked-but-not-ignored files |
| `--staged` | off | Scan only staged changes (overrides `--git-only`) |
| `--verbose` / `-v` | off | Show (redacted) matched content |
| `--allowlist` | `.secretsignore` | Path to allowlist file |

---

### `tree-shake` — TypeScript Dead Code Removal

Runs [`tsr`](https://github.com/line/ts-remove-unused) to remove unused TypeScript exports from the project entry points.

```bash
resq tree-shake
```

Runs: `bunx tsr --write --recursive "^src/(main|index)\.ts$" "^src/app/.*\.(ts|tsx)$"`

No flags — operates on the project root detected by walking up from the current directory.

---

## Project Root Detection

All commands resolve the project root by walking up from the current directory until finding a `Cargo.toml`, `package.json`, or `pyproject.toml`. This means you can run `resq <cmd>` from any subdirectory in the monorepo.

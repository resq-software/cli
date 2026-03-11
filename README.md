# resq

Developer CLI for the [ResQ](https://github.com/resq-software/resQ) autonomous drone platform.

## Install

```sh
cargo install resq-cli
```

## Commands

| Command | Description |
|---|---|
| `resq copyright` | Check / fix copyright headers across the repo |
| `resq secrets` | Scan for leaked credentials and secrets |
| `resq audit` | Audit blockchain events |
| `resq cost` | Estimate cloud costs |
| `resq lqip` | Generate low-quality image placeholders |
| `resq tree-shake` | Remove unused exports (tsr wrapper) |
| `resq dev` | Start the development server |
| `resq pre-commit` | Run pre-commit checks (TUI) |
| `resq version` | Manage versions and changesets |
| `resq docs` | Export and publish documentation |
| `resq explore` | Launch Perf-Explorer TUI |
| `resq logs` | Launch Log-Explorer TUI |
| `resq health` | Launch Health-Explorer TUI |
| `resq deploy` | Launch Deploy-Explorer TUI |
| `resq clean` | Launch Cleanup-Explorer TUI |
| `resq asm` | Launch Asm-Explorer for machine code analysis |

## Publishing

Releases are automated via the `release.yml` workflow on `v*` tags.
Add a `CARGO_REGISTRY_TOKEN` secret to the repository to enable crates.io publishing.

```sh
git tag v0.2.0
git push origin v0.2.0
```

## License

Apache-2.0

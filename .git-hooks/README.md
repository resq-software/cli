# ResQ Git Hooks

This directory contains custom Git hooks for the ResQ platform.

## Hooks

### `pre-commit`
Runs a comprehensive set of checks before allowing a commit:
- **Copyright Verification**: Ensures all source files have appropriate Apache-2.0 headers.
- **Secret Scanning**: Scans for accidental inclusion of API keys, private keys, and credentials.
- **Security Audit**: Runs `cargo audit` and other security checks.
- **Formatting**: Verifies code formatting.
- **Versioning**: Prompts for a changeset if a version bump is needed.

This hook delegates to the `resq pre-commit` command in the project's own CLI.

### `commit-msg`
Ensures commit messages follow the **Conventional Commits** specification:
- Format: `type(scope): subject`
- Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Prevents `fixup!`, `squash!`, and `WIP` commits on the `master` branch.

## Setup

To enable these hooks, run the following command from the repository root:

```bash
resq dev install-hooks
```

If you are using the debug build:
```bash
./target/debug/resq dev install-hooks
```

This configures `git` to use this directory for hooks:
```bash
git config core.hooksPath .git-hooks
```

## Bypassing Hooks

If you need to bypass hooks for a specific commit (e.g., when committing a work-in-progress to a feature branch):

```bash
git commit --no-verify
```

Or set the environment variable:
```bash
GIT_HOOKS_SKIP=1 git commit
```

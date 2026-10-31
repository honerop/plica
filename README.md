# Plica

Plica is an experimental **structured terminal shell implemented entirely in [Babel](https://github.com/honerop/babel)**. It currently provides a small interactive dispatcher, structured filesystem and process results, native terminal commands, and an explicit AI query command.

This is a developer preview, **not yet a POSIX-compatible login shell**. Do not set it as your default shell.

## NixOS quick start

Run the current version directly from GitHub:

```sh
nix run github:honerop/plica
```

Or clone the repo and run:

```sh
nix build
nix run .
nix develop
```

You can work on Babel and Plica at the same time with `nix build --override-input babel path:../babel` (requires a neighboring Babel checkout). See [development instructions](docs/development.md).

## Commands

| Command | Behavior |
|---|---|
| `pwd` | Show the working directory |
| `cd PATH` | Change the current shell directory |
| `files [PATH]` | Emit a structured JSON list of `{name}` records |
| `capture CMD ARGS` | Run a program and emit `{code,stdout,stderr}` JSON |
| `ask PROMPT` | Ask Babel's OpenCode AI provider; does **not** execute AI output |
| `help` / `exit` | Show help or exit |
| Any other command | Launch directly with inherited terminal I/O |

Example session:

```text
plica> pwd
/home/me/dev
plica> cd projects
plica> files .
[{"name":"babel"},{"name":"plica"}]
plica> git status
... normal git output ...
plica> capture git status --porcelain
{"code":0,"stderr":"","stdout":"..."}
```

## Known limitations

Argument parsing currently splits on whitespace. Quoting, escaping, globs, pipelines (`|`), redirection, environment assignments, history, completion, shell script evaluation, background jobs, and robust POSIX job control are not yet implemented. `files` and `capture` emit structured data, but there is no structured pipeline syntax yet.

Plica's application source is 100% Babel: [`src/main.babel`](src/main.babel). The build uses Nix and Babel's existing Rust compiler/runtime for OS bindings. AI support uses Babel's `chat` builtin and an available OpenCode CLI/provider. Do not run AI-generated shell commands without review.

The required Babel terminal primitives were merged in [Babel PR #47](https://github.com/honerop/babel/pull/47). The flake pins the corresponding merge commit. There is no `flake.lock` yet, so `nixpkgs` is not pinned; generate and commit a lockfile before treating builds as reproducible.

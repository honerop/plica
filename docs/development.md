# Developing and debugging Plica on NixOS

The shell is Babel code, not a Rust wrapper. You can modify Babel itself when the compiler or standard library lacks a needed operation.

## Using Nix

```sh
nix --extra-experimental-features 'nix-command flakes' build
nix run .
```

Use a neighboring Babel checkout for compiler/runtime changes:

```sh
git clone https://github.com/honerop/babel ../babel
cd ../babel
git switch main
cd -
nix build --override-input babel path:../babel --show-trace
nix run . --override-input babel path:../babel
```

The required terminal primitives and segment imports are merged into Babel `main`. Plica now imports `system.fs`, `system.process`, `system.terminal`, and `ai.chat`. A dirty Babel checkout is acceptable during local iteration, but Nix may warn that it is dirty.

## Faster development loop

Run `nix develop` to enter a shell with `rustc`, `cargo`, and `git`. Build the compiler from local or pinned Babel sources and then compile the actual shell:

```sh
mkdir -p .build
rustc --edition=2021 --crate-name babel_compiler --crate-type lib "$BABEL_SRC/src/lib.rs" -o .build/libbabel_compiler.rlib
rustc --edition=2021 "$BABEL_SRC/src/main.rs" --extern babel_compiler=.build/libbabel_compiler.rlib -o .build/babelc
.build/babelc check-json src/main.babel
.build/babelc build src/main.babel -o .build/plica
./.build/plica
```

If you want to iterate on a local Babel checkout instead of Nix's pinned copy, export `BABEL_SRC="$PWD/../babel"` before running these commands.

## Test native Linux executables

The native command path uses Babel's `processinherit`, which runs binaries from the inherited `PATH` or direct absolute/relative executable paths.

```text
plica> git status
plica> /usr/bin/env printf hello
plica> run /usr/bin/env printf hello
plica> ./local-executable
```

The smoke test also creates an executable script and verifies invocation by name through a temporary PATH addition, via `run`, by its absolute path, and using `./` after `cd`. It conditionally checks a `/usr/bin/env` executable when available. On NixOS, most binaries live in the Nix store, not `/usr/bin`.

## Smoke test

```sh
bash tests/smoke.sh .build/plica
```

You can diagnose a Babel compile failure with `.build/babelc check-json src/main.babel`. The JSON diagnostics include an error code and line number. The current backend emits Rust and compiles it with `rustc`; low-level runtime issues may require inspecting `.build/babelc transpile src/main.babel -o .build/generated.rs`.

For runtime failures, start from Ghostty or another regular terminal. Do not make Plica a login shell: Ctrl-C/job control, quoting, completion, and history still need proper handling.

## Design boundaries

- `src/main.babel` is the *entire shell implementation*. No native code belongs in this repo to implement shell behavior.
- Native OS features that Babel cannot express yet belong in generic Babel builtins/segments, not Plica-specific Rust files.
- Interactive native programs use `processinherit`; machine-readable capture uses `processrun`. Those are not the same transport.
- `ask` runs a model query only. Its output is text, never an automatically executed command.
- A future `segments/shell` library in Babel should expose terminal, process, filesystem, and structured stream types without requiring AI or GUI dependencies.

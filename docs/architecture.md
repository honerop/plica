# Plica architecture and Babel segments

The v0 shell is one Babel source file because Babel does not yet support a real module/import system. That is a compiler limit, not an argument for implementing the shell in Rust.

## Near-term shape

```text
Ghostty / other terminal
        ⇅ stdin / stdout / stderr via terminal PTY
Plica (Babel)
  ├─ REPL and command dispatch
  ├─ Data values / structured command results
  ├─ explicit AI requests (Babel chat)
  └─ Babel standard runtime
       ├─ termwrite, readline
       ├─ workingdir, changedir, fslist
       ├─ processinherit (interactive terminal)
       └─ processrun (captured structured output)
```

## Segments (proposed, not implemented)

Instead of putting every operation in the compiler's parser, Babel could group related libraries in **segments**. Each segment may contain many modules, but the compiler remains lean:

| Segment | Proposed modules |
|---|---|
| `core` | Data, collections, text, JSON, errors |
| `system` | filesystem, paths, processes, env, terminal, PTY, signals |
| `network` | HTTP, TCP, sockets, protocol parsers |
| `storage` | SQLite, serialization, TOML, CSV |
| `ai` | chat, tools, agents, capability grants |
| `desktop` | GUI, input, clipboard, accessibility |
| `media` | audio, graphics, video |

The compiler should recognize a small module/segment manifest, resolve dependencies, and compile only referenced code. Reusable public APIs belong in Babel; OS bindings may still require native runtime code inside the Babel project. Runtime availability and feature selection should be independent of syntax.

**Do not split existing runtime source files immediately.** First add modules/imports, then move the existing builtins behind compatibility aliases and exercise golden tests. A large rename before a module resolver exists mainly creates broken imports.

## Roadmap

1. Ship the Babel-native REPL with external command execution and structured `files`/`capture` output.
2. Add lexical quoting/escaping and arguments, then real `Data` stream pipelines with explicit text adapters.
3. Add process groups, signals, PTY job control and interactive terminal handoff.
4. Add safe configuration, shell history, completion, and PATH/cache support.
5. Introduce Babel modules/segment manifests, migrate standard APIs, then expose agent orchestration with per-action approvals and clear capability boundaries.

No phase should execute model-produced code automatically. Babel's builtin permissions are not an OS sandbox.

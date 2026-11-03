# Plica architecture and Babel segments

The v0 shell is still one application file, but it imports reusable Babel modules. The current compiler supports `use segment.module` with versioned manifests and expands imported Babel functions into the program. The application remains Babel-only.

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

## Segments (initial imports implemented)

Babel now groups Babel source wrappers into **segments**. Plica imports `system.fs`, `system.process`, `system.terminal`, and `ai.chat`. The seven segment families are:

| Segment | Proposed modules |
|---|---|
| `core` | Data, collections, text, JSON, errors |
| `system` | filesystem, paths, processes, env, terminal, PTY, signals |
| `network` | HTTP, TCP, sockets, protocol parsers |
| `storage` | SQLite, serialization, TOML, CSV |
| `ai` | chat, tools, agents, capability grants |
| `desktop` | GUI, input, clipboard, accessibility |
| `media` | audio, graphics, video |

The Rust backend recognizes versioned segment manifests, resolves explicit imports, and compiles the expanded source. Reusable APIs belong in Babel; OS bindings still need native runtime code inside Babel. Existing native builtins are compatible aliases, not yet fully isolated namespaces.

**Remaining work:** migrate more builtins behind importable wrappers and add integration tests without breaking legacy programs.

## Roadmap

1. Ship the Babel-native REPL with external command execution and structured `files`/`capture` output.
2. Add lexical quoting/escaping and arguments, then real `Data` stream pipelines with explicit text adapters.
3. Add process groups, signals, PTY job control and interactive terminal handoff.
4. Add safe configuration, shell history, completion, and PATH/cache support.
5. Extend existing Babel segment modules, migrate remaining APIs, then expose agent orchestration with per-action approvals and clear capability boundaries.

No phase should execute model-produced code automatically. Babel's builtin permissions are not an OS sandbox.

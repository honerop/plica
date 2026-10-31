# Plica development rules

- Shell source is **100% Babel**. Do not add Rust/Python/Go/JS runtime implementation inside Plica.
- Compiler gaps must be fixed as reusable Babel language/runtime features, ideally reusable across all Babel apps.
- The only shell implementation is `src/main.babel`. Nix and CI/test scripts are packaging and test infrastructure, not shell runtime.
- The default runtime is the Babel Rust backend (AIR/LLVM currently does not have these OS primitives).
- Keep structured Data distinct from terminal byte streams. `processinherit` is for interactive foreground binaries; `processrun` is for captured structured results.
- Do not claim POSIX compatibility, typed process pipelines, correct SIGINT behavior, or isolation without tests.
- AI commands require explicit invocation. Never automatically execute model output. Babel permissions are not OS sandboxing.
- Validate `babelc check-json src/main.babel` and `tests/smoke.sh`, then add tests for each new command or segment.

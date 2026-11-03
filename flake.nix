{
  description = "Plica: structured interactive shell written in Babel";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pinned to Babel main with importable segment modules.
    # Override this input with path:../babel while hacking on both repos.
    babel.url = "github:honerop/babel/e4b15a2298d9c51332ce40b53aa53d05544d3ce8";
  };
  outputs = { self, nixpkgs, babel }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forSystems = f: nixpkgs.lib.genAttrs systems
        (system: f (import nixpkgs { inherit system; }));
    in {
      packages = forSystems (pkgs:
        let
          plica = pkgs.stdenv.mkDerivation {
            pname = "plica";
            version = "0.1.0";
            src = self;
            nativeBuildInputs = [ pkgs.rustc ];
            dontConfigure = true;
            buildPhase = ''
              runHook preBuild
              mkdir -p .build
              rustc --edition=2021 --crate-name babel_compiler --crate-type lib \
                ${babel}/src/lib.rs -o .build/libbabel_compiler.rlib
              rustc --edition=2021 ${babel}/src/main.rs \
                --extern babel_compiler=.build/libbabel_compiler.rlib \
                -o .build/babelc
              .build/babelc check src/main.babel
              .build/babelc build src/main.babel -o .build/plica
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              install -Dm755 .build/plica "$out/bin/plica"
              runHook postInstall
            '';
            meta = {
              description = "Early interactive shell built in Babel";
              mainProgram = "plica";
              platforms = pkgs.lib.platforms.linux;
            };
          };
        in { default = plica; plica = plica; });
      apps = forSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/plica";
        };
      });
      devShells = forSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ pkgs.rustc pkgs.cargo pkgs.git ];
          shellHook = ''
            export BABEL_SRC=${babel}
            echo 'Plica dev shell: see docs/development.md'
          '';
        };
      });
    };
}

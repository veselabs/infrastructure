{
  description = "infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts/main";
    treefmt-nix.url = "github:numtide/treefmt-nix/main";
    devenv.url = "github:cachix/devenv/main";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({self, ...}: {
      systems = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];

      perSystem = {
        pkgs,
        self',
        system,
        ...
      }: let
        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs = {
            alejandra.enable = true;
            prettier.enable = true;
            terraform.enable = true;
            terraform.package = pkgs.terraform;
          };
        };
      in {
        devShells.default = inputs.devenv.lib.mkShell {
          inherit inputs pkgs;

          modules = [
            {
              env = {
                AWS_ACCESS_KEY_ID = "op://veselabs/AWS Root Access Key/username";
                AWS_SECRET_ACCESS_KEY = "op://veselabs/AWS Root Access Key/credential";
                GITHUB_APP_ID = "op://veselabs/GitHub App Organization/id";
                GITHUB_APP_INSTALLATION_ID = "op://veselabs/GitHub App Organization/installation_id";
                GITHUB_APP_PEM_FILE = "op://veselabs/GitHub App Private Key/private key";
              };

              languages = {
                nix.enable = true;
                terraform.enable = true;
              };

              packages = [
                self'.formatter
              ];

              git-hooks.hooks = {
                deadnix.enable = true;
                end-of-file-fixer.enable = true;
                statix.enable = true;
                treefmt.enable = true;
                treefmt.package = self'.formatter;
                trim-trailing-whitespace.enable = true;
              };
            }
          ];
        };

        devShells.ci = pkgs.mkShellNoCC {
          packages = builtins.attrValues {
            inherit (pkgs) terraform;
          };
        };

        packages = {
          devenv-test = self'.devShells.default.config.test;
          devenv-up = self'.devShells.default.config.procfileScript;
        };

        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    });
}

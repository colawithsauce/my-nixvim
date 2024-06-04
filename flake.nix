{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-23.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    vim-pretty-folds = {
      url = "github:luisdavim/pretty-folds";
      flake = false;
    };
    todoist-nvim = {
      url = "github:romgrk/todoist.nvim";
      flake = false;
    };
    mlir = {
      url = "path:/home/colawithsauce/Projects/Triton/llvm-project/mlir/utils/vim";
      flake = false;
    };
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    { nixvim
    , flake-parts
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      perSystem =
        { self, pkgs, system, config, ... }:
        let
          nixvimLib = nixvim.lib.${system};
          nixvim' = nixvim.legacyPackages.${system};
          nixvimModule = {
            inherit pkgs;
            module = import ./config; # import the module directly
            # You can use `extraSpecialArgs` to pass additional arguments to your module files
            extraSpecialArgs = {
              # inherit (inputs) foo;
              inherit inputs;
            };
          };
          nvim = nixvim'.makeNixvimWithModule nixvimModule;
        in
        rec
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
            overlays = [
              inputs.neovim-nightly.overlays.default
            ];
          };

          checks = {
            # Run `nix flake check .` to verify that your config is not broken
            default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
          };

          packages = {
            neovim = nvim;
            # Lets you run `nix run .` to start nixvim
            default = nvim;
          };

          overlayAttrs = {
            inherit (config.packages) neovim;
          };
        };
    };
}

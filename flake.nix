{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    dagger.url = "github:dagger/nix";
    dagger.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      dagger,
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        deps = with pkgs; [
          gomplate
          tectonic
        ];
      in
      {
        devShell = pkgs.mkShell {
          packages =
            deps
            ++ (with pkgs; [
              git-crypt # for secrets
              texliveMinimal # for editor linting
            ])
            ++ [
              dagger.packages.${system}.dagger
            ];
        };
      }
    );
}

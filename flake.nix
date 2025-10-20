{
  description = "Booklore inputs";

  inputs = {
    build-gradle-application.url = "github:raphiz/buildGradleApplication";
  };

  outputs = { self, nixpkgs, build-gradle-application, ... }:
    let
      system = "x86_64-linux";
	  pkgs = import nixpkgs {
        inherit system;
        overlays = [build-gradle-application.overlays.default];
      };
    in {
	  packages.${system} = {
	    booklore-api = pkgs.callPackage ./booklore-api.nix { };
      };
	  nixosModules.booklore-api = import ./module/booklore-api.nix;
    };
}

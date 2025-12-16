{
  description = "Booklore flake";

  inputs = {
    build-gradle-application.url = "github:raphiz/buildGradleApplication";
  };

  outputs =
    {
      self,
      nixpkgs,
      build-gradle-application,
      ...
    }:
    let
      system = "x86_64-linux";
      version = "v1.13.2";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
					build-gradle-application.overlays.default 
				];
      };
			booklore-api = pkgs.callPackage ./booklore-api.nix { inherit version; };
			booklore-ui = pkgs.callPackage ./booklore-ui.nix { inherit version; };
    in
	{
		formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
		packages.${system} = {
			booklore-api = booklore-api;
			booklore-ui = booklore-ui;
		};
		nixosModules.booklore-api = import ./nixos/modules/booklore-api.nix;
		nixosModules.booklore-ui = import ./nixos/modules/booklore-ui.nix;

		nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
			inherit system;
			specialArgs = {
			 inherit booklore-api booklore-ui;
			};
			modules = [
				self.nixosModules.booklore-api
				self.nixosModules.booklore-ui
				(import ./nixos/vm-test.nix { inherit self pkgs; })
				# Config for VM allocation
				(
					{ config, pkgs, ... }:
					{
						virtualisation.vmVariant = {
							virtualisation = {
								memorySize = 4096;
								cores = 2;
							};
						};
					}
				)
			];
		};
	};
}

{
  description = "Booklore flake";

  inputs = { };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      version = "v1.14.1";
			sha256 = "01ikqf3fmyghyg7zi8s9c8yi2b0s31f6xv20ig7nzn9kqv9ks37h";
      pkgs = import nixpkgs {
        inherit system;
      };
			booklore-api = pkgs.callPackage ./booklore-api.nix { inherit version sha256; };
			booklore-ui = pkgs.callPackage ./booklore-ui.nix { inherit version sha256; };
    in
	{
		formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
		packages.${system} = {
			inherit booklore-api booklore-ui;
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

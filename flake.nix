{
  description = "Booklore flake";

  inputs = { };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      version = "v1.14.1";
			rev = "a3caea3411527900ca12414b66614fd168dd0d27";
			hash = "sha256-8Aw908Yz2W/Pi0DsblwYGiwRPWJJo/jP8/D56obDMwY=";
      pkgs = import nixpkgs {
        inherit system;
      };
			booklore-api = pkgs.callPackage ./booklore-api.nix { inherit version rev hash; };
			booklore-ui = pkgs.callPackage ./booklore-ui.nix { inherit version rev hash; };
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

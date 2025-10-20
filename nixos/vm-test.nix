{self, pkgs, lib, ...}:

{
  networking.hostName = "booklore-vm";
  services.getty.autologinUser = "root";

  services.booklore-api = {
    enable = true;
	package = self.packages.${pkgs.system}.booklore-api;
  };
}

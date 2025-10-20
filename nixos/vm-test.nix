{self, pkgs, ...}:

{
  networking.hostName = "booklore-vm";
  services.getty.autologinUser = "root";

  services.mysql = {
    enable = true;
	package = pkgs.mariadb;
  };

  services.booklore-api = {
    enable = true;
	package = self.packages.${pkgs.system}.booklore-api;
  };
}

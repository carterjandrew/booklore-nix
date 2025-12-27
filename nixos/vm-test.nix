{ pkgs, ... }:

{
  networking.hostName = "booklore-vm";

  services = {
		booklore = {
			enable = true;
			database.password = "secret";
		};
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  programs.firefox.enable = true;
  programs.sway.enable = true;

  users.users.test = {
    isNormalUser = true;
    enable = true;
    password = "test";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

}

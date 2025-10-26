{self, pkgs, ...}:

{
  networking.hostName = "booklore-vm";
  services.getty.autologinUser = "root";

  services.mysql = {
    enable = true;
	package = pkgs.mariadb;
	ensureDatabases = [ "booklore" ];
  };

  systemd.services.setdbpass = {
    wants = [ "mysql.service" ];
	wantedBy = [ "multi-user.target" ];
	serviceConfig = {
	  Type = "oneshot";
	  RemainAfterExit = true;
	  User = "root";
	  ExecStart = ''
        ${pkgs.mariadb}/bin/mysql -u root -e \
		"CREATE booklore@localhost IF NOT EXISTS IDENTIFIED BY 'passwd';"
	  '';
	};
  };

  services.booklore-api = {
    enable = true;
	package = self.packages.${pkgs.system}.booklore-api;
	database.host = "localhost";
	database.password = "passwd";
	port = 7070;
  };

  services.booklore-ui = {
    enable = true;
	package = self.packages.${pkgs.system}.booklore-ui;
  };

  programs.firefox.enable = true;
  programs.sway.enable = true;

  services = {
	displayManager.sddm.enable = true;
	displayManager.sddm.wayland.enable = true;
  };

  users.users.carter = {
    isNormalUser = true;
	enable = true;
	password = "Test";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  services.nginx = {
    enable = true;
	recommendedProxySettings = true;
	recommendedTlsSettings = true;

	virtualHosts."booklore.local" = {
      listen = [{
	    addr = "0.0.0.0";
		port = 8080;
	  }];

	  locations."/" = {
	    proxyPass = "http://127.0.0.1:6060";
	    extraConfig = ''
		  proxy_set_header X-Forwarded-Port 8080;
		  proxy_set_header X-Forwarded-Host localhost;
		'';
	  };
	  locations."/api" = {
	    proxyPass = "http://127.0.0.1:7070";
	    extraConfig = ''
		  proxy_set_header X-Forwarded-Port 8080;
		  proxy_set_header X-Forwarded-Host localhost;
		'';
	  };
	  locations."/ws" = {
	    proxyPass = "http://127.0.0.1:7070/ws";
		proxyWebsockets = true;
	  };
	};
  };
}

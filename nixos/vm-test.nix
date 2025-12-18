{ self, pkgs, ... }:

{
  networking.hostName = "booklore-vm";
  systemd.services.setdbpass = {
    wants = [ "mysql.service" ];
    after = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
		script = ''
			${pkgs.mariadb}/bin/mysql -u root -e \
			"
				CREATE DATABASE IF NOT EXISTS booklore;
				DROP USER IF EXISTS 'booklore'@'localhost';
				DROP USER IF EXISTS 'booklore'@'%';
				CREATE USER 'booklore'@'localhost' IDENTIFIED BY 'passwd';
				GRANT ALL PRIVILEGES ON booklore.* TO 'booklore'@'localhost';
				FLUSH PRIVILEGES;
			"
		'';
  };

  services = {
    getty.autologinUser = "root";
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };

    booklore-api = {
      enable = true;
      package = self.packages.${pkgs.system}.booklore-api;
      database.host = "127.0.0.1";
      database.password = "passwd";
    };

    booklore-ui = {
      enable = true;
    };

    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."booklore.local" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 7070;
          }
        ];

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:6060";
            extraConfig = ''
              						proxy_set_header X-Forwarded-Port 7070;
              						proxy_set_header X-Forwarded-Host localhost;
              					'';
          };

          "/api" = {
            proxyPass = "http://127.0.0.1:8080";
            extraConfig = ''
              						proxy_set_header X-Forwarded-Port 7070;
              						proxy_set_header X-Forwarded-Host localhost;
              					'';
          };

          "/ws" = {
            proxyPass = "http://127.0.0.1:7070/ws";
            proxyWebsockets = true;
          };
        };
      };
    };
  };

  programs.firefox.enable = true;
  programs.sway.enable = true;

  users.users.carter = {
    isNormalUser = true;
    enable = true;
    password = "Test";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

}

# nixos/modules/booklore.nix
{
	config,
	lib,
	pkgs,
	...
}:

with lib;

let
  cfg = config.services.booklore;
in {
	imports = [
		./booklore-api.nix
	];

  options.services.booklore = {
    enable = mkEnableOption "Booklore service";
    
    database = {
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      
      password = mkOption {
        type = types.str;
      };
      
      name = mkOption {
        type = types.str;
        default = "booklore";
      };
      
      user = mkOption {
        type = types.str;
        default = "booklore";
      };
    };
    
    ui = {
      package = mkOption {
        type = types.package;
				# default = booklore-ui;
        description = "Booklore UI package";
      };
      
      port = mkOption {
        type = types.port;
        default = 7070;
      };
    };
    
    # Allow users to extend nginx/mysql config through standard means
    # rather than duplicating options
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = mkDefault true;
      virtualHosts."booklore.local" = {
        root = "${cfg.ui.package}/lib/node_modules/booklore/dist/booklore/browser/";
        listen = [{
          port = cfg.ui.port;
          addr = "0.0.0.0";
        }];
        locations = {
          "/" = {
            tryFiles = "$uri $uri/ /index.html";
            extraConfig = ''
              location ~* \.mjs$ {
                types {
                  text/javascript mjs;
                }
              }
            '';
          };
          "/api/" = {
            proxyPass = "http://${cfg.database.host}:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Port ${toString cfg.ui.port};
              proxy_set_header X-Forwarded-Host localhost;
            '';
          };
          "/ws" = {
            proxyPass = "http://${cfg.database.host}:8080/ws";
            proxyWebsockets = true;
          };
        };
      };
    };
    
    services.mysql = {
      enable = mkDefault true;
      package = mkDefault pkgs.mariadb;
    };
    
    systemd.services.booklore-init-db = {
      wants = [ "mysql.service" ];
      after = [ "mysql.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      script = ''
        ${config.services.mysql.package}/bin/mysql -u root -e "
          CREATE DATABASE IF NOT EXISTS ${cfg.database.name};
          DROP USER IF EXISTS '${cfg.database.user}'@'localhost';
          CREATE USER '${cfg.database.user}'@'localhost' IDENTIFIED BY '${cfg.database.password}';
          GRANT ALL PRIVILEGES ON ${cfg.database.name}.* TO '${cfg.database.user}'@'localhost';
          FLUSH PRIVILEGES;
        "
      '';
    };
    
    services.booklore-api = {
      enable = true;
      database = cfg.database;
    };
  };
}

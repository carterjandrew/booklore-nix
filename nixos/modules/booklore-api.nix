{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let cfg = config.services.booklore-api; in {
  options.services.booklore-api = {
    enable = lib.mkEnableOption "booklore-api service";

	user = mkOption { type = types.str; default = "booklore"; };
	group = mkOption { type = types.str; default = "booklore"; };

	package = mkOption {
	  type = types.package;
	  description = "Booklore derivation that provides a fat JAR, and a optional JRE wrapper binary";
	};

    port = mkOption {
      type = types.port;
	  default = 6060;
	  description = "Port BookLore API listens on";
	};

	dataDir = mkOption {
      type = types.path;
      default = "/var/lib/booklore/data";
      description = "Persistent BookLore application data directory.";
    };

	booksDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Primary books library directory to mount read/write into the service.";
    };

	bookdropDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "BookDrop directory watched for imports.";
    };

    database = {
      host = mkOption { type = types.str; default = "127.0.0.1"; };
      port = mkOption { type = types.port; default = 3306; };
      name = mkOption { type = types.str; default = "booklore"; };
      user = mkOption { type = types.str; default = "booklore"; };
      # Prefer a passwordFile for secrets; plain password allowed for testing.
      passwordFile = mkOption { type = types.nullOr types.path; default = null; };
      password = mkOption { type = types.nullOr types.str; default = null; };
      # Supply a full JDBC URL yourself to override (otherwise composed from host/port/name).
      jdbcUrl = mkOption { type = types.nullOr types.str; default = null; };
    };

  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
	  isSystemUser = true;
	  group = cfg.group;
	  home = "/var/lib/booklore";
	  createHome = true;
	};
	users.groups.${cfg.group} = { };

	systemd.services.booklore = {
	  description = "Booklore API";
	  wantedBy = [ "multi-user.target" ];
	  after = [ "network-online.target" ];
	  wants = [ "network-online.target" ];
	  serviceConfig = {
        User = cfg.user;
		Group = cfg.group;
		ExecStart = "${cfg.package}/bin/booklore-api";
	  };
	};
  };
}

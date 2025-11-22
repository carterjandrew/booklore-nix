{
  lib,
  config,
  ...
}:
with lib;
let cfg = config.services.booklore-api; in {
  options.services.booklore-api = {
		enable = lib.mkEnableOption "booklore-api service";

		user = mkOption { type = types.str; default = "booklore"; };
		group = mkOption { type = types.str; default = "booklore"; };

		wants = mkOption {
			type = types.listOf types.str;
			description = "Wanted services and targets for triggering start";
			default = [ "mysql.service" "network-online.target"];
		};

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
		
		after = mkOption {
			type = types.listOf types.str;
			default = [ "network-online.target" ];
			description = "The targets and services we wait on to start";
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
			jdbcUrl = mkOption { type = types.str; default = "jdbc:mariadb://${cfg.database.host}:${builtins.toString(cfg.database.port)}/booklore"; };
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

	systemd.services.booklore-api = {
	  description = "Booklore API";
	  wantedBy = [ "multi-user.target" ];
	  after = cfg.after;
	  wants = cfg.wants;
	  serviceConfig = {
        User = cfg.user;
		Group = cfg.group;
		ExecStart = "${cfg.package}/bin/booklore-api";
	  };
	  environment = {
        TZ="Etc/UTC";
        DATABASE_URL=cfg.database.jdbcUrl;
        DATABASE_USERNAME=cfg.database.user;
        DATABASE_PASSWORD=cfg.database.password;
        SWAGGER_ENABLED="false";
        FORCE_DISABLE_OIDC="false";
	  };
	};
  };
}

{
	booklore-api,
	pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.booklore-api;
in
{
  options.services.booklore-api = {
    enable = lib.mkEnableOption "Booklore API";

    user = lib.mkOption {
      type = lib.types.str;
      default = "booklore";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "booklore";
    };

    wants = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Wanted services and targets for triggering start";
      default = [
        "mysql.service"
        "network-online.target"
      ];
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = booklore-api;
      description = "Booklore derivation that provides a fat JAR, and a optional JRE wrapper binary";
    };

    # port = lib.mkOption {
    # 	type = lib.types.port;
    # 	default = 6060;
    # 	description = "Port BookLore API listens on";
    # };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/booklore/data";
      description = "Persistent BookLore application data directory.";
    };

    booksDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/booklore/books";
      description = "Primary books library directory to mount read/write into the service.";
    };

    bookdropDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/booklore/bookdrop";
      description = "BookDrop directory watched for imports.";
    };

    after = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
				"network-online.target"
				"systemd-tmpfiles-setup.service"
			];
      description = "The targets and services we wait on to start";
    };

    database = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 3306;
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "booklore";
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = "booklore";
      };
      # Prefer a passwordFile for secrets; plain password allowed for testing.
      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      # Supply a full JDBC URL yourself to override (otherwise composed from host/port/name).
      jdbcUrl = lib.mkOption {
        type = lib.types.str;
        default = "jdbc:mariadb://${cfg.database.host}:${builtins.toString cfg.database.port}/booklore";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      home = "/var/lib/booklore";
      createHome = true;
    };

    users.groups.${cfg.group} = { };

		# We use systemD path binds so the api will look in the 
		# right place for files
		# But the host directories need to exist before we bind them
		systemd.tmpfiles.rules = [
			"d ${cfg.dataDir} 0755 booklore booklore -"
			"d ${cfg.booksDir} 0755 booklore booklore -"
			"d ${cfg.bookdropDir} 0755 booklore booklore -"

			# Bind mount targets, should maybe set these up to expire or remove themselves
			# It's lame that booklore has hard coded paths for these
			"d /app 0755 root root -"
			"d /app/data 0755 booklore booklore -"
			"d /books 0755 booklore booklore -"
			"d /bookdrop 0755 booklore booklore -"
		];


    systemd.services.booklore-api = {
      description = "Booklore API";
      wantedBy = [ "multi-user.target" ];
      inherit (cfg) after wants;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/booklore-api";
				BindPaths = [
					"${cfg.dataDir}:/app/data"
					"${cfg.booksDir}:/books"
					"${cfg.bookdropDir}:/bookdrop"
				];
      };
      environment = {
        TZ = "Etc/UTC";
        DATABASE_URL = cfg.database.jdbcUrl;
        DATABASE_USERNAME = cfg.database.user;
        DATABASE_PASSWORD = cfg.database.password;
        SWAGGER_ENABLED = "false";
        FORCE_DISABLE_OIDC = "false";
      };
    };
  };
}

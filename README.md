# Nix Booklore
[Booklore](https://github.com/booklore-app/booklore) is a:
> self-hosted web app for organizing and managing your personal book collection. It provides an intuitive interface to browse, read, and track your progress across PDFs and eBooks. With robust metadata management, multi-user support, and a sleek, modern UI, BookLore makes it easy to build and explore your personal library.

[Nix](https://nixos.org/) is a:
> tool that takes a unique approach to package management and system configuration by making builds reproducible, declarative, and reliable.

# The services

This repository hosts the source for two systemd services:
1. The booklore API
2. The booklore Frontend Webapp

that compose the application. These then interact with:

1. A MariaDB database (for the backend api)
2. NGINX (for routing both services through a single port)

# Getting started

`./nixos/vm-test.nix` contains an example of the minimum config needed for booklore on your system.

You can run a full VM with a working instance of booklore with the following commands:

```bash
make vm
./result/bin/run-booklore-vm-vm
```

Basically, you will need:

```nix
{
    services = {
		booklore = {
			enable = true;
			database.password = "secret";
		};
    };
}
```

**Currently there are some issues with port configuration because of the upstream repository, so currently the configuration requires the ports:**

- 6060
- 7070
- 8080

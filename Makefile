default:
	make deps
	make vm
vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm
ui:
	nix build .#booklore-ui
api:
	nix build .#booklore-api
deps:
	"$$(nix build .#booklore-api.mitmCache.updateScript --print-out-paths)"
lint:
	nix run nixpkgs#statix -- fix
hash:
	nix-prefetch-url --unpack --print-path https://github.com/booklore-app/BookLore/archive/v1.14.1.tar.gz

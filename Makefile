vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm
ui:
	nix build .#booklore-ui
api:
	nix build .#booklore-api
deps:
	"$$(nix build .#booklore-api.mitmCache.updateScript --print-out-paths)"
lint:
	nix run nixpkgs#statix -- check

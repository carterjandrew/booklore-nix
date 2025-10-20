default:
	make deps.json
	make result
result:
	nix build .#booklore-api
deps.json:
	nix build .#booklore-api.mitmCache.updateScript
	./result
vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm

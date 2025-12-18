{ 
	lib,
	fetchFromGitHub,
	buildNpmPackage,
	makeWrapper,
	nodejs,
	nodePackages,
	stdenv,
	sha256,
	version
}:

buildNpmPackage (finalAttrs: {
  inherit version;
  pname = "booklore-ui";

  src = fetchFromGitHub {
		inherit sha256;
		rev = version;
    owner = "booklore-app";
    repo = "booklore";
  };

  sourceRoot = "${finalAttrs.src.name}/booklore-ui";

  npmDepsHash = "sha256-DEC67N9ArHpM5cR+l1gYkt3pQy1C5EH2jq9e/05qdDA=";

  npmPackFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper ];

	npmFlags = [ "--legacy-peer-deps" ];

	buildPhase = ''
		npm run build --configuration=production
	'';

  meta = {
    description = "Web UI for Booklore";
    homepage = "https://github.com/booklore-app/booklore/tree/develop";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ carter ];
  };
})

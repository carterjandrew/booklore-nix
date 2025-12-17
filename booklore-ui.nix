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

buildNpmPackage (_finalAttrs: {
  inherit version;
  pname = "booklore-ui";

  src = fetchFromGitHub {
		inherit sha256;
		rev = version;
    owner = "booklore-app";
    repo = "booklore";
  };

  sourceRoot = "${_finalAttrs.src.name}/booklore-ui";

  npmDepsHash = "sha256-DEC67N9ArHpM5cR+l1gYkt3pQy1C5EH2jq9e/05qdDA=";

  npmPackFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    nodejs
    nodePackages.http-server
  ];

	buildPhase = ''
		npm run build --configuration=production
	'';


  installPhase = ''
    	  runHook preInstall

    	  mkdir -p $out/bin
    	  mkdir -p $out/share
    	  mkdir -p $out/share/booklore-ui
          cp -r dist/booklore/browser/* $out/share/booklore-ui/
    	  makeWrapper ${nodePackages.http-server}/bin/http-server \
    	  $out/bin/booklore-ui \
    	  --add-flags "$out/share/booklore-ui" \
    	  --add-flags "-p 6060"

    	  runHook postInstall
    	'';

  meta = {
    description = "Web UI for Booklore";
    homepage = "https://github.com/booklore-app/booklore/tree/develop";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ carter ];
  };
})

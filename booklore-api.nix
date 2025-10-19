{
  stdenv,
  fetchFromGitHub,
  yq-go,
  gradle_9,
  jdk25,
  temurin-jre-bin-25,
  makeWrapper,
}: let

  gradle = gradle_9.override { java = jdk25; };

  version = "v1.6.0";

  _src = fetchFromGitHub {
    owner = "booklore-app";
    repo = "booklore";
    rev = "v1.6.0";
    sha256 = "0c369fl6wds75kync2kgjm1z1777rbbnlsk9z606lgicqv4akw4v";
  };

  self = stdenv.mkDerivation (_finalAttrs:{
    pname = "booklore-api";
    inherit version;

	src = _src;

	sourceRoot = "${_src.name}/booklore-api";

	nativeBuildInputs = [ gradle makeWrapper yq-go ];
  
    mitmCache = gradle.fetchDeps {
      pkg = self;
  	  data = ./deps.json;
    };

	gradleBuildTask = "clean build -x test";

	doCheck = true;

	postPatch = ''
	  export APP_VERSION=${version}
      yq eval '.app.version = strenv(APP_VERSION)' -i src/main/resources/application.yaml
	'';

	installPhase = ''
      mkdir -p $out/{bin,share/booklore-api}
      cp build/libs/booklore-api-0.0.1-SNAPSHOT.jar $out/share/booklore-api/booklore-api-all.jar

      makeWrapper ${temurin-jre-bin-25}/bin/java $out/bin/booklore-api \
        --add-flags "-jar $out/share/booklore-api/booklore-api-all.jar"
    '';
  });
in
  self

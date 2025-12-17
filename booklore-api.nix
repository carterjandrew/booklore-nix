{
	rev,
	hash,
  version,
	lib,
  stdenv,
  makeWrapper,
  fetchFromGitHub,
  yq-go,
	jdk21,
  jdk25,
  gradle_9,
  temurin-jre-bin-25,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "booklore-api";

  gradle = gradle_9.override {
		java = jdk25;
		javaToolchains = [ jdk21 ];
	};

  src = fetchFromGitHub {
		inherit rev hash;
    owner = "booklore-app";
    repo = "booklore";
  };

  sourceRoot = "${finalAttrs.src.name}/booklore-api";

  nativeBuildInputs = [
    yq-go
    makeWrapper
    finalAttrs.gradle
  ];

	# Required for mtimCache on Darwin
	__darwinAllowLocalNetworking = true;

  mitmCache = finalAttrs.gradle.fetchDeps {
		pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

	meta.sourceProvenance = with lib.sourceTypes; [
    fromSource
    binaryBytecode # mitm cache
  ];

	gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleBuildTask = "clean build -x test";

  doCheck = true;

	# Copied from booklores docker build instructions
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
})

{
	sha256,
  version,
	lib,
  stdenv,
  makeWrapper,
  fetchFromGitHub,
  yq-go,
  jdk21,
  gradle,
  temurin-jre-bin-21,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "booklore-api";

  gradle = gradle.override {
		java = jdk21;
		javaToolchains = [ jdk21 ];
	};

  src = fetchFromGitHub {
		inherit sha256;
		rev = version;
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

  gradleBuildTask = "clean build -x test --stacktrace";

  doCheck = true;

	# Copied from booklores docker build instructions
  postPatch = ''
    			export APP_VERSION=${version}
    			yq eval '.app.version = strenv(APP_VERSION)' -i src/main/resources/application.yaml
    		'';

  installPhase = ''
    			mkdir -p $out/{bin,share/booklore-api}
    			cp build/libs/booklore-api-0.0.1-SNAPSHOT.jar $out/share/booklore-api/booklore-api-all.jar
    			makeWrapper ${temurin-jre-bin-21}/bin/java $out/bin/booklore-api \
    			--add-flags "-jar $out/share/booklore-api/booklore-api-all.jar"
    		'';
})

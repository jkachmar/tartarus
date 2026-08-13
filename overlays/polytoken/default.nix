{ lib
, stdenv
, fetchurl
, unzip
, installShellFiles
, versionCheckHook
# release channel
, channel ? "latest"
}:

let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  version = sources.${channel}
    or (throw "polytoken: unknown channel `${channel}` (expected `latest` or `stable`)");

  releases = sources.versions.${version}
    or (throw "polytoken: no `sources.json` entry for version `${version}`");

  release = releases.${stdenv.hostPlatform.system}
    or (throw "polytoken: no `sources.json` entry for `${stdenv.hostPlatform.system}`");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "polytoken";
  inherit version;

  src = fetchurl {
    url = "https://dl.polytoken.dev/${finalAttrs.version}/${release.platform}/polytoken.zip";
    inherit (release) hash;
  };

  nativeBuildInputs = [ unzip installShellFiles ];
  sourceRoot = ".";

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${finalAttrs.meta.mainProgram} $out/bin/${finalAttrs.meta.mainProgram}

    installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
      --bash <(./${finalAttrs.meta.mainProgram} completions bash) \
      --zsh <(./${finalAttrs.meta.mainProgram} completions zsh) \
      --fish <(./${finalAttrs.meta.mainProgram} completions fish)

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = ./update.py;

  meta = {
    description = "Polytoken CLI";
    homepage = "https://docs.polytoken.dev";
    downloadPage = "https://docs.polytoken.dev/installation/downloads/";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames releases;
    mainProgram = "polytoken";
  };
})

{
  # custom args
  name,
  appname ? name,
  version,
  src,
  description,
  homepage,
  postInstall ? "",
  sourceRoot ? ".",
  plistArrayArgs ? ''
    <string>-data</string>
    <string>${builtins.getEnv "HOME"}/.nix-data/${name}</string>
  '',
  # nix supplied
  pkgs,
  ...
}:

pkgs.callPackage ./app.nix {
  name = name;
  appname = appname;
  version = version;
  src = src;
  sourceRoot = sourceRoot;
  description = description;
  homepage = homepage;
  postInstall = postInstall + ''
    INFO=$out/Applications/${appname}.app/Contents/Info.plist
    substituteInPlace $INFO --replace "</array>" "${plistArrayArgs}</array>"
  '';
}

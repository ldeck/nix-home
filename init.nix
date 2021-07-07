with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    niv
  ];
}
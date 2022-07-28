{
  description = "Updated SoapUI derivation";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages.x86_64-linux = {
      soapui = pkgs.callPackage ./derivation.nix {};
      default = self.packages.x86_64-linux.soapui;
    };
  };
}

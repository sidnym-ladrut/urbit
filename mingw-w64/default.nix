{ nixpkgs, arch }:
let
  host = "${arch}-w64-mingw32";

  os = "windows";

  gyp_os = "win";

  binutils = import ./binutils { inherit nixpkgs arch; };

  mingw-w64 = rec {
    name = "mingw-w64-${version}";
    version = "5.0.0";
    src = nixpkgs.fetchurl {
      url = "mirror://sourceforge/mingw-w64/mingw-w64-v${version}.tar.bz2";
      sha256 = "023d14dnd5638cqpz1vkmr67731rzk99xsgbr0al4az276kqq7g4";
    };
    patches = [ ./popcnt.patch ];
  };

  mingw-w64_headers = nixpkgs.stdenv.mkDerivation {
    name = "${mingw-w64.name}-headers";
    inherit (mingw-w64) src patches;
    preConfigure = "cd mingw-w64-headers";
    configureFlags = "--without-crt";
  };

  gcc_stage_1 = import ./gcc {
    stage = 1;
    libc = mingw-w64_headers;
    inherit nixpkgs arch binutils;
  };

  mingw-w64_crt_and_headers = nixpkgs.stdenv.mkDerivation {
    name = "${mingw-w64.name}-${host}";
    inherit (mingw-w64) src patches;
    buildInputs = [ binutils gcc_stage_1 ];
    preConfigure = "export CC=;";   # The stdenv sets CC=gcc and mingw-w64-crt tries to use that.
    configureFlags = "--host=${host}";
    dontStrip = true;
  };

  gcc = import ./gcc {
    libc = mingw-w64_crt_and_headers;
    inherit nixpkgs arch binutils;
  };

  cmake_toolchain = import ../cmake_toolchain {
    cmake_system_name = "Windows";
    inherit nixpkgs host;
  };

in
{
  # Target info
  inherit host arch os;

  # Toolchain
  inherit gcc binutils mingw-w64_crt_and_headers;

  # nixpkgs: a wide variety of programs and build tools
  inherit nixpkgs;

  # Expressions used to bootstrap the toolchain, not normally needed.
  inherit mingw-w64 mingw-w64_headers gcc_stage_1;

  # Support for various build tools
  inherit cmake_toolchain gyp_os;
}

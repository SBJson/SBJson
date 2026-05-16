# AFL++ on macOS via Nix
#
# Commands:
#   nix-shell                         -- shell with afl-fuzz, afl-cc, etc. on PATH
#   nix-shell --command "afl-fuzz -V"  -- run one-off command
#   nix-build                          -- builds and creates ./result symlink
#
# The nixpkgs derivation only targets Linux (QEMU user-mode, cgroups, etc.).
# This one strips those Linux-only features and builds the core fuzzer + LLVM
# instrumentation, which work fine on macOS.

{ pkgs ? import <nixpkgs> { } }:

let
  version = "4.34c";

  src = pkgs.fetchFromGitHub {
    owner = "AFLplusplus";
    repo = "AFLplusplus";
    tag = "v${version}";
    hash = "sha256-ymHt746cuZ+jyWs0vB3R1qNgpgAu6pUVXp9/g9Km9JI=";
  };

  aflplusplus = pkgs.stdenv.mkDerivation {
    pname = "aflplusplus";
    inherit version src;

    enableParallelBuilding = true;

    nativeBuildInputs = with pkgs; [ makeWrapper which ];

    buildInputs = with pkgs; [
      clang
      llvm
      llvmPackages.bintools
      python3
      gmp
    ];

    hardeningDisable = [ "fortify" ];

    postPatch = ''
      substituteInPlace src/afl-cc.c \
        --replace-fail "CLANGPP_BIN" '"${pkgs.clang}/bin/clang++"' \
        --replace-fail "CLANG_BIN" '"${pkgs.clang}/bin/clang"' \
        --replace-fail '"gcc"' '"${pkgs.gcc}/bin/gcc"' \
        --replace-fail '"g++"' '"${pkgs.gcc}/bin/g++"' \
        --replace-fail 'getenv("AFL_PATH")' '(getenv("AFL_PATH") ? getenv("AFL_PATH") : "$out/lib/afl")' \
        --replace-fail '#ifndef "${pkgs.clang}/bin/clang"' '#ifndef CLANG_BIN'

      substituteInPlace src/afl-ld-lto.c \
        --replace-fail 'LLVM_BINDIR' '"/nixpkgs-patched-does-not-exist"'

      sed -i 's|LLVM_BINDIR = .*|LLVM_BINDIR = |' utils/aflpp_driver/GNUmakefile
      substituteInPlace utils/aflpp_driver/GNUmakefile \
        --replace-fail 'LLVM_BINDIR = ' 'LLVM_BINDIR = ${pkgs.clang}/bin/'

      substituteInPlace GNUmakefile.llvm \
        --replace-fail "\''$(LLVM_BINDIR)/clang" "${pkgs.clang}/bin/clang"
    '';

    env.NIX_CFLAGS_COMPILE = toString (
      pkgs.lib.optionals (pkgs.stdenv.cc.isGcc or false) [ "-Wno-error=use-after-free" ]
    );

    makeFlags = [
      "PREFIX=${placeholder "out"}"
      "USE_BINDIR=0"
      "TEST_MMAP=1"
      "SHMAT_OK=0"
    ];

    # `make all` builds core tools + LLVM modes (includes LTO).
    # test_build fails on macOS (shmget test) but is ignored by Makefile.
    buildPhase = ''
      runHook preBuild

      # Build core + LLVM instrumentation
      make all $makeFlags -j$NIX_BUILD_CORES || true

      # Ensure LLVM runtime objects are built (make all calls GNUmakefile.llvm
      # but test_build failing may cause it to skip some targets)
      make -f GNUmakefile.llvm PROGS="$PROGS_ALWAYS" afl-compiler-rt.o afl-cc \
        $makeFlags -j$NIX_BUILD_CORES || true

      runHook postBuild
    '';

    # make install also triggers `all` as prerequisite, installs everything.
    installPhase = ''
      runHook preInstall
      make install $makeFlags -j$NIX_BUILD_CORES || true
      runHook postInstall
    '';

    postInstall = ''
      # Remove symlinks that could confuse xcodebuild
      rm -f $out/bin/afl-clang $out/bin/afl-clang++

      # Install LLVM runtime objects that make install missed
      mkdir -p $out/lib/afl
      for f in afl-compiler-rt.o afl-compiler-rt-32.o afl-compiler-rt-64.o \
               afl-llvm-pass.so afl-llvm-ijon-pass.so \
               afl-llvm-rt-lto*.o afl-llvm-lto-instrumentlist.so \
               SanitizerCoveragePCGUARD.so SanitizerCoverageLTO.so \
               cmplog-routines-pass.so cmplog-instructions-pass.so cmplog-switches-pass.so \
               split-compares-pass.so split-switches-pass.so \
               compare-transform-pass.so afl-llvm-dict2file.so injection-pass.so; do
        if [ -f "$f" ]; then
          install -m 755 "$f" "$out/lib/afl/"
        fi
      done

      # Also install any other .o, .so, .a that was missed
      for f in *.o *.so *.a; do
        if [ -f "$f" ] && [ ! -f "$out/lib/afl/$f" ]; then
          install -m 755 "$f" "$out/lib/afl/"
        fi
      done

      # Install afl-ld-lto (LTO linker wrapper) if built
      if [ -f ./afl-ld-lto ]; then
        install -m 755 ./afl-ld-lto $out/bin/
      fi

      # Create LLVM mode symlinks for afl-cc.
      # afl-cc selects instrumentation mode based on argv[0]:
      #   afl-clang-lto   -> LTO mode (best, clang 11+)
      #   afl-clang-fast  -> LLVM mode (fallback)
      ln -sf afl-cc $out/bin/afl-clang-fast
      ln -sf afl-cc $out/bin/afl-clang-fast++
      ln -sf afl-cc $out/bin/afl-clang-lto
      ln -sf afl-cc $out/bin/afl-clang-lto++
      ln -sf afl-cc $out/bin/afl-lto
      ln -sf afl-cc $out/bin/afl-lto++
      ln -sf afl-cc $out/bin/afl-c++

      patchShebangs $out/bin
    '';

    doInstallCheck = false;

    meta = {
      description = ''
        Heavily enhanced version of AFL, incorporating many features
        and improvements from the community
      '';
      homepage = "https://aflplus.plus";
      changelog = "https://aflplus.plus/docs/changelog";
      license = pkgs.lib.licenses.asl20;
      platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    };
  };
in

pkgs.mkShell {
  buildInputs = [ aflplusplus ];

  shellHook = ''
    # nix's setup hook sets DEVELOPER_DIR to a nix Apple SDK path
    # which breaks xcodebuild. Point it back at the real Xcode.
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
    # nix's CC/CXX wrappers don't understand Xcode-specific flags
    # like -index-store-path. Let xcodebuild use its own clang.
    unset CC CXX LD AR NM RANLIB STRIP OBJCOPY OBJDUMP SIZE STRINGS \
          NIX_CFLAGS_COMPILE NIX_LDFLAGS
    echo "AFL++ ${version} ready."
  '';
}

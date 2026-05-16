#!/usr/bin/env bash
#
# AFL++ fuzzing helper for sbjson.
#
# Run from within nix-shell:
#   ./fuzz.sh
#
# The script builds an instrumented sbjson binary, seeds from
# TestData/jsonchecker, and fires up afl-fuzz.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR=/tmp/sbjson-afl
SEEDS="$HERE/TestData/jsonchecker"
OUTPUT="$HERE/output"

# Find AFL++ -- either on PATH (nix-shell) or latest nix store build
AFL="$(dirname "$(dirname "$(which afl-clang-fast 2>/dev/null || true)")" 2>/dev/null)" || true
if [ -z "$AFL" ]; then
  AFL="$(ls -dt /nix/store/*-aflplusplus-4.34c 2>/dev/null | head -1)"
fi

if [ -z "$AFL" ] || [ ! -x "$AFL/bin/afl-clang-fast" ]; then
  echo "ERROR: can't find afl-clang-fast. Run from nix-shell."
  exit 1
fi

# xcodebuild may not be on PATH inside nix-shell (nix's xcbuild shim
# shadows the real one, and DEVELOPER_DIR/SDKROOT point to nix SDK
# paths). Use the real Xcode binary directly with env vars cleared,
# and use Xcode's own clang with AFL instrumentation flags instead of
# nix-wrapped afl-clang-fast.
XCODEBUILD="/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
XCODE_CC="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
AFL_LIB="$AFL/lib/afl"

# nix-shell exports tool vars that conflict with the real Xcode tools.
# Clear the compiler/linker wrappers but keep SDK paths so linking works.
unset CC CXX LD AR NM RANLIB STRIP OBJCOPY OBJDUMP SIZE STRINGS \
      DEVELOPER_DIR \
      NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_BINTOOLS \
      NIX_HARDENING_ENABLE NIX_ENFORCE_NO_NATIVE

echo "=== Building instrumented sbjson ==="
"$XCODEBUILD" -project "$HERE/SBJson5.xcodeproj" -scheme sbjson \
  CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
  CC="$XCODE_CC" \
  OTHER_CFLAGS="-fsanitize-coverage=trace-pc-guard" \
  OTHER_LDFLAGS="$AFL_LIB/afl-compiler-rt.o" \
  -quiet

echo ""
echo "=== Starting fuzzer ==="
echo "  binary: $BUILD_DIR/sbjson"
echo "  seeds:  $SEEDS"
echo "  output: $OUTPUT"
echo ""

exec afl-fuzz -i "$SEEDS" -o "$OUTPUT" -- "$BUILD_DIR/sbjson"

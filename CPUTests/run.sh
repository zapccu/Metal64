#!/bin/sh
#
# Build and run the CPU regression tests for the Metal64 headers.
# Usage: CPUTests/run.sh   (from any directory; uses $CXX or clang++)
#
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
CXX="${CXX:-clang++}"
OUT="${TMPDIR:-/tmp}/metal64_cputests"

# -ffp-contract=off: no FMA contraction, plain float32 arithmetic like Metal with fast math disabled
"$CXX" -std=c++17 -O2 -ffp-contract=off -fno-fast-math -Wno-unknown-pragmas \
    -I"$DIR" -I"$DIR/../Sources/Metal64/include" \
    "$DIR/test_metal64.cpp" -o "$OUT"

"$OUT"

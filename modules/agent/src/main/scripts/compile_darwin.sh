#!/usr/bin/env bash
set -euo pipefail

# Build JNI dylibs for macOS: x86_64 and arm64 (aarch64)
# Requires: Xcode command line tools / clang, a JDK (JAVA_HOME)

CC="${CC:-clang}"
CFLAGS="-O2 -fPIC -pthread -D_LP64=1"
INCLUDES=(-I "$JAVA_HOME/include" -I "$JAVA_HOME/include/darwin")

OUT_X86="target/native/darwin_x86_64"
OUT_ARM="target/native/darwin_aarch64"

mkdir -p "$OUT_X86" "$OUT_ARM"

echo "==> macOS x86_64"
$CC $CFLAGS "${INCLUDES[@]}" -c -arch x86_64 src/main/c/agent.c -o agent_x86_64.o
$CC -dynamiclib -arch x86_64 agent_x86_64.o -lc -o "$OUT_X86/libfaketime.dylib"
rm -f agent_x86_64.o

echo "==> macOS arm64"
$CC $CFLAGS "${INCLUDES[@]}" -c -arch arm64 src/main/c/agent.c -o agent_arm64.o
$CC -dynamiclib -arch arm64 agent_arm64.o -lc -o "$OUT_ARM/libfaketime.dylib"
rm -f agent_arm64.o

echo "done."

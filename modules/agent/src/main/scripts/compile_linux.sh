#!/usr/bin/env bash
set -euo pipefail

# Build JNI .so for Linux.
# - On x86_64 host: builds x86_32 and x86_64.
# - On aarch64 host: builds aarch64.
# - Cross mode: if LINUX_AARCH64_CROSS=true, build aarch64 on x86 using aarch64-linux-gnu-gcc.

CC="${CC:-gcc}"
CFLAGS_COMMON="-O2 -fPIC -pthread"
INCLUDES=(-I "$JAVA_HOME/include" -I "$JAVA_HOME/include/linux")

# ---------- Cross-compile path for linux aarch64 ----------
if [[ "${LINUX_AARCH64_CROSS:-}" == "true" ]]; then
  OUTARM="target/native/linux_aarch64"
  mkdir -p "$OUTARM"
  : "${CC:=aarch64-linux-gnu-gcc}"
  echo "==> Linux aarch64 (cross; CC=$CC)"
  $CC $CFLAGS_COMMON -D_LP64=1 "${INCLUDES[@]}" -c src/main/c/agent.c -o agent_aarch64.o
  $CC -shared -Wl,-z,defs -static-libgcc agent_aarch64.o -lc -o "$OUTARM/libfaketime.so"
  rm -f agent_aarch64.o
  echo "done (cross)."
  exit 0
fi
# ----------------------------------------------------------

ARCH="$(uname -m || true)"

if [[ "${ARCH}" == "x86_64" ]]; then
  OUT32="target/native/linux_x86_32"
  OUT64="target/native/linux_x86_64"
  mkdir -p "$OUT32" "$OUT64"

  echo "==> Linux x86_32"
  if ! echo 'int main(){}' | $CC -m32 -x c - -o /dev/null >/dev/null 2>&1; then
    echo "WARNING: 32-bit toolchain not available; skipping linux_x86_32." >&2
  else
    $CC -m32 $CFLAGS_COMMON "${INCLUDES[@]}" -c src/main/c/agent.c -o agent_x86_32.o
    $CC -m32 -shared -Wl,-z,defs -static-libgcc agent_x86_32.o -lc -o "$OUT32/libfaketime.so"
    rm -f agent_x86_32.o
  fi

  echo "==> Linux x86_64"
  $CC -m64 $CFLAGS_COMMON -D_LP64=1 "${INCLUDES[@]}" -c src/main/c/agent.c -o agent_x86_64.o
  $CC -m64 -shared -Wl,-z,defs -static-libgcc agent_x86_64.o -lc -o "$OUT64/libfaketime.so"
  rm -f agent_x86_64.o

elif [[ "${ARCH}" == "aarch64" ]]; then
  OUTARM="target/native/linux_aarch64"
  mkdir -p "$OUTARM"

  echo "==> Linux aarch64 (native)"
  $CC $CFLAGS_COMMON -D_LP64=1 "${INCLUDES[@]}" -c src/main/c/agent.c -o agent_aarch64.o
  $CC -shared -Wl,-z,defs -static-libgcc agent_aarch64.o -lc -o "$OUTARM/libfaketime.so"
  rm -f agent_aarch64.o
else
  echo "ERROR: Unsupported Linux host arch '${ARCH}'. Supported: x86_64, aarch64." >&2
  exit 1
fi

echo "done."

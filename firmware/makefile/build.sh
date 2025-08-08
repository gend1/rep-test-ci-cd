#!/usr/bin/env bash
set -euo pipefail

echo "$(date +%T)"
echo "================================================================"
echo "Compiling in process.."
echo "================================================================"

# Remove old outputs (ignore errors)
rm -f *.o.map *.o.s *.o *.map *.axf *.axf.map *.axf.s *.axf.bin *.axf.bin.ntl00 *.log || true

# Settings
ARCH=arm-none-eabi
AS="${ARCH}-as"
CC="${ARCH}-gcc"
OBJCOPY="${ARCH}-objcopy"
OBJFILE=main.o
INCLUDEPATH="-I../src/sys"
MARCH="-march=armv5te -g"
CFLAGS="-Os"

# Assemble
$AS $MARCH -c ../src/sys/start.s -o start.o || { echo "[ERROR] The assembly failed."; exit 1; }

# Compile
$CC $MARCH $CFLAGS $INCLUDEPATH -c ../src/sys/main.c -o "$OBJFILE" || { echo "[ERROR] Compiling failed."; exit 1; }

# Release link
$CC $MARCH $CFLAGS $INCLUDEPATH -T linker_script.release.ld -o release.axf start.o "$OBJFILE" -nostdlib || { echo "[ERROR release] Linking failed."; exit 1; }
$OBJCOPY release.axf -O binary release.axf.bin || { echo "[ERROR release] Conversion to binary failed."; exit 1; }

# Debug link
$CC $MARCH $CFLAGS $INCLUDEPATH -T linker_script.debug.ld -o debug.axf start.o "$OBJFILE" -nostdlib || { echo "[ERROR debug] Linking failed."; exit 1; }
$OBJCOPY debug.axf -O binary debug.axf.bin || { echo "[ERROR debug] Conversion to binary failed."; exit 1; }

echo "================================================================"
echo "Assembly completed successfully!"
echo "release.axf      (ELF)"
echo "release.axf.bin  (binary image)"
echo "debug.axf        (ELF)"
echo "debug.axf.bin    (binary image)"
echo "================================================================"

# Run auxiliary scripts (если они существуют и исполняемы в bash)
/bin/bash -c "./.remap" || echo "[Warning] .remap failed"
 /bin/bash -c "./.reasm" || echo "[Warning] .reasm failed"
 /bin/bash -c "./r.ntl00" || echo "[Warning] r.ntl00 failed"

echo "$(date +%T)"

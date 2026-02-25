#!/usr/bin/env bash
# flash.sh - Flash firmware to STM32 via ST-LINK using openocd
# Usage: flash.sh <firmware> [openocd.cfg]
# Exit 0: flash + verify succeeded
# Exit 1: error

set -euo pipefail

FIRMWARE="${1:-}"
CONFIG="${2:-openocd.cfg}"
OPENOCD_BIN="${OPENOCD_PATH:-openocd}"

# ---- Validation ----

if [ -z "$FIRMWARE" ]; then
    echo "Usage: flash.sh <firmware> [openocd.cfg]"
    echo ""
    echo "Arguments:"
    echo "  <firmware>     Path to .elf, .hex, or .bin file (required)"
    echo "  [openocd.cfg]  Path to openocd config (default: ./openocd.cfg)"
    echo ""
    echo "Examples:"
    echo "  flash.sh build/firmware.elf"
    echo "  flash.sh build/firmware.elf /path/to/openocd.cfg"
    echo "  flash.sh build/output.hex"
    echo "  flash.sh build/output.bin"
    exit 1
fi

if [ ! -f "$FIRMWARE" ]; then
    echo "ERROR: Firmware file not found: $FIRMWARE" >&2
    exit 1
fi

if [ ! -f "$CONFIG" ]; then
    echo "ERROR: openocd config not found: $CONFIG" >&2
    echo "" >&2
    echo "Generate one with:" >&2
    echo "  ~/.claude/skills/stm32-stlink/scripts/generate_config.sh <family>" >&2
    echo "  (e.g., generate_config.sh f4)" >&2
    exit 1
fi

if ! command -v "$OPENOCD_BIN" &>/dev/null; then
    echo "ERROR: openocd not found. Run check_tools.sh for install instructions." >&2
    exit 1
fi

# ---- Determine firmware format ----

EXT="${FIRMWARE##*.}"
EXT="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"

case "$EXT" in
    elf)
        FORMAT_NOTE="ELF (load addresses embedded in file)"
        PROGRAM_CMD="program $FIRMWARE verify reset exit"
        ;;
    hex)
        FORMAT_NOTE="Intel HEX (addresses embedded in file)"
        PROGRAM_CMD="program $FIRMWARE verify reset exit"
        ;;
    bin)
        FORMAT_NOTE="Raw binary (loading at STM32 flash start: 0x08000000)"
        PROGRAM_CMD="program $FIRMWARE verify reset exit 0x08000000"
        ;;
    *)
        echo "ERROR: Unrecognized firmware extension: .$EXT" >&2
        echo "Supported formats: .elf, .hex, .bin" >&2
        exit 1
        ;;
esac

# ---- Flash ----

echo "=== STM32 Firmware Flash ==="
echo "Firmware : $FIRMWARE"
echo "Format   : $FORMAT_NOTE"
echo "Config   : $CONFIG"
echo "OpenOCD  : $(command -v "$OPENOCD_BIN")"
echo ""
echo "Flashing..."
echo ""

# openocd writes progress to stderr; merge to stdout for clean display
if "$OPENOCD_BIN" -f "$CONFIG" -c "$PROGRAM_CMD" 2>&1; then
    echo ""
    echo "=== Flash Result: SUCCESS ==="
    echo "Firmware verified and target reset."
    exit 0
else
    OPENOCD_EXIT=$?
    echo ""
    echo "=== Flash Result: FAILED (openocd exit code $OPENOCD_EXIT) ===" >&2
    echo ""
    echo "Common fixes:" >&2
    echo "  - Check that the ST-LINK is connected and target is powered" >&2
    echo "  - Verify openocd.cfg is correct for your chip family" >&2
    echo "  - Run detect_device.sh to identify the chip and regenerate the config" >&2
    echo "  - For .bin files: binary is loaded at 0x08000000 by default" >&2
    echo "  - Close STM32CubeIDE or other tools that may be holding the ST-LINK" >&2
    exit 1
fi

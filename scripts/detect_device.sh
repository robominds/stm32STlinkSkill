#!/usr/bin/env bash
# detect_device.sh - Detect connected ST-LINK and identify STM32 target
# Prints ST-LINK version, target IDCODE, and suggested openocd target config
# Exit 0: device found
# Exit 1: device not found or error

set -euo pipefail

OPENOCD_BIN="${OPENOCD_PATH:-openocd}"

if ! command -v "$OPENOCD_BIN" &>/dev/null; then
    echo "ERROR: openocd not found. Run check_tools.sh for install instructions." >&2
    exit 1
fi

# Locate openocd scripts directory
find_openocd_scripts() {
    for candidate in \
        "/opt/homebrew/share/openocd/scripts" \
        "/usr/local/share/openocd/scripts" \
        "/usr/share/openocd/scripts" \
        "/usr/share/openocd"; do
        if [ -d "$candidate/interface" ]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

OPENOCD_SCRIPTS=""
if OPENOCD_SCRIPTS="$(find_openocd_scripts)"; then
    SCRIPTS_ARG="-s $OPENOCD_SCRIPTS"
else
    SCRIPTS_ARG=""
    echo "WARNING: Could not locate openocd scripts directory. Using openocd default search path." >&2
fi

echo "=== ST-LINK Device Detection ==="
echo ""
echo "Probing for connected ST-LINK..."
echo ""

TMPFILE="$(mktemp /tmp/openocd_detect_XXXXXX.log)"
trap 'rm -f "$TMPFILE"' EXIT

# Run openocd: init, scan_chain, then shut down
# shellcheck disable=SC2086
if ! "$OPENOCD_BIN" $SCRIPTS_ARG \
    -f interface/stlink.cfg \
    -c "transport select hla_swd" \
    -c "init" \
    -c "scan_chain" \
    -c "shutdown" \
    > "$TMPFILE" 2>&1; then

    echo "ERROR: Could not connect to ST-LINK." >&2
    echo ""
    echo "--- OpenOCD output ---"
    cat "$TMPFILE"
    echo "--- End of output ---"
    echo ""
    echo "Possible causes:"
    echo "  - ST-LINK not connected over USB"
    echo "  - Target board not powered"
    echo "  - Another process is using the ST-LINK (close STM32CubeIDE, CubeProgrammer, etc.)"
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "  - macOS: check System Preferences > Security & Privacy for blocked USB driver"
    else
        echo "  - Linux: check udev rules (see references/installation.md)"
    fi
    exit 1
fi

echo "--- OpenOCD Detection Output ---"
cat "$TMPFILE"
echo "--- End ---"
echo ""

# Map IDCODE to STM32 family
# IDCODE structure: bits[31:28]=version, bits[27:12]=part number, bits[11:1]=manufacturer, bit[0]=1
# We match on the full hex IDCODE reported by openocd
identify_family() {
    local idcode_hex="${1,,}"  # lowercase

    # Cortex-M debug port IDCODEs commonly seen with STM32 families
    case "$idcode_hex" in
        # Cortex-M0 DAP (used by STM32F0)
        0x0bb11477) echo "STM32F0x (Cortex-M0) -> use: generate_config.sh f0" ;;
        # Cortex-M3 DAP (used by STM32F1, F2, L1)
        0x1ba01477|0x3ba01477|0x2ba01477)
            echo "STM32F1x/F2x/L1x (Cortex-M3) -> use: generate_config.sh f1 or f2 or l1"
            echo "  (Check chip marking to determine exact family)"
            ;;
        # Cortex-M4 DAP (used by STM32F3, F4, G4, L4, WBx M4 core)
        0x1ba02477|0x2ba02477|0x0ba02477)
            echo "STM32F3x/F4x/G4x/L4x (Cortex-M4F) -> use: generate_config.sh f4 (most common)"
            echo "  (Check chip marking to determine exact family)"
            ;;
        # Cortex-M7 DAP (used by STM32F7, H7)
        0x1ba04477|0x2ba04477|0x0ba04477)
            echo "STM32F7x/H7x (Cortex-M7) -> use: generate_config.sh f7 or h7"
            echo "  (Check chip marking to determine exact family)"
            ;;
        # Cortex-M0+ DAP (used by STM32G0, L0, WBx M0+ core)
        0x0bc11477|0x0bb11477)
            echo "STM32G0x/L0x (Cortex-M0+) -> use: generate_config.sh g0 or l0"
            ;;
        # Cortex-M33 DAP (used by STM32L5, U5)
        0x0ba04477|0x6ba00477)
            echo "STM32L5x/U5x (Cortex-M33) -> use: generate_config.sh l5 or u5"
            ;;
        *)
            echo "Unknown IDCODE: $idcode_hex"
            echo "  Check the openocd output above for 'idcode' lines."
            echo "  Cross-reference with references/openocd-targets.md"
            ;;
    esac
}

# Parse key info from openocd output
STLINK_VER="$(grep -oiE 'ST-LINK[[:space:]]*(V[0-9]+(-[0-9]+)?)' "$TMPFILE" | head -1 || echo "unknown")"
VOLTAGE="$(grep -oE 'Target voltage: [0-9.]+' "$TMPFILE" | head -1 || echo "")"
IDCODE_LINE="$(grep -iE 'idcode[[:space:]]+0x[0-9a-f]+' "$TMPFILE" | head -1 || echo "")"
IDCODE_HEX="$(echo "$IDCODE_LINE" | grep -oE '0x[0-9a-fA-F]+' | head -1 || echo "")"

echo "=== Device Summary ==="
[ -n "$STLINK_VER" ] && echo "ST-LINK version : $STLINK_VER"
[ -n "$VOLTAGE" ]    && echo "$VOLTAGE"

if [ -n "$IDCODE_HEX" ]; then
    echo "Target IDCODE   : $IDCODE_HEX"
    echo "Identified as   : $(identify_family "$IDCODE_HEX")"
else
    echo ""
    echo "Could not extract target IDCODE from openocd output."
    echo "Check the raw output above for 'idcode' or 'tap' lines."
    echo "Cross-reference with references/openocd-targets.md"
fi

echo ""
echo "Next step: generate an openocd.cfg for your chip:"
echo "  ~/.claude/skills/stm32-stlink/scripts/generate_config.sh <family>"
echo "  (e.g., generate_config.sh f4)"

exit 0

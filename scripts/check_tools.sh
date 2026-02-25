#!/usr/bin/env bash
# check_tools.sh - Verify STM32 toolchain is installed
# Exit 0: all required tools found
# Exit 1: one or more required tools missing (install instructions printed)

set -euo pipefail

REQUIRED_MISSING=0

# Terminal colors (suppressed if not a tty)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    GREEN='' RED='' YELLOW='' NC=''
fi

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

check_tool() {
    local name="$1"
    local binary="$2"

    if command -v "$binary" &>/dev/null; then
        local path
        path="$(command -v "$binary")"
        local version
        version="$("$binary" --version 2>&1 | head -1)" || version="(version unknown)"
        printf "${GREEN}[OK]${NC}      %s\n" "$name"
        printf "          Path:    %s\n" "$path"
        printf "          Version: %s\n" "$version"
        return 0
    else
        printf "${RED}[MISSING]${NC} %s (%s)\n" "$name" "$binary"
        return 1
    fi
}

OS="$(detect_os)"

echo "=== STM32 Toolchain Check ==="
echo "OS: $OS"
echo ""

# Check openocd
if ! check_tool "OpenOCD" "openocd"; then
    REQUIRED_MISSING=1
    echo ""
    printf "${YELLOW}Install openocd:${NC}\n"
    if [ "$OS" = "macos" ]; then
        echo "  brew install openocd"
    elif [ "$OS" = "linux" ]; then
        echo "  sudo apt install openocd         # Debian/Ubuntu"
        echo "  sudo dnf install openocd         # Fedora/RHEL"
        echo "  sudo pacman -S openocd           # Arch"
    fi
fi

echo ""

# Check arm-none-eabi-gdb (may also be gdb-multiarch on Linux)
GDB_BINARY=""
if command -v arm-none-eabi-gdb &>/dev/null; then
    GDB_BINARY="arm-none-eabi-gdb"
elif command -v gdb-multiarch &>/dev/null; then
    GDB_BINARY="gdb-multiarch"
fi

if [ -n "$GDB_BINARY" ]; then
    check_tool "ARM GDB ($GDB_BINARY)" "$GDB_BINARY"
else
    printf "${RED}[MISSING]${NC} ARM GDB (arm-none-eabi-gdb or gdb-multiarch)\n"
    REQUIRED_MISSING=1
    echo ""
    printf "${YELLOW}Install ARM GDB:${NC}\n"
    if [ "$OS" = "macos" ]; then
        echo "  brew install gcc-arm-embedded"
        echo "  # or: brew install --cask gcc-arm-embedded"
    elif [ "$OS" = "linux" ]; then
        echo "  sudo apt install gcc-arm-none-eabi gdb-multiarch   # Debian/Ubuntu"
        echo "  sudo dnf install arm-none-eabi-gcc-cs              # Fedora/RHEL"
        echo "  sudo pacman -S arm-none-eabi-gcc                   # Arch"
    fi
fi

echo ""

# Check arm-none-eabi-gcc (optional — needed to compile, not just flash/debug)
if command -v arm-none-eabi-gcc &>/dev/null; then
    check_tool "ARM GCC (compiler)" "arm-none-eabi-gcc"
else
    printf "${YELLOW}[INFO]${NC}    arm-none-eabi-gcc not found\n"
    echo "          (Not required for flash/debug, but needed to compile firmware)"
    if [ "$OS" = "macos" ]; then
        echo "          Install: brew install gcc-arm-embedded"
    elif [ "$OS" = "linux" ]; then
        echo "          Install: sudo apt install gcc-arm-none-eabi"
    fi
fi

echo ""

# macOS: check libusb (needed for openocd USB access)
if [ "$OS" = "macos" ]; then
    if [ -f "/opt/homebrew/lib/libusb-1.0.dylib" ] || \
       [ -f "/usr/local/lib/libusb-1.0.dylib" ] || \
       find /opt/homebrew /usr/local -name "libusb*.dylib" -maxdepth 4 2>/dev/null | grep -q .; then
        printf "${GREEN}[OK]${NC}      libusb (USB device access)\n"
    else
        printf "${YELLOW}[WARN]${NC}    libusb not found at expected Homebrew paths\n"
        echo "          Install: brew install libusb"
        echo "          (OpenOCD may have bundled libusb — try connecting a device to test)"
    fi
    echo ""
fi

echo "=== Summary ==="
if [ "$REQUIRED_MISSING" -eq 0 ]; then
    printf "${GREEN}All required tools are installed. Ready to use.${NC}\n"
    exit 0
else
    printf "${RED}One or more required tools are missing. Install them before proceeding.${NC}\n"
    exit 1
fi

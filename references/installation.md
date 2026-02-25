# STM32 Toolchain Installation Guide

Installation guide for OpenOCD and the ARM GNU toolchain on macOS and Linux.

---

## macOS (Homebrew)

### Install Homebrew (if not installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install OpenOCD

```bash
brew install openocd
```

Verify:
```bash
openocd --version
# Expected: Open On-Chip Debugger 0.12.0 (or newer)
```

### Install ARM GNU Toolchain (GCC + GDB)

```bash
brew install gcc-arm-embedded
```

This installs:
- `arm-none-eabi-gcc` — C/C++ cross-compiler
- `arm-none-eabi-gdb` — GDB debugger for ARM targets
- `arm-none-eabi-objcopy`, `arm-none-eabi-size`, etc.

Verify:
```bash
arm-none-eabi-gdb --version
# Expected: GNU gdb (Arm GNU Toolchain ...) 14.x or newer

arm-none-eabi-gcc --version
# Expected: arm-none-eabi-gcc (Arm GNU Toolchain ...) 13.x or newer
```

### libusb (if needed)

OpenOCD uses libusb for USB access. It is normally installed as a dependency of OpenOCD. If you encounter USB errors:

```bash
brew install libusb
```

### macOS USB Permissions

On newer macOS, the ST-LINK USB device may require a security approval:

1. Connect the ST-LINK
2. Open System Preferences > Privacy & Security > General
3. Look for a message about a blocked system extension from ST Microelectronics
4. Click "Allow"

Also ensure no other application holds the ST-LINK open (STM32CubeIDE, STM32CubeProgrammer).

---

## Ubuntu / Debian Linux

### Install OpenOCD

```bash
sudo apt update
sudo apt install openocd
```

Verify:
```bash
openocd --version
```

### Install ARM GNU Toolchain

```bash
sudo apt install gcc-arm-none-eabi gdb-multiarch binutils-arm-none-eabi
```

> **Note:** On Ubuntu/Debian, the GDB binary is `gdb-multiarch`, not `arm-none-eabi-gdb`. The skill scripts handle both automatically.

Verify:
```bash
gdb-multiarch --version
arm-none-eabi-gcc --version
```

### USB Permissions (Linux — required)

By default, non-root users cannot access ST-LINK USB devices. Add udev rules:

```bash
sudo tee /etc/udev/rules.d/70-st-link.rules > /dev/null <<'EOF'
# ST-LINK V1
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3744", MODE="0666", GROUP="plugdev"
# ST-LINK V2
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666", GROUP="plugdev"
# ST-LINK V2-1 (on Nucleo boards)
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="plugdev"
# ST-LINK V3
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3754", MODE="0666", GROUP="plugdev"
EOF

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Add your user to the plugdev group
sudo usermod -aG plugdev "$USER"
# Log out and back in for group membership to take effect
```

Verify the device is visible after reconnecting:
```bash
lsusb | grep -i "0483"
# Should show: Bus ... ID 0483:374b STMicroelectronics ST-LINK/V2-1
```

---

## Fedora / RHEL / CentOS

```bash
# OpenOCD
sudo dnf install openocd

# ARM toolchain
sudo dnf install arm-none-eabi-gcc arm-none-eabi-newlib gdb

# udev rules — use the same rules as the Ubuntu section above
```

---

## Arch Linux

```bash
# OpenOCD
sudo pacman -S openocd

# ARM toolchain
sudo pacman -S arm-none-eabi-gcc arm-none-eabi-gdb arm-none-eabi-newlib

# udev rules — use the same rules as the Ubuntu section above
```

---

## Verifying the Full Setup

After installation, run the skill's check script:

```bash
~/.claude/skills/stm32-stlink/scripts/check_tools.sh
```

All required tools should show `[OK]`. Then connect a board and run:

```bash
~/.claude/skills/stm32-stlink/scripts/detect_device.sh
```

If both succeed, the setup is complete.

---

## Using STM32CubeIDE Bundled Tools

STM32CubeIDE installs its own copies of OpenOCD and arm-none-eabi-gdb. Point the skill at those using the `OPENOCD_PATH` environment variable:

```bash
# macOS (typical path)
export OPENOCD_PATH="$HOME/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.openocd.macos64_*/tools/bin/openocd"

# Linux (typical path)
export OPENOCD_PATH="$HOME/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.openocd.linux64_*/tools/bin/openocd"
```

Setting `OPENOCD_PATH` overrides the binary used by all skill scripts.

---

## Installing a Newer ARM Toolchain from ARM's Website

If your distribution's packaged toolchain is outdated:

1. Download from the ARM GNU Toolchain releases page
2. Extract the archive:
   ```bash
   tar xjf arm-gnu-toolchain-*-arm-none-eabi.tar.bz2 -C /opt/
   ```
3. Add to PATH:
   ```bash
   export PATH="/opt/arm-gnu-toolchain-*/bin:$PATH"
   # Add to ~/.zshrc or ~/.bashrc to persist
   ```

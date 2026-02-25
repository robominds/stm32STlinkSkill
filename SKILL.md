---
name: stm32-stlink
description: Use this skill when the user asks to flash, program, or debug an STM32 microcontroller using ST-LINK, asks about openocd or arm-none-eabi-gdb for embedded development, invokes /stm32, wants to generate an openocd.cfg, wants to start a GDB debug session on embedded hardware, or says things like "flash my firmware", "debug my STM32", "program the chip", or "connect to the board".
allowed-tools: Bash
---

# STM32 ST-LINK Programming and Debugging

Flash firmware and debug STM32 microcontrollers via ST-LINK using OpenOCD and arm-none-eabi-gdb.

## Step 1: Always Check Tools First

Before any other action, verify the toolchain is installed:

```bash
~/.claude/skills/stm32-stlink/scripts/check_tools.sh
```

Exit code 0 means all tools are present. Exit code 1 means one or more tools are missing — read the output, show the install commands to the user, and do not proceed with any other steps until tools are installed.

## Step 2: Detect Connected Device

When the user wants to detect what STM32 is connected, or before flashing/debugging if no `openocd.cfg` exists in the working directory:

```bash
~/.claude/skills/stm32-stlink/scripts/detect_device.sh
```

This probes the ST-LINK over USB and prints chip identification. If it fails, check that:
- The ST-LINK is physically connected over USB
- The target board is powered
- No other process (e.g. a running openocd, STM32CubeIDE) is holding the ST-LINK

## Step 3: Generate openocd.cfg

When the user needs to create an openocd config, or when one does not exist in the working directory:

```bash
~/.claude/skills/stm32-stlink/scripts/generate_config.sh <family>
```

Where `<family>` is one of: `f0`, `f1`, `f2`, `f3`, `f4`, `f7`, `g0`, `g4`, `h7`, `l0`, `l1`, `l4`, `l5`, `u5`, `wb`, `wl`

Examples:
```bash
~/.claude/skills/stm32-stlink/scripts/generate_config.sh f4
~/.claude/skills/stm32-stlink/scripts/generate_config.sh h7
~/.claude/skills/stm32-stlink/scripts/generate_config.sh l4
```

The script prints the generated `openocd.cfg` content to stdout. Show this to the user and offer to save it as `openocd.cfg` in their project directory.

## Step 4: Flash Firmware

To flash a firmware file (.elf, .hex, or .bin) to the target:

```bash
~/.claude/skills/stm32-stlink/scripts/flash.sh <firmware-file> [openocd.cfg]
```

- `<firmware-file>`: path to the .elf, .hex, or .bin file (required)
- `[openocd.cfg]`: path to openocd config (optional; defaults to `./openocd.cfg`)

Examples:
```bash
~/.claude/skills/stm32-stlink/scripts/flash.sh build/firmware.elf
~/.claude/skills/stm32-stlink/scripts/flash.sh build/firmware.elf /path/to/openocd.cfg
~/.claude/skills/stm32-stlink/scripts/flash.sh build/output.hex
~/.claude/skills/stm32-stlink/scripts/flash.sh build/output.bin
```

Exit code 0 = flash succeeded and verified. Exit code 1 = error — read the output for the specific failure reason.

## Step 5: Debug Session

To start an interactive GDB debug session:

```bash
~/.claude/skills/stm32-stlink/scripts/debug.sh <firmware-elf> [openocd.cfg]
```

- `<firmware-elf>`: path to the .elf file with debug symbols (required; must be .elf)
- `[openocd.cfg]`: path to openocd config (optional; defaults to `./openocd.cfg`)

The script:
1. Starts openocd as a background GDB server on port 3333
2. Writes a `.gdbinit-stm32` for the session with auto-connect commands
3. Launches `arm-none-eabi-gdb` connected to the GDB server

Example:
```bash
~/.claude/skills/stm32-stlink/scripts/debug.sh build/firmware.elf
```

When in the GDB session, use standard GDB commands. See `references/gdb-commands.md` for embedded-specific commands.

## Environment Variable Overrides

| Variable | Default | Purpose |
|---|---|---|
| `OPENOCD_PATH` | `openocd` | Path to openocd binary (for CubeIDE bundled tools) |
| `GDB_PORT` | `3333` | TCP port for GDB server |

Example:
```bash
OPENOCD_PATH=/opt/stm32/bin/openocd ~/.claude/skills/stm32-stlink/scripts/debug.sh build/firmware.elf
```

## Interpreting Output

### check_tools.sh
- `[OK]` — tool found at shown path with version
- `[MISSING]` — tool not installed; install commands shown below

### detect_device.sh
- Reports ST-LINK version, target voltage, chip IDCODE, and suggested family
- Use the family to pick the right argument for `generate_config.sh`

### flash.sh
- `** Programming Finished **` and `** Verified OK **` = success
- `Error: ...` lines indicate failure type

### debug.sh
- Reports openocd server startup on port 3333
- GDB connects and halts the CPU
- Prints current PC and source location if symbols are available

## Common Errors and Fixes

**"libusb_open() failed" or "ST-LINK not found"**
- Check USB connection and board power
- macOS: check System Preferences > Security for blocked drivers
- Linux: check udev rules (see `references/installation.md`)

**"Error: init mode failed" or "timed out waiting for target"**
- Wrong target config for the chip family — run `detect_device.sh` first, then regenerate config
- Target may be in a locked state — try `reset_config srst_nogate` in openocd.cfg

**".bin file without base address"**
- flash.sh automatically adds `0x08000000` for .bin files
- If your binary is not for STM32 internal flash start, use .elf or .hex format

**"Port 3333 already in use" during debug**
- Another openocd instance is running: `pkill openocd`
- Or set a different port: `GDB_PORT=3334 debug.sh ...`

**GDB "Cannot access memory at address"**
- Run `monitor reset halt` in GDB to ensure the MCU is halted

## Reference Files

- `references/installation.md` — Full toolchain installation guide for macOS and Linux
- `references/openocd-targets.md` — STM32 family to openocd target config mapping, part numbers
- `references/gdb-commands.md` — Embedded GDB command reference, peripheral registers, fault analysis

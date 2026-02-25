# stm32-stlink

A [Claude Code](https://claude.ai/claude-code) skill for programming and debugging STM32 microcontrollers via ST-LINK using OpenOCD and GDB.

## What it does

Gives Claude Code the ability to flash firmware and run source-level GDB debug sessions on any STM32 board connected via an ST-LINK V1/V2/V2-1/V3 adapter. Claude walks through a five-step workflow — tool check, device detection, config generation, flash, and debug — calling the appropriate scripts automatically based on what you ask.

## Prerequisites

| Tool | macOS | Ubuntu/Debian |
|---|---|---|
| OpenOCD | `brew install openocd` | `sudo apt install openocd` |
| ARM GCC + GDB | `brew install gcc-arm-embedded` | `sudo apt install gcc-arm-none-eabi gdb-multiarch` |

**Linux only:** add udev rules so OpenOCD can access the ST-LINK USB device without root — see [`references/installation.md`](references/installation.md).

## Installation

```bash
git clone https://github.com/robominds/stm32STlinkSkill.git
cd stm32STlinkSkill
bash install.sh
```

`install.sh` creates a symlink from `~/.claude/skills/stm32-stlink/` to this directory and marks all scripts executable. Edits to the source are immediately reflected — no reinstall needed.

To uninstall:
```bash
rm ~/.claude/skills/stm32-stlink
```

## Workflow

Once installed, invoke the skill in Claude Code by asking anything related to flashing or debugging STM32 hardware (or explicitly with `/stm32-stlink`). Claude follows this five-step process:

| Step | Script | Example |
|---|---|---|
| 1. Check tools | `check_tools.sh` | Verifies openocd and arm-none-eabi-gdb are installed |
| 2. Detect device | `detect_device.sh` | Probes ST-LINK via USB, reports chip IDCODE |
| 3. Generate config | `generate_config.sh <family>` | `generate_config.sh f4` → prints `openocd.cfg` |
| 4. Flash firmware | `flash.sh <fw> [cfg]` | `flash.sh build/firmware.elf` |
| 5. Debug | `debug.sh <fw.elf> [cfg]` | `debug.sh build/firmware.elf` |

### Flash

```bash
# Flash an ELF, HEX, or BIN file (openocd.cfg defaults to ./openocd.cfg)
~/.claude/skills/stm32-stlink/scripts/flash.sh build/firmware.elf
~/.claude/skills/stm32-stlink/scripts/flash.sh build/firmware.hex /path/to/openocd.cfg
```

### Debug

```bash
# Starts OpenOCD GDB server on port 3333, then launches arm-none-eabi-gdb
~/.claude/skills/stm32-stlink/scripts/debug.sh build/firmware.elf
```

`debug.sh` writes a `.gdbinit-stm32` next to the ELF that automatically connects to OpenOCD, resets and halts the target, and sets a breakpoint at `main`. OpenOCD is stopped automatically when GDB exits.

## Supported STM32 Families

| Shorthand | Family | Core | Max Speed |
|---|---|---|---|
| `f0` | STM32F0x | Cortex-M0 | 48 MHz |
| `f1` | STM32F1x | Cortex-M3 | 72 MHz |
| `f2` | STM32F2x | Cortex-M3 | 120 MHz |
| `f3` | STM32F3x | Cortex-M4F | 72 MHz |
| `f4` | STM32F4x | Cortex-M4F | 168 MHz |
| `f7` | STM32F7x | Cortex-M7 | 216 MHz |
| `g0` | STM32G0x | Cortex-M0+ | 64 MHz |
| `g4` | STM32G4x | Cortex-M4F | 170 MHz |
| `h7` | STM32H7x | Cortex-M7 (+ M4) | 480 MHz |
| `l0` | STM32L0 | Cortex-M0+ | 32 MHz |
| `l1` | STM32L1 | Cortex-M3 | 32 MHz |
| `l4` | STM32L4x | Cortex-M4F | 80 MHz |
| `l5` | STM32L5x | Cortex-M33 | 110 MHz |
| `u5` | STM32U5x | Cortex-M33 | 160 MHz |
| `wb` | STM32WBx | Cortex-M4 + M0+ | 64 MHz |
| `wl` | STM32WLx | Cortex-M4 + M0+ | 48 MHz |

## Script Reference

| Script | Purpose | Arguments |
|---|---|---|
| `check_tools.sh` | Verify toolchain; print install commands if missing | — |
| `detect_device.sh` | Probe connected ST-LINK, identify chip IDCODE | — |
| `generate_config.sh` | Print `openocd.cfg` for a given family to stdout | `<family>` |
| `flash.sh` | Flash firmware and verify | `<firmware> [openocd.cfg]` |
| `debug.sh` | Start OpenOCD server + launch GDB | `<firmware.elf> [openocd.cfg]` |

## Environment Variables

| Variable | Default | Purpose |
|---|---|---|
| `OPENOCD_PATH` | `openocd` | Override openocd binary path (e.g. for STM32CubeIDE bundled tools) |
| `GDB_PORT` | `3333` | GDB server TCP port |

```bash
# Example: use STM32CubeIDE's bundled OpenOCD
OPENOCD_PATH=~/STM32CubeIDE/plugins/.../openocd \
  ~/.claude/skills/stm32-stlink/scripts/debug.sh build/firmware.elf
```

## References

- [`references/installation.md`](references/installation.md) — Full toolchain setup for macOS, Ubuntu, Fedora, and Arch; Linux udev rules
- [`references/openocd-targets.md`](references/openocd-targets.md) — STM32 family → OpenOCD target config mapping, common part numbers, flash addresses
- [`references/gdb-commands.md`](references/gdb-commands.md) — Embedded GDB command reference: registers, memory, watchpoints, HardFault analysis, peripheral access

## Authorship

Written by Mark Castelluccio. AI assistance provided by [Claude](https://claude.ai) (Anthropic).

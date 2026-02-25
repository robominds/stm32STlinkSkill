# OpenOCD STM32 Target Configuration Reference

Maps STM32 chip families to their OpenOCD target config files, core types, and common part numbers.

---

## Quick Reference Table

| Shorthand | Full Name | CPU Core | OpenOCD Target Config | Default Speed |
|---|---|---|---|---|
| `f0` | STM32F0x | Cortex-M0 | `target/stm32f0x.cfg` | 1000 kHz |
| `f1` | STM32F1x | Cortex-M3 | `target/stm32f1x.cfg` | 1000 kHz |
| `f2` | STM32F2x | Cortex-M3 | `target/stm32f2x.cfg` | 2000 kHz |
| `f3` | STM32F3x | Cortex-M4F | `target/stm32f3x.cfg` | 2000 kHz |
| `f4` | STM32F4x | Cortex-M4F | `target/stm32f4x.cfg` | 4000 kHz |
| `f7` | STM32F7x | Cortex-M7 | `target/stm32f7x.cfg` | 4000 kHz |
| `g0` | STM32G0x | Cortex-M0+ | `target/stm32g0x.cfg` | 2000 kHz |
| `g4` | STM32G4x | Cortex-M4F | `target/stm32g4x.cfg` | 4000 kHz |
| `h7` | STM32H7x | Cortex-M7 + M4 | `target/stm32h7x.cfg` | 4000 kHz |
| `l0` | STM32L0 | Cortex-M0+ | `target/stm32l0.cfg` | 500 kHz |
| `l1` | STM32L1 | Cortex-M3 | `target/stm32l1.cfg` | 500 kHz |
| `l4` | STM32L4x | Cortex-M4F | `target/stm32l4x.cfg` | 2000 kHz |
| `l5` | STM32L5x | Cortex-M33 | `target/stm32l5x.cfg` | 2000 kHz |
| `u5` | STM32U5x | Cortex-M33 | `target/stm32u5x.cfg` | 2000 kHz |
| `wb` | STM32WBx | M4 + M0+ | `target/stm32wbx.cfg` | 2000 kHz |
| `wl` | STM32WLx | M4 + M0+ | `target/stm32wlx.cfg` | 2000 kHz |

---

## Family Details and Common Parts

### STM32F0x — Cortex-M0, 48 MHz, entry-level
Parts: STM32F030, STM32F042, STM32F051, STM32F070, STM32F072, STM32F091
```bash
generate_config.sh f0
```

### STM32F1x — Cortex-M3, 72 MHz ("Blue Pill" family)
Parts: STM32F100, STM32F101, STM32F102, **STM32F103**, STM32F105, STM32F107
Popular boards: Blue Pill (STM32F103C8T6), Maple Mini, Nucleo-F103RB
```bash
generate_config.sh f1
```

### STM32F2x — Cortex-M3, 120 MHz
Parts: STM32F205, STM32F207, STM32F215, STM32F217
```bash
generate_config.sh f2
```

### STM32F3x — Cortex-M4F, 72 MHz
Parts: STM32F301, STM32F302, **STM32F303**, STM32F334, STM32F373
Popular boards: STM32F3Discovery, Nucleo-F303RE
```bash
generate_config.sh f3
```

### STM32F4x — Cortex-M4F, 168 MHz (most popular)
Parts: STM32F401, STM32F405, **STM32F407**, STM32F410, **STM32F411**, STM32F429, **STM32F446**, STM32F469
Popular boards: STM32F407VET6 "Black Board", Nucleo-F401RE, Nucleo-F446RE, STM32F4Discovery
```bash
generate_config.sh f4
```

### STM32F7x — Cortex-M7, 216 MHz
Parts: STM32F722, STM32F745, **STM32F746**, STM32F767, STM32F777
Popular boards: Nucleo-F746ZG, STM32F746G-DISCO
```bash
generate_config.sh f7
```

### STM32G0x — Cortex-M0+, 64 MHz (modern low-cost replacement for F0)
Parts: STM32G030, STM32G031, STM32G041, STM32G070, **STM32G071**, STM32G081
```bash
generate_config.sh g0
```

### STM32G4x — Cortex-M4F, 170 MHz (math accelerators)
Parts: STM32G431, **STM32G474**, STM32G484
Popular boards: Nucleo-G474RE, STM32G4 Discovery
```bash
generate_config.sh g4
```

### STM32H7x — Cortex-M7 + M4, up to 480 MHz (dual-core, highest performance)
Parts: **STM32H743**, STM32H745 (dual), STM32H747 (dual), **STM32H750**, STM32H753
Popular boards: Nucleo-H743ZI, STM32H745I-DISCO, WeAct MiniH743
Note: Single-core variants (H743, H750) use M7 only. Dual-core variants (H745, H747) need special config.
```bash
generate_config.sh h7
```

### STM32L0 — Cortex-M0+, 32 MHz (ultra-low-power)
Parts: STM32L010, STM32L031, STM32L051, STM32L071, STM32L073
Adapter speed kept at 500 kHz — MSI oscillator runs very slowly at startup.
```bash
generate_config.sh l0
```

### STM32L1 — Cortex-M3, 32 MHz (ultra-low-power)
Parts: STM32L100, STM32L151, STM32L152, STM32L162
```bash
generate_config.sh l1
```

### STM32L4x — Cortex-M4F, 80 MHz (ultra-low-power + performance)
Parts: STM32L412, STM32L432, **STM32L476**, STM32L496, STM32L4A6
Popular boards: Nucleo-L476RG, Nucleo-L432KC, STM32L476G-DISCO
```bash
generate_config.sh l4
```

### STM32L5x — Cortex-M33, 110 MHz (TrustZone security)
Parts: STM32L552, STM32L562
If connection fails, TrustZone may be enabled. Check option bytes.
```bash
generate_config.sh l5
```

### STM32U5x — Cortex-M33, 160 MHz (ultra-low-power + TrustZone)
Parts: STM32U535, STM32U575, STM32U5A5
Popular boards: Nucleo-U575ZI-Q
```bash
generate_config.sh u5
```

### STM32WBx — Cortex-M4 + M0+, 64 MHz (Bluetooth/BLE)
Parts: STM32WB10, STM32WB35, **STM32WB55**
Popular boards: Nucleo-WB55RG
Note: Only M4 (user core) is debuggable via standard ST-LINK. M0+ runs BLE stack.
```bash
generate_config.sh wb
```

### STM32WLx — Cortex-M4 + M0+, 48 MHz (LoRa/Sub-GHz)
Parts: STM32WL54, STM32WL55, STM32WLE5
Popular boards: Nucleo-WL55JC
```bash
generate_config.sh wl
```

---

## openocd.cfg Templates

### Minimal config (most common)
```tcl
source [find interface/stlink.cfg]
transport select hla_swd
source [find target/stm32f4x.cfg]
reset_config none
adapter speed 4000
```

### With NRST hardware reset pin connected
```tcl
source [find interface/stlink.cfg]
transport select hla_swd
source [find target/stm32f4x.cfg]
reset_config srst_nogate
adapter speed 4000
```

### With explicit port configuration
```tcl
source [find interface/stlink.cfg]
transport select hla_swd
source [find target/stm32f4x.cfg]
reset_config none
adapter speed 4000
gdb_port 3333
telnet_port 4444
tcl_port 6666
```

### Multiple ST-LINK devices (select by serial number)
```tcl
source [find interface/stlink.cfg]
adapter serial "003A00213438510734313939"   # Get serial from: openocd -c "adapter serial list"
transport select hla_swd
source [find target/stm32f4x.cfg]
reset_config none
adapter speed 4000
```

---

## Flash Memory Base Addresses

All STM32 families use `0x08000000` as the flash start address for internal flash.

| Family | Flash Start | Max Flash |
|---|---|---|
| STM32F0x | 0x08000000 | 256 KB |
| STM32F1x | 0x08000000 | 512 KB |
| STM32F2x | 0x08000000 | 1 MB |
| STM32F3x | 0x08000000 | 512 KB |
| STM32F4x | 0x08000000 | 2 MB |
| STM32F7x | 0x08000000 | 2 MB |
| STM32G0x | 0x08000000 | 512 KB |
| STM32G4x | 0x08000000 | 512 KB |
| STM32H7x | 0x08000000 | 2 MB (dual-bank) |
| STM32L0  | 0x08000000 | 192 KB |
| STM32L1  | 0x08000000 | 512 KB |
| STM32L4x | 0x08000000 | 1 MB |
| STM32U5x | 0x08000000 | 4 MB |
| STM32WBx | 0x08000000 | 1 MB |

---

## Finding Available Target Configs

List all STM32 target configs in your OpenOCD installation:

```bash
# macOS Homebrew
ls /opt/homebrew/share/openocd/scripts/target/ | grep stm32

# Linux
ls /usr/share/openocd/scripts/target/ | grep stm32
```

---

## Troubleshooting Wrong Target Config

If `detect_device.sh` or flash/debug fails with "wrong target", the IDCODE mismatch will appear in the OpenOCD output:

```
Warn : UNEXPECTED idcode (0x2ba01477)!
Expected 4 of 1: 0x06430041
```

This means the target config file does not match your chip. Run `detect_device.sh` again and look for the IDCODE, then cross-reference with this table or the OpenOCD target config files directly.

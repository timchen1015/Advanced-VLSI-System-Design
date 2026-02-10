# Advanced VLSI System Design

This repository contains selected coursework projects for Advanced VLSI System Design, including CPU design and Cache implementation.

> **Note**: This is a public repository. TSMC technology files, synthesis results, and APR data are excluded per confidentiality agreement.

## Project Structure

```
├── HW1/             # HW1: 5-stage RISC-V CPU
└── HW4/             # HW4: Cache & System Integration
```

### Homework Folder Structure

Each homework folder contains the following directories:

```
HWx/
├── include/         # Header files (.svh)
├── script/          # Synthesis and verification scripts
│   ├── synthesis.tcl       # Synthesis script
│   └── superlint.tcl       # Lint checking script
├── sim/             # Simulation files
│   ├── prog0-6/            # Test programs
│   └── top_tb.sv           # Testbench
├── src/             # RTL source code (.sv)
└── Makefile         # Compilation and simulation script
```

## Homework Contents

### [HW1: 5-Stage RISC-V CPU](HW1)
- Implementation of basic 5-stage pipeline RISC-V processor
- Support for RV32I instruction set
- Pipeline hazard detection and forwarding
- Branch prediction unit

### [HW4: Cache and System Integration](HW4)
- L1 Instruction/Data Cache implementation
- Cache coherence control
- AXI bus integration
- DMA controller
- Watchdog Timer (WDT)
- Clock Domain Crossing (CDC) design

## Tools and Environment

- **Simulation**: VCS
- **Synthesis**: Synopsys Design Compiler
- **Verification**: JasperGold (Formal), Spyglass (CDC)
- **Language**: SystemVerilog
- **Process**: TSMC N16 ADFP (confidential files excluded)

## Usage

### RTL Simulation
```bash
cd HWx/sim
make rtl0  # Run test program 0
```

## Confidentiality Notice

This repository excludes the following confidential materials per TSMC N16 ADFP agreement:
- TSMC standard cell libraries (*.lib, *.db)
- Memory compiler models (SRAM, ROM, DRAM)
- Synthesis results (*_syn.v, *.sdf)
- APR files and technology data
- Any TSMC-provided documentation

Only original RTL design files and scripts are included.


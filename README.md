# RISC-V Processor

This project contains a basic 32-bit RISC-V processor designed in SystemVerilog. The processor is built using a modular RTL structure with separate blocks for instruction fetch, decode, execution, memory, register file, ALU, branch, jump, load, and store operations.

The project also includes unit-level testbenches for verifying individual processor modules.

## Project Structure

```text
riscv_processor_project/
├── rtl/
│   ├── processor.sv
│   ├── processor_defines.sv
│   ├── ifu.sv
│   ├── idu.sv
│   ├── ieu.sv
│   ├── alu_core.sv
│   ├── regfile.sv
│   ├── branch.sv
│   ├── jump.sv
│   ├── load.sv
│   ├── store.sv
│   ├── mem.sv
│   └── inst_data_arbiter.sv
│
├── tb/
│   ├── regfile_tb.sv
│   ├── alu_core_tb.sv
│   ├── branch_tb.sv
│   ├── jump_tb.sv
│   ├── load_tb.sv
│   ├── store_tb.sv
│   ├── mem_tb.sv
│   └── processor_tb.sv
│
├── .gitignore
└── README.md
```

## Features

- 32-bit RISC-V processor implementation
- Modular SystemVerilog RTL design
- Instruction Fetch Unit
- Instruction Decode Unit
- Integer Execution Unit
- Register file
- ALU
- Branch and jump control
- Load and store support
- Byte-enable based memory writes
- Instruction/data memory arbitration
- Unit-level verification using SystemVerilog testbenches

## Verified Modules

The following modules have been tested using Icarus Verilog:

| Module | Testbench | Status |
|---|---|---|
| Register File | `regfile_tb.sv` | Passed |
| ALU | `alu_core_tb.sv` | Passed |
| Branch Unit | `branch_tb.sv` | Passed |
| Jump Unit | `jump_tb.sv` | Passed |
| Load Unit | `load_tb.sv` | Passed |
| Store Unit | `store_tb.sv` | Passed |
| Memory | `mem_tb.sv` | Passed |

## Tools Used

- SystemVerilog
- Icarus Verilog
- GTKWave
- VS Code
- Ubuntu/Linux terminal
- Git and GitHub

## Running Testbenches

Run all commands from the project root directory.

### Register File

```bash
iverilog -g2012 -I rtl -o regfile_tb.out rtl/regfile.sv tb/regfile_tb.sv
vvp regfile_tb.out
```

### ALU

```bash
iverilog -g2012 -I rtl -o alu_core_tb.out rtl/alu_core.sv tb/alu_core_tb.sv
vvp alu_core_tb.out
```

### Branch Unit

```bash
iverilog -g2012 -I rtl -o branch_tb.out rtl/branch.sv tb/branch_tb.sv
vvp branch_tb.out
```

### Jump Unit

```bash
iverilog -g2012 -I rtl -o jump_tb.out rtl/jump.sv tb/jump_tb.sv
vvp jump_tb.out
```

### Load Unit

```bash
iverilog -g2012 -I rtl -o load_tb.out rtl/load.sv tb/load_tb.sv
vvp load_tb.out
```

### Store Unit

```bash
iverilog -g2012 -DSUBMODULE_DISABLE_WAVES -I rtl -o store_tb.out rtl/store.sv tb/store_tb.sv
vvp store_tb.out
```

### Memory

```bash
iverilog -g2012 -DSUBMODULE_DISABLE_WAVES -I rtl -o mem_tb.out rtl/mem.sv tb/mem_tb.sv
vvp mem_tb.out
```

### Processor Top

```bash
iverilog -g2012 -DDISABLE_WAVES -DSUBMODULE_DISABLE_WAVES -DSUBMODULE_DISABLE_WAVES_ALU_CORE -I rtl -o processor_tb.out rtl/processor.sv tb/processor_tb.sv
vvp processor_tb.out
```

## Design Overview

### Instruction Fetch Unit

The instruction fetch unit updates the program counter and provides the current and previous PC values. It also supports PC stall and PC update signals for branch and jump operations.

### Instruction Decode Unit

The instruction decode unit decodes the instruction and generates register addresses, immediate values, and control signals for ALU, load, store, branch, and jump instructions.

### Integer Execution Unit

The integer execution unit connects the register file, ALU, branch unit, jump unit, load unit, and store unit. It handles register writeback, memory access control, and PC update control.

### Memory

The memory module supports read and write operations. Store instructions use byte enables to support byte, halfword, and word writes.

### Instruction/Data Arbiter

The instruction/data arbiter selects between instruction fetch access and data memory access depending on whether the processor is executing a load or store operation.

## Current Status

- RTL modules implemented
- Individual unit testbenches written
- Major modules verified using Icarus Verilog
- Processor-level testbench added for integration testing

## Future Improvements

- Add more RV32I instruction tests
- Add an automated script to run all testbenches
- Add waveform screenshots
- Improve processor-level verification
- Add more instruction support
- Explore pipelining and hazard handling

## Author

Priyanka Rabra
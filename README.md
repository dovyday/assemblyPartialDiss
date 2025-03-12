# Partial 8086 Disassembler

## Overview
This project is a partial disassembler for 8086 assembly language. It processes binary machine code and translates supported instructions into their assembly mnemonics. The disassembler handles specific instructions such as `pop`, `dec`, `and`, `loop`, `loope`, `loopne`, `lea`, and `lds`.

## Features
- Reads input binary files.
- Decodes and prints supported assembly instructions.
- Outputs results to a specified file.
- Supports both register and memory addressing modes where applicable.
- Provides basic error handling for unsupported instructions.

## Supported Instructions
- `pop`
- `dec`
- `and`
- `loop`
- `loope`
- `loopne`
- `lea`
- `lds`
- Registers: `AX`, `CX`, `DX`, `BX`, `SP`, `BP`, `SI`, `DI`
- Segment Registers: `ES`, `CS`, `SS`, `DS`
- Addressing Modes: `[BX+SI]`, `[BX+DI]`, `[BP+SI]`, `[BP+DI]`, etc.

## Requirements
- 8086-compatible assembler (TASM)
- DOS or DOSBox for execution
- File input and output handling via DOS interrupts

## Usage
1. Assemble the source code using an assembler, for example:
   ```
   tasm disassembler.asm
   tlink disassembler.obj
   ```
2. Run the executable and provide input and output file names:
   ```
   disassembler input.bin output.asm
   ```
3. If no parameters are provided, manual input mode is enabled.
4. The disassembled instructions will be written to the specified output file.




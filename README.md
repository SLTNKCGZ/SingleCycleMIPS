This repository contains the Verilog implementation of an extended single-cycle MIPS processor. Developed as part of the CSE3038 Computer Organization course at Marmara University, this project focuses 
on expanding a standard MIPS architecture to support a custom instruction set.  The core objective was to modify the datapath, control unit, ALU control, memory write logic, and PC selection logic to 
accommodate new operations while maintaining the integrity of the original processor structure.  

## Implemented Instructions   
The processor has been upgraded to execute the following seven custom instructions:  
  - lwslt: Performs a signed less-than comparison using memory data and writes the boolean result back to a register.
  - beqm: A branch instruction that evaluates equality between a register and a dynamically calculated memory value.
  - swand: Calculates a target memory address using a bitwise AND operation between two registers before storing data.
  - swinc: Stores an incremented register value into memory.
  - swv: A conditional memory write operation dependent on the overflow (V) flag.
  - bnpos: A pseudo-direct branch triggered by the zero (Z) or negative (N) status flags.
  - balerr: A conditional branch-and-link instruction that executes if the Z, N, and V flags are all set.

## Key Architectural Updates
To support these new instructions, several hardware components were redesigned:
  - Status Register Integration: Designed a continuously updating status register to store ALU-generated Overflow (V), Negative (N), and Zero (Z) flags after every instruction execution for use in status-dependent branching.
  - Comparator Enhancements: Updated the comparator module to handle both standard equality and signed greater-than/less-than comparisons.
  - Memory Path Modifications: Added specific multiplexers to the data memory address and write-data paths, enabling instructions to dynamically route register values directly to memory.

## Testing & Simulation
The custom datapath and control unit were fully verified using ModelSim. Each instruction was tested independently with custom initialization files for instruction memory, data memory, and the register file. 
The simulations confirm that all seven instructions process memory updates, logical comparisons, and branch conditions accurately within a single clock cycle.  

## Documentation
For more detailed information, including complete datapath schematics, instruction formats, and step-by-step ModelSim waveform analyses, please review the full [Project Report](https://github.com/SLTNKCGZ/SingleCycleMIPS/blob/main/Project%20Report.pdf) included in this repository.

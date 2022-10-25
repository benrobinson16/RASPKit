# RASPKit

A swift package to facilitate simple simulations of Random-Access Stored-Program (RASP) machines.

## Installation

Add the following to your `Package.swift` file, or add this url as a dependency to your Xcode project.

```swift
.package(url: "https://github.com/benrobinson16/RASPKit", branch: "main")
```

## Usage

You can write a program in one of two ways: using an "assembly language" syntax or type-safe swift arrays.

### Raw Instructions

Initialise an array of `Instruction` structs, providing the operation, addressing mode and value for each instruction. Note you must manually provide the locations of instructions/variables. Variables are always in registers immediately following the instructions.

For example, the following is a multiplication of two numbers:

```swift
let multiply: [Instruction] = [
    .init(.load, .direct, 11),
    .init(.add, .direct, 9),
    .init(.store, .immediate, 11),
    .init(.load, .direct, 10),
    .init(.subtract, .immediate, 1),
    .init(.store, .immediate, 10),
    .init(.branchIfZero, .immediate, 8),
    .init(.jump, .immediate, 0),
    .init(.halt, .immediate, 0)
]
```

This can be converted into raw machine code/integers like so:

```swift
let machineCode = multiply.map { $0.encode() }
```

See below for a description of operations and addressing modes.

### Assembly Language

You can also use a form of assembly language, which will manage the memory locations of variables and lines of code for you.

In general, the syntax is as follows:

- Write an instruction in the form `<opcode> <addressing_mode><operand>` with exactly one per line.
- Addressing mode can be # (immediate), R (contents of register), RR (contents of register pointed to).
- Define variables using an entire line in the form `$define variable_name`.
  - Note that variables will be stored in the order they are defined immediately following the instructions in memory.
- When using a variable, still specify the addressing mode but replace the operand with the variable name.
- Load from a variable with `LDA Rvariable_name`; store to a variable with `STR #variable_name`.
- `#variable_name` gives location of a variable; `Rvariable_name` gives value at variable.
- Label lines in form `@<line_name>: <opcode> <addressing_mode><operand>`.
- Access labels like an addressing mode and operand pair: `JMP @<line_label>`
- In general `@<line_label>` provides the address of the labelled line (in case you want to store it in a variable).

Here is an example program to multiply two numbers, equivalent to the above manual program:

```swift
let multiply = """
$define numA
$define numB
$define output

@loop: LDA Routput
ADD RnumA
STR #output
LDA RnumB
SUB #1
STR #numB
BZE @final
JMP @loop
@final: HLT
"""
```

This can be assembled into machine code like so:

```swift
let assembler = Assembler()
let machineCode = try assembler.assemble(multiply)
```

### Running the Code

To run the code, a machine must be created and then the registers of instructions and variables must be provided. You must provide the input/initial values of the variables.

```swift
let m1 = RandomAccessMachine() // Creates a machine with 1024 registers by default
let m2 = RandomAccessMachine(numRegisters: 2048) // Creates a machine with 2048 registers
let m3 = RandomAccessMachine(registers: machineCode) // Creates a machine with 1024 registers starting with the provided instructions
let m4 = RandomAccessMachine(instructions: machineCode, variables: [a, b, c], blankRegisters: 2) // Creates a machine with the machine code, followed by variables, followed by blank spaced in memory
```

For our example above, we need two variables pre-populated and another one for the output. We can run it to multipl 2 * 5 like so:

```swift
let machineCode = // Our compiled instructions
let machine = RandomAccessMachine(instructions: machineCode, variables: [2, 5], blankRegisters: 1)
machine.run()
print(machine.registers.last) // The output is in the final register
```

## Operations

| **Opcode** | **Operation Name**  | **Description**                                                                               |
|------------|---------------------|-----------------------------------------------------------------------------------------------|
| `HLT`      | Halt                | Ends the computation (operand ignored)                                                        |
| `LDA`      | Load                | Loads the operand into the accumulator                                                        |
| `STR`      | Store               | Stores the value in the accumulator in the provided register                                  |
| `ADD`      | Add                 | Adds the operand to the accumulator                                                           |
| `SUB`      | Subtract            | Subtracts the operand from the accumulator                                                    |
| `AND`      | And                 | Performs a bitwise AND operation on the accumulator with the operand                          |
| `ORR`      | Or                  | Performs a bitwise OR operation on the accumulator with the operand                           |
| `XOR`      | Xor                 | Performs a bitwise exclusive or (XOR) operation on the accumulator with the operand           |
| `NOT`      | Not                 | Performs a bitwise NOT operation on the accumulator (operand ignored)                         |
| `LSL`      | Logical shift left  | Shift bits in the accumulator to the left by the number of times in the operand               |
| `LSR`      | Logical shift right | Shift bits in the accumulator to the right by the number of times in the operand              |
| `BZE`      | Branch if zero      | Go to the instruction at the register specified by the operand if the accumulator is zero     |
| `BNE`      | Branch if negative  | Go to the instruction at the register specified by the operand if the accumulator is < 0      |
| `BPO`      | Branch if positive  | Go to the instruction at the register specified by the operand if the accumulator is > 0      |
| `BNZ`      | Branch if not zero  | Go to the instruction at the register specified by the operand if the accumulator if not zero |
| `JMP`      | Jump                | Go unconditionally to the instruction at the register specified by the operand                |

## Addressing Modes

| **Prefix** | **Addressing Mode Name** | **Description**                                                                                            |
|------------|--------------------------|------------------------------------------------------------------------------------------------------------|
| `#`        | Immediate                | Uses the value directly specified in the operand.                                                          |
| `R`        | Direct                   | Uses the value in the register whose address is specified in the operand.                                  |
| `RR`       | Indirect                 | Uses the value in the register whose address is in the register whose address is specified in the operand. |

In other words:

- Immediate: Operand
- Direct: Operand --> Register
- Indirect: Operand --> Register --> Register

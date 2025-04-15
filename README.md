# Implementation-of-a-Stack-based-Processor

This experiment involves designing and programming a **stack-based processor** with the following specifications:

- 🧮 **8-bit stack** with **8 registers**
- 💾 **256 bytes of memory** (8-bit cells)
- 🔌 The last 8 memory addresses (`0xF8` to `0xFF`) are reserved for **I/O** using **I/O Mapped Memory**

## 📜 Instruction Set

| Opcode | Instruction | Description |
|--------|-------------|-------------|
| `0000` | `PUSH C`    | Pushes the 8-bit constant `C` onto the stack |
| `0001` | `PUSH M`    | Loads memory at address `M` (8-bit) and pushes it onto the stack |
| `0010` | `POP M`     | Pops value from the stack and stores it at address `M` (or writes to I/O) |
| `0011` | `JUMP`      | Pops value from the stack and jumps to that address (sets PC) |
| `0100` | `JZ`        | If Zero flag `Z` is set, pops value and sets PC |
| `0101` | `JS`        | If Sign flag `S` is set, pops value and sets PC |
| `0110` | `ADD`       | Pops top two stack values, adds them, and pushes result |
| `0111` | `SUB`       | Pops top two stack values, subtracts them, and pushes result |

🧠 **Flags:**
- `Z` (Zero) and `S` (Sign)
- Updated only on `ADD` and `SUB`
- All operations are **signed** using **two’s complement**

## 🧩 Project

Write a **machine code program** for this processor to:

1. Take an **8-bit positive number `X`** as input using the FPGA board
2. Calculate the expression:  
   ```text
   Y = ((X + 23) * 2) - 12
3. Output `Y` to the **7-segment display** on the board.
4. If:
  - Input `X` is **negative**, **OR**
  - Output `Y` **exceeds 127**  
  ➡️ **Turn ON an error LED** on the board.
5. Demonstrate **correct execution** on the **FPGA board**.
6. Ensure **all I/O interactions** (LEDs, switches, 7-segment) are done using **I/O Mapped Memory**.

> 💡 **Note:**  
> All arithmetic operations are **signed** and use **two’s complement**.  
> Handle I/O **only through mapped memory** (`0xF8` to `0xFF`).

--

## 🧠 Part 1: Processor Design

Each instruction is 8 bits. The upper 4 bits represent the `opcode`, which determines the operation. The processor fetches the instruction, stores it in the IR (Instruction Register), and executes it based on its type.

### 🛠 Instruction Implementation

#### `PUSH C` — Push Constant
Reads a constant from memory and stores it in the stack.
```verilog
data = mem[pc];
pc = pc + 1;
stack[SP] = data;
SP = SP + 1;
```
#### `PUSH M` — Push from Memory
Reads a memory address, fetches the value at that address, and pushes it to the stack.
```verilog
data = mem[pc];
pc = pc + 1;
stack[SP] = mem[data];
SP = SP + 1;
```

#### `POP M` — Pop to Memory
Pops the top value of the stack and writes it to the memory.
```verilog
data = mem[pc];
pc = pc + 1;
SP = SP - 1;
mem[data] = stack[SP];
```

#### `JUMP` — Unconditional Jump
Sets the program counter (pc) to the value at the top of the stack.
```verilog
SP = SP - 1;
pc = stack[SP];
```

#### `JS/JZ` — Conditional Jumps
Jumps if the `zero` or `sign` flag is set.
```verilog
if (z) begin
  SP = SP - 1;
  pc = stack[SP];
end
```

#### `ADD/SUB` — Arithmetic Operations
Adds or subtracts the top two stack values, stores the result, and sets flags.
```verilog
stack[SP - 2] = stack[SP - 2] + stack[SP - 1];
SP = SP - 1;
data = stack[SP - 1];

if (data[7]) s = 1; else s = 0;
if (~data)  z = 1; else z = 0;
```

## 💾 Part 2: Machine Code for Expression `(x + 23) * 2 - 1`

We write machine-level code to compute the expression and store the result in memory. If the result is negative, an error flag is raised.

### 🧮 Assembly Instructions

```verilog
mem[0]  = 8'b0000_0001; // pushM x
mem[1]  = 8'd255;

mem[2]  = 8'b0000_0001; // pushM x
mem[3]  = 8'd255;

mem[4]  = 8'b0000_0000; // pushC 23
mem[5]  = 8'd23;

mem[6]  = 8'b0000_0000; // pushC 23
mem[7]  = 8'd23;

mem[8]  = 8'b0000_0110; // add
mem[9]  = 8'b0000_0110; // add
mem[10] = 8'b0000_0110; // add

mem[11] = 8'b0000_0000; // pushC 12
mem[12] = 8'd12;

mem[13] = 8'b0000_0111; // sub

mem[14] = 8'b0000_0001; // pushM error_addr
mem[15] = 8'd253;

mem[16] = 8'b0000_1010; // jump if sign

mem[17] = 8'b0000_0010; // pop to result
mem[18] = 8'd254;

mem[19] = 8'b0000_0000; // pushC 32
mem[20] = 8'd32;

mem[21] = 8'b0000_0011; // jump end

mem[22] = 8'b0000_0000; // pushC 1
mem[23] = 8'd1;

mem[24] = 8'b0000_0010; // pop to error flag
mem[25] = 8'd253;

## 🔢 Part 3: Output Using 7-Segment Display

We display the final result using a seven-segment display.

### 🔧 Display Module

```verilog
module sevenSeg_convertor(out, in);
  input [3:0] in;
  output [6:0] out;
  wire [15:0] number;

  assign number[0]  = ~in[0] & ~in[1] & ~in[2] & ~in[3];
  assign number[1]  =  in[0] & ~in[1] & ~in[2] & ~in[3];
  assign number[2]  = ~in[0] &  in[1] & ~in[2] & ~in[3];
  assign number[3]  =  in[0] &  in[1] & ~in[2] & ~in[3];
  assign number[4]  = ~in[0] & ~in[1] &  in[2] & ~in[3];
  assign number[5]  =  in[0] & ~in[1] &  in[2] & ~in[3];
  assign number[6]  = ~in[0] &  in[1] &  in[2] & ~in[3];
  assign number[7]  =  in[0] &  in[1] &  in[2] & ~in[3];
  assign number[8]  = ~in[0] & ~in[1] & ~in[2] &  in[3];
  assign number[9]  =  in[0] & ~in[1] & ~in[2] &  in[3];
  assign number[10] = ~in[0] &  in[1] & ~in[2] &  in[3];
  assign number[11] =  in[0] &  in[1] & ~in[2] &  in[3];
  assign number[12] = ~in[0] & ~in[1] &  in[2] &  in[3];
  assign number[13] =  in[0] & ~in[1] &  in[2] &  in[3];
  assign number[14] = ~in[0] &  in[1] &  in[2] &  in[3];
  assign number[15] =  in[0] &  in[1] &  in[2] &  in[3];

  assign out[0] = number[1]  | number[4]  | number[11] | number[13];
  assign out[1] = number[2]  | number[5]  | number[6]  | number[11] | number[12] | number[14];
  assign out[2] = number[0]  | number[1]  | number[3]  | number[4]  | number[5]  | number[7]  | number[10] | number[13] | number[15];
  assign out[3] = number[1]  | number[2]  | number[3]  | number[7]  | number[10] | number[15];
  assign out[4] = number[1]  | number[3]  | number[4]  | number[5]  | number[7]  | number[9];
  assign out[5] = number[0]  | number[2]  | number[3]  | number[5]  | number[6]  | number[8];
  assign out[6] = number[0]  | number[1]  | number[7]  | number[12];
endmodule

Each `number[i]` maps a 4-bit binary input to a decimal digit (0–15), and each `out[j]` controls segment `j` of the seven-segment display. This allows the correct segments to light up and visually represent the corresponding digit.


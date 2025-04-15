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

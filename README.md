# Implementation-of-a-Stack-based-Processor

This experiment involves designing and programming a **stack-based processor** with the following specifications:

- 🧮 **8-bit stack** with **8 registers**
- 💾 **256 bytes of memory** (8-bit cells)
- 🔌 The last 8 memory addresses (`0xF8` to `0xFF`) are reserved for **I/O** using **I/O Mapped Memory**

---

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

---

## 🧩 Assignment

Write a **machine code program** for this processor to:

1. Take an **8-bit positive number `X`** as input using the FPGA board
2. Calculate the expression:  
   ```text
   Y = ((X + 23) * 2) - 12

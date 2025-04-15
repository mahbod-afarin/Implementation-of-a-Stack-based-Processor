module cpu (
    input clk,
    input start,
    input [7:0] x,
    output wire error,
    output wire [0:6] out0,
    output wire [0:6] out1
);

  // Registers and memory
  reg [7:0] stack [0:7];
  reg [7:0] memory [0:255];
  reg [7:0] pc;
  reg [3:0] sp;  // stack pointer
  reg zeroFlag, signFlag;
  reg [7:0] IR, DR;

  // Wires for output
  wire [7:0] result;
  wire [7:0] tmp;
  assign tmp = memory[253];
  assign error = tmp[0];
  assign result = memory[254];

  // 7-Segment output
  wire [3:0] res0 = result % 10;
  wire [3:0] res1 = result / 10;
  SevenSeg seg0(res0, out0);
  SevenSeg seg1(res1, out1);

  // CPU Logic
  always @(posedge clk) begin
    if (start) begin
      // Initialization
      memory[253] = 0;         // error = 0
      memory[254] = 0;         // result = 0
      memory[255] = x;         // input x
      pc = 0;
      zeroFlag = 0;
      signFlag = 0;
      sp = 0;

      // Program instructions
      memory[0]  = 8'b0001_0000; memory[1]  = 8'd255; // push M[x]
      memory[2]  = 8'b0000_0000; memory[3]  = 8'd0;   // push 0
      memory[4]  = 8'b0110_0000;                     // add
      memory[5]  = 8'b0000_0000; memory[6]  = 8'd33;  // push error addr
      memory[7]  = 8'b0101_0000;                     // jump if sign

      memory[8]  = 8'b0001_0000; memory[9]  = 8'd255; // push M[x]
      memory[10] = 8'b0000_0000; memory[11] = 8'd23;  // push 23
      memory[12] = 8'b0110_0000;                     // add
      memory[13] = 8'b0010_0000; memory[14] = 8'd100; // store to [100]
      memory[15] = 8'b0001_0000; memory[16] = 8'd100; // push M[100]
      memory[17] = 8'b0001_0000; memory[18] = 8'd100; // push M[100]
      memory[19] = 8'b0110_0000;                     // add (2x)
      memory[20] = 8'b0000_0000; memory[21] = 8'd12;  // push 12
      memory[22] = 8'b0111_0000;                     // sub

      memory[23] = 8'b0000_0000; memory[24] = 8'd33;  // push error addr
      memory[25] = 8'b0101_0000;                     // jump if sign
      memory[26] = 8'b0010_0000; memory[27] = 8'd80;  // dummy pop
      memory[28] = 8'b0010_0000; memory[29] = 8'd254; // store result
      memory[30] = 8'b0000_0000; memory[31] = 8'd37;  // push end addr
      memory[32] = 8'b0011_0000;                     // jump
      memory[33] = 8'b0000_0000; memory[34] = 8'd1;   // push 1 (error)
      memory[35] = 8'b0010_0000; memory[36] = 8'd253; // store error
    end else begin
      IR = memory[pc];
      pc = pc + 1;

      case (IR[7:4])
        4'h0: begin // PUSH CONST
          DR = memory[pc];
          pc = pc + 1;
          stack[sp] = DR;
          sp = sp + 1;
        end

        4'h1: begin // PUSH MEM
          DR = memory[pc];
          pc = pc + 1;
          stack[sp] = memory[DR];
          sp = sp + 1;
        end

        4'h2: begin // POP MEM
          DR = memory[pc];
          pc = pc + 1;
          sp = sp - 1;
          memory[DR] = stack[sp];
        end

        4'h3: begin // JUMP
          sp = sp - 1;
          pc = stack[sp];
        end

        4'h4: begin // JUMP IF ZERO
          if (zeroFlag) begin
            sp = sp - 1;
            pc = stack[sp];
          end
        end

        4'h5: begin // JUMP IF SIGN
          if (signFlag) begin
            sp = sp - 1;
            pc = stack[sp];
          end
        end

        4'h6: begin // ADD
          stack[sp-2] = stack[sp-2] + stack[sp-1];
          sp = sp - 1;
          DR = stack[sp-1];
          zeroFlag = (DR == 0);
          signFlag = DR[7];
        end

        4'h7: begin // SUB
          stack[sp-2] = stack[sp-2] - stack[sp-1];
          sp = sp - 1;
          DR = stack[sp-1];
          zeroFlag = (DR == 0);
          signFlag = DR[7];
        end

        default: ; // No-op
      endcase
    end
  end

endmodule

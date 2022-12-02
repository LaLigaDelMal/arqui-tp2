`timescale 1ns / 1ps

module alu #(
    parameter  DATA_WIDTH = 8
    ) (
        input wire i_clock, i_reset,
        input wire signed [DATA_WIDTH-1:0] i_operandA,
        input wire signed [DATA_WIDTH-1:0] i_operandB,
        input wire signed [DATA_WIDTH-1:0] i_opcode,
        
        output wire signed [DATA_WIDTH-1:0] o_result,
        output wire o_zero, o_carry, o_overflow, o_negative, o_exception, o_done
    );
   
   reg signed [DATA_WIDTH-1:0] result;
   reg signed [DATA_WIDTH-1:0]  A;
   reg signed [DATA_WIDTH-1:0]  B;
   reg signed [2:0] enters;
   reg [3:0] opcode;
   reg carry, overflow, exception, done, next_done;
   
   //RESET
   
   always @ (posedge i_clock) begin
            if (i_reset) begin
                    result <= {DATA_WIDTH{1'b0}};
                    A <= {DATA_WIDTH{1'b0}};
                    B <= {DATA_WIDTH{1'b0}};
                    opcode <= 1'b0000;
                    carry <= 0;
                    overflow <= 0;
                    exception <= 0;
                    enters <= 0;
                    //done <=0; 
            end
            //else 
                //done<=next_done;
    end   
   
   always @ (*) begin
            A = i_operandA;
            B = i_operandB;
            opcode = i_opcode;
            //next_done = 0;
            case (opcode)
                4'b1000: begin                                                          // ADD (8)
                    {carry, result} = {1'b0, A} + {1'b0, B};
                    overflow = (A[DATA_WIDTH - 1] ^ B[DATA_WIDTH - 1]) ? 0 : (result[DATA_WIDTH - 1] != A[DATA_WIDTH - 1]);
                end
                4'b1010: begin                                                          // SUB (10)
                    {carry, result} = {1'b0, A} - {1'b0, B};
                    overflow = (A[DATA_WIDTH - 1] ^ B[DATA_WIDTH - 1]) ? (result[DATA_WIDTH - 1] == B[DATA_WIDTH - 1]) : 0;
                end
                4'b1100: begin                                                          // AND (12)
                    result = A & B;
                end
                4'b1101: begin                                                          // OR  (13)
                    result = A | B;
                end
                4'b1110: begin                                                         // XOR  (14)
                    result = A ^ B;
                end
                4'b0011: begin                                                         // SRA  (3)
                    carry = A[0];
                    result = A >>> 1;
                end
                4'b0010: begin                                                        // SRL   (2)
                    carry = A[0];
                    result = A >> 1;
                end
                default : exception = 1;                                   // Undefined Opcode
           endcase
           //if(|opcode)
                //done <= 1;
                //next_done <= 0;
           
end

    assign o_result = result[DATA_WIDTH-1:0];
    assign o_zero = result == {DATA_WIDTH-1{1'b0}};
    assign o_negative = result[DATA_WIDTH-1];
    assign o_carry = carry;
    assign o_overflow = overflow;
    assign o_exception = exception;
    assign o_done = done;

endmodule

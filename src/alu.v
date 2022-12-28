`timescale 1ns / 1ps

module alu #(
    parameter  DATA_WIDTH = 8
    ) (
        input wire i_clock, i_reset,
        input wire signed [DATA_WIDTH-1:0] i_operandA,
        input wire signed [DATA_WIDTH-1:0] i_operandB,
        input wire signed [3:0] i_opcode,
        
        output reg signed [DATA_WIDTH-1:0] o_result,
        output reg o_zero, o_carry, o_overflow, o_negative, o_exception
    );
    
    always @ (*) begin
        o_exception = 0;
        o_zero = ~|o_result[DATA_WIDTH-1:0];
        o_negative = o_result[DATA_WIDTH-1];
        o_carry = 0;
        o_overflow = 0;
    end
   
    always @ (*) begin
              
        case (i_opcode)
            4'b1000: begin                                                          //ADD (8)
                {o_carry, o_result} = {1'b0, i_operandA} + {1'b0, i_operandB};
                o_overflow = (i_operandA[DATA_WIDTH - 1] ^ i_operandB[DATA_WIDTH - 1]) ? 
                                0 : (o_result[DATA_WIDTH - 1] != i_operandA[DATA_WIDTH - 1]);
            end
            4'b1010: begin                                                          // SUB (10)
                {o_carry, o_result} = {1'b0, i_operandA} - {1'b0, i_operandB};
                o_overflow = (i_operandA[DATA_WIDTH - 1] ^ i_operandB[DATA_WIDTH - 1]) ? 
                                (o_result[DATA_WIDTH - 1] == i_operandB[DATA_WIDTH - 1]) : 0;
            end
            4'b1100: begin                                                          // AND (12)
                o_result = i_operandA & i_operandB;
            end
            4'b1101: begin                                                          // OR  (13)
                o_result = i_operandA | i_operandB;
            end
            4'b1110: begin                                                         // XOR  (14)
                o_result = i_operandA ^ i_operandB;
            end
            4'b0011: begin                                                         // SRA  (3)
                o_carry = i_operandA[0];
                o_result = i_operandA >>> 1;
            end
            4'b0010: begin                                                        // SRL   (2)
                o_carry = i_operandA[0];
                o_result = i_operandA >> 1;
            end
            default : o_exception = 1;                                   // Undefined Opcode
        endcase
           
    end
    
endmodule

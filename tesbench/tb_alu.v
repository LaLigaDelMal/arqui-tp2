`timescale 1ns / 1ps

module tb_alu();

    // Inputs
     reg[7:0] operandA, operandB;
     reg[3:0] opcode;
     reg clock, reset;
     
     // Outputs
     wire[7:0] result;
     wire exception, zero, carry, overflow, negative, done;
     
     alu dut (    
        .i_clock(clock),
        .i_reset(reset),
        .i_operandA(operandA),
        .i_operandB(operandB),
        .i_opcode(opcode),
        .o_result(result),
        .o_zero(zero),
        .o_carry(carry),
        .o_overflow(overflow),
        .o_negative(negative),
        .o_exception(exception),
        .o_done(done)
);
                    
        initial begin
            clock = 0;
            operandA = 0;
            operandB = 0;
            opcode = 0;
            #5 reset = 1;
            #5 reset = 0;
        end
                 
        always  
                begin
                    #5 clock = ~clock;
                end
  
        initial begin
              // Suma
            #10 
            operandA = 4;
            operandB = 5;
            opcode = 4'b1000;
            #1
            // Resta
            //reset = 1;
            //#10 reset = 0;
            operandA = -10;
            operandB = 128;
            opcode = 4'b1010;
            #1
            // And
            operandA = 16;
            operandB = 127;
            opcode = 4'b1100;
            /*
             // Or
            reset = 1;
            #10 reset = 0;
            #10 operand = 128;
            #10 enter = 1;
            #10 enter = 0;
            #10 operand = 128;
            #10 enter = 1;
            #10 enter = 0;
            #10 operand = 4'b1101;
            #10 enter = 1;
            #10 enter = 0;
            #50
             // XOR
            reset = 1;
            #10 reset = 0;
            #10 operand = 8'b00001111;
            #10 enter = 1;
            #10 enter = 0;
            #10 operand = 8'b00011111;
            #10 enter = 1;
            #10 enter = 0;
            #10 opcode = 4'b1110;
            #10 enter = 1;
            #10 enter = 0;
            #50
             // SRA
            reset = 1;
            #10 reset = 0;
            #10 operand = 8'b10001111;
            #10 enter = 1;
            #10 enter = 0;
            #10 operand = 0;
            #10 enter = 1;
            #10 enter = 0;
            #10 operand = 4'b0011;
            #10 enter = 1;
            #10 enter = 0;
            #50
            // SRA
            reset = 1;
            #10 reset = 0;
            #10 operand = 8'b10001111;
            #10 enter = 1;
            #10 enter = 0;
            #10 operand = 0;
            #10 enter = 1;
            #10 enter = 0;
            #10 operand = 4'b0010;
            #10 enter = 1;
            #10 enter = 0;
            */
            
        end
    
    
endmodule

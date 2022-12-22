`timescale 1ns / 1ps
//WIP
module interface #(
        parameter DATA_WIDTH = 8
    )(
        input  wire i_clock,
        input  wire i_reset,
        
        //RX FIFO WIRES
        input  wire [DATA_WIDTH-1:0] i_rxff_data,
        input  wire i_rxff_empty,
        
        output reg o_rxff_read,
        
        //ALU (Ordenado por orden de funcionamiento)
        output reg [DATA_WIDTH-1:0] o_operandA,
        output reg [DATA_WIDTH-1:0] o_operandB,
        output reg [DATA_WIDTH-1:0] o_opcode,
        
        input  wire [DATA_WIDTH-1:0] i_result, 
        
        //FX FIFO WIRES
        input  wire i_txff_full,
        
        output reg [DATA_WIDTH-1:0] o_txff_data,
        output reg o_txff_write
        
    );    
    
    reg [3:0] state, next_state;
    
    //wire alu_exception, alu_zero, alu_carry, alu_overflow, alu_negative, alu_done; //TODO: Checkear
    
    //// Finite State Machine 
    localparam NSTATES = 5;
    localparam NSTATE_BITS = $clog2(NSTATES);
    // States
    localparam [NSTATE_BITS-1:0] IDLE = 0;
    localparam [NSTATE_BITS-1:0] INPUT_A = 1;
    localparam [NSTATE_BITS-1:0] INPUT_B  = 2;
    localparam [NSTATE_BITS-1:0] INPUT_OPC  = 3;
    localparam [NSTATE_BITS-1:0] SEND  = 4;
    
    //RESET
    always @(posedge i_clock) begin
         if(i_reset)begin
            state <= IDLE;
         end
         else begin
            state <= next_state;
         end
    end    
    
    
    always @(*) begin
        //next_state = state;
        
        o_txff_write = 0;
        o_rxff_read = 0;
        
        case(state)
            IDLE: begin
                if(!i_rxff_empty) begin
                    next_state = INPUT_A;
                end
            end
            INPUT_A: begin
                o_rxff_read = 1;
                o_operandA = i_rxff_data;
                
                if(!i_rxff_empty) begin
                    next_state = INPUT_B;
                end
            end
            INPUT_B: begin
                o_rxff_read = 1;
                o_operandB = i_rxff_data;
                
                if(!i_rxff_empty) begin
                    next_state = INPUT_OPC;
                end
            end
            INPUT_OPC: begin
                o_rxff_read = 1;
                o_opcode = i_rxff_data[3:0];
                next_state = SEND;
            end
            SEND: begin
                if(!i_txff_full) begin
                    o_txff_write = 1;
                    o_txff_data = i_result;
                    next_state = IDLE;
                end
            end
        endcase
        
    end
       
endmodule

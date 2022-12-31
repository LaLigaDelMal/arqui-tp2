`timescale 1ns / 1ps
//WIP
module interface #(
        parameter WORD_WIDTH = 8
    ) (
        input  wire i_clock,  i_reset,
        //ALU
        input  wire [WORD_WIDTH-1:0] i_result,

        output reg [WORD_WIDTH-1:0] o_operandA,
        output reg [WORD_WIDTH-1:0] o_operandB,
        output reg [WORD_WIDTH-1:0] o_opcode,

        //INPUT FIFO
        input  wire i_rxff_empty, i_rxff_full,
        input  wire [WORD_WIDTH-1:0] i_rxff_data,
        
        output reg o_rxff_read, o_rxff_write,
        output reg [WORD_WIDTH-1:0] o_rxff_data,

        //OUTPUT FIFO
        input  wire i_txff_empty, i_txff_full,
        input  wire [WORD_WIDTH-1:0] i_txff_data,

        output reg o_txff_read, o_txff_write,
        output reg [WORD_WIDTH-1:0] o_txff_data,

        // RX
        input wire [WORD_WIDTH-1:0] i_rx_data,
        input wire i_rx_done,

        // TX
        input wire i_tx_ready,

        output reg o_tx_start,
        output reg [WORD_WIDTH-1:0] o_tx_data
    );    

    //wire alu_exception, alu_zero, alu_carry, alu_overflow, alu_negative, alu_done; //TODO: Checkear
    
    //// Finite State Machine 
    localparam NSTATES = 6;
    localparam NSTATE_BITS = $clog2(NSTATES);
    // States
    localparam [NSTATE_BITS-1:0] IDLE       = 0;
    localparam [NSTATE_BITS-1:0] READ_RXFF  = 1;
    localparam [NSTATE_BITS-1:0] INPUT_A    = 2;
    localparam [NSTATE_BITS-1:0] INPUT_B    = 3;
    localparam [NSTATE_BITS-1:0] INPUT_OPC  = 4;
    localparam [NSTATE_BITS-1:0] WRITE_TXFF = 5;
    
    // More States
    localparam [NSTATE_BITS-1:0] WRITE_RXFF    = 1; 
    localparam [NSTATE_BITS-1:0] READ_TXFF  = 1;

    reg [NSTATE_BITS-1:0] inputs;
    reg [NSTATE_BITS-1:0] state, next_state;
    reg [NSTATE_BITS-1:0] state_rx, next_state_rx;
    reg [NSTATE_BITS-1:0] state_tx, next_state_tx;
    
    //RESET
    always @(posedge i_clock) begin
         if(i_reset)begin
            state <= IDLE;
            state_tx <= IDLE;
            state_rx <= IDLE;
            inputs <= 0;
         end
         else begin
            state <= next_state;
            state_tx <= next_state_tx;
            state_rx <= next_state_rx;
         end
    end    
    
    
    always @ (*) begin
        next_state = state;        
        
        case (state)
            IDLE: begin
                o_txff_write = 0;
                if (~i_rxff_empty) begin
                    next_state = READ_RXFF;
                end
            end
            
            READ_RXFF: begin
                o_rxff_read = 1;
                case (inputs)
                    0:
                        next_state = INPUT_A;
                    1:
                        next_state = INPUT_B;
                    2:
                        next_state = INPUT_OPC;
                    default:
                        inputs = 0;
                 endcase
            end
            
            INPUT_A: begin
                o_rxff_read = 0;
                o_operandA = i_rxff_data;
                next_state = IDLE;
                inputs = inputs + 1;
            end 
            
            INPUT_B: begin
                o_rxff_read = 0;
                o_operandB = i_rxff_data;
                next_state = IDLE;
                inputs = inputs + 1;
            end
            
            INPUT_OPC: begin
                o_rxff_read = 0;
                o_opcode = i_rxff_data[3:0];
                next_state = WRITE_TXFF;
                inputs = 0;
            end
            
            WRITE_TXFF: begin
                o_txff_data = i_result;
                if (~i_txff_full) begin
                    o_txff_write = 1;
                    next_state = IDLE;
                end
            end
        endcase
    end

    // UART RX interface with FIFO
    always @ (*) begin
        next_state_rx = state_rx;        
        
        case (state_rx)
            IDLE: begin
                o_rxff_write = 0;
                if (i_rx_done) begin
                    next_state_rx = WRITE_RXFF;
                end
            end

            WRITE_RXFF: begin
                o_rxff_data = i_rx_data;
                if (~i_rxff_full) begin
                    o_rxff_write = 1;
                    next_state_rx = IDLE;
                end
            end
        endcase
    end

    // UART TX interface with FIFO
    always @ (*) begin
        next_state_tx = state_tx;        
        
        case (state_tx)
            IDLE: begin
                o_txff_read = 0;
                o_tx_start = 0;
                if (~i_txff_empty) begin
                    o_txff_read = 1;
                    next_state_tx = READ_TXFF;
                end
            end

            READ_TXFF: begin
                o_tx_data = i_txff_data;
                if (i_tx_ready) begin
                    o_tx_start = 1;
                    next_state_tx = IDLE;
                end
            end
        endcase
    end

endmodule

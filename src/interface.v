`timescale 1ns / 1ps
//WIP
module interface #(
        parameter DATA_WIDTH = 8,
        parameter FIFO_SIZE = 4
    )(
        input wire i_clock,
        input wire i_reset,
        input wire [DATA_WIDTH-1:0] i_rx_data,
        input wire i_rx_done,
        
        output wire [DATA_WIDTH-1:0] txfifo_o_data
    );
        
    reg [3:0] state, next_state;
    
    reg [DATA_WIDTH-1:0] i_rxfifo_data;
    reg rxfifo_read, rxfifo_write;
    wire rxfifo_empty, rxfifo_full;
    wire [DATA_WIDTH-1:0] o_rxfifo_data;
    
    // Rx_FIFO-->Interface
    fifo #(.DATA_WIDTH(DATA_WIDTH),.LENGTH(FIFO_SIZE)) Rx_FIFO (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_read(rxfifo_read),
        .i_write(rxfifo_write),
        .i_data(i_rx_data),
        .o_empty(rxfifo_empty),
        .o_full(rxfifo_full),
        .o_data(o_rxfifo_data)
    );
    
    reg [DATA_WIDTH-1:0] txfifo_i_data;
    reg txfifo_read, txfifo_write;
    wire txfifo_empty, txfifo_full;
    
    // Tx_FIFO<--Interface
    fifo #(.DATA_WIDTH(DATA_WIDTH),.LENGTH(FIFO_SIZE)) Tx_FIFO (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_read(txfifo_read),
        .i_write(txfifo_write),
        .i_data(txfifo_i_data),
        .o_empty(txfifo_empty),
        .o_full(txfifo_full),
        .o_data(txfifo_o_data)
    );
    
    reg [DATA_WIDTH-1:0] operandA, operandB;
    reg [DATA_WIDTH-1:0] opcode;
    wire alu_exception, alu_zero, alu_carry, alu_overflow, alu_negative, alu_done;
    wire [DATA_WIDTH-1:0] alu_result;
    
    alu #(.DATA_WIDTH(DATA_WIDTH)) ALU (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_operandA(operandA),
        .i_operandB(operandB),
        .i_opcode(opcode),
        .o_result(alu_result),
        .o_zero(alu_zero),
        .o_carry(alu_carry),
        .o_overflow(alu_overflow),
        .o_negative(alu_negative),
        .o_exception(alu_exception),
        .o_done(alu_done)
    );
    
    
    reg finished, next_finished, next_rxfifo_write, next_rxfifo_read;
    //RESET
    always @(posedge i_clock) begin
         if(i_reset)begin
            state <= 0;
            rxfifo_write <= 0;
            rxfifo_read <= 0;
            finished <=0;
            next_finished <=0;
            next_rxfifo_write <=0;
            next_rxfifo_read <=0;
         end
         else begin
            state <= next_state;
            rxfifo_write <= next_rxfifo_write;
            rxfifo_read <= next_rxfifo_read;
            //finished <= next_finished;
         end
    end    
    
    always @(*) begin
        if(i_rx_done && !rxfifo_full && ~finished) begin
            rxfifo_write = 1;
            next_rxfifo_write = 0;
            finished = 1;
            next_state = state + 1;
        end
        else begin
            finished = 0;
            case(state)
                4'b0010: begin
                    rxfifo_read = 1;
                    next_rxfifo_read = 0;
                    operandA = o_rxfifo_data;
                end
                4'b0011: begin
                    rxfifo_read = 1;
                    next_rxfifo_read = 0;
                    operandB = o_rxfifo_data;
                end
                4'b0100: begin
                    next_rxfifo_write = 0;
                    rxfifo_read = 1;
                    opcode = o_rxfifo_data[3:0];
                    next_state = 4'b0000;
                end
            endcase
        end
    end
    
endmodule

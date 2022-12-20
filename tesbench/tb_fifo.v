`timescale 1ns / 1ps

module tb_interface();
    parameter DATA_WIDTH = 8;
    parameter FIFO_SIZE = 4;
    
    reg clk, rst;
    
    //Escribir en la fifo de RX
    reg rxfifo_write;
    reg [7:0] i_rx_data;
    
    //Interconexion
    wire rxff_empty, rxff_full, rxff_read;
    wire [DATA_WIDTH-1:0] rxfifo_data;
    
    // Rx_FIFO-->Interface
    fifo #(.DATA_WIDTH(DATA_WIDTH),.LENGTH(FIFO_SIZE)) Rx_FIFO (
        .i_clock(clk),
        .i_reset(rst),
        .i_read(rxff_read),
        .i_write(rxfifo_write),
        .i_data(i_rx_data),
        .o_empty(rxff_empty),
        .o_full(rxff_full),
        .o_data(rxfifo_data)
    );
    
    //Interface solo deberia tener interconexión
    wire [DATA_WIDTH-1:0] operandA, operandB;
    wire [DATA_WIDTH-1:0] opcode;
    
    interface dut(
        .i_clock(clk),
        .i_reset(rst),
        .i_rx_data(rxfifo_data),
        .i_rxff_empty(rxff_empty),
        .i_rxff_full(rxff_full),
        .o_rxff_read(rxff_read),
        .o_operandA(operandA),
        .o_operandB(operandB),
        .o_opcode(opcode)
        //.txfifo_o_data(out)
    );
    
    reg [DATA_WIDTH-1:0] txfifo_i_data;
    reg txfifo_read, txfifo_write;
    wire txfifo_empty, txfifo_full;
    wire [DATA_WIDTH-1:0] txfifo_o_data;
    
    // Tx_FIFO<--Interface
    fifo #(.DATA_WIDTH(DATA_WIDTH),.LENGTH(FIFO_SIZE)) Tx_FIFO(
        .i_clock(clk),
        .i_reset(rst),
        .i_read(txfifo_read),
        .i_write(txfifo_write),
        .i_data(txfifo_i_data),
        .o_empty(txfifo_empty),
        .o_full(txfifo_full),
        .o_data(txfifo_o_data)
    );
    
    wire alu_exception, alu_zero, alu_carry, alu_overflow, alu_negative, alu_done;
    wire [DATA_WIDTH-1:0] alu_result;
    
    alu #(.DATA_WIDTH(DATA_WIDTH)) ALU (
        .i_clock(clk),
        .i_reset(rst),
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
    
    initial begin
        $timeformat(-9, 2, " ns", 20);
        clk = 0;
        rst = 1;
        //i_rx_done = 0;
        #10 rst = 0;
     end
     
     always begin
        #5 clk = ~clk;     
     end
     
          
     always @(posedge clk, negedge clk) begin
        //$display("A: %b | B: %b | Op %b | Res %b", interface.operandA, interface.operandB, interface.opcode, interface.alu_result);
        //$display("%t:: RX_FIFO: %b Rxfifo_stat: %b done: %b state: %b operandA: %b, operandB: %b,  opcode: %b", $time, interface.Rx_FIFO.FIFO,interface.Rx_FIFO.FIFO_status, interface.finished,  interface.state, interface.operandA, interface.operandB, interface.opcode);
        
     end
     
     initial begin
        #10
        i_rxfifo_write = 1;
        i_rx_data = 8'b10000001;
        #1 i_rxfifo_write = 0;
        
        #9
        i_rxfifo_write = 1;
        i_rx_data  = 8'b01111110;
        #1 i_rxfifo_write = 0;
        
        #9
        i_rxfifo_write = 1;
        i_rx_data = 8'b00001000;
        #1 i_rxfifo_write = 0;
        
     end
endmodule

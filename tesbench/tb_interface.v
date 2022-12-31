`timescale 1ns / 1ps

module tb_interface();
    parameter WORD_WIDTH = 8;
    parameter FIFO_SIZE = 4;
    
    reg clk, rst;
    
    //Escribir en la fifo de RX
    wire rxfifo_write;
    wire [WORD_WIDTH-1:0] i_rx_data;
    
    //Interconexion
    wire rxff_empty, rxff_full, rxff_read;
    wire [WORD_WIDTH-1:0] rxfifo_data;
    
    // RX y TX
    reg [WORD_WIDTH-1:0] rx_data;
    wire [WORD_WIDTH-1:0] tx_data;
    reg rx_done;
    reg tx_ready;
    wire tx_start;
    
    // Rx_FIFO-->Interface
    fifo #(.WORD_WIDTH(WORD_WIDTH),.SIZE(FIFO_SIZE)) Rx_FIFO (
        .i_clock(clk),
        .i_reset(rst),
        .i_read(rxff_read),
        .i_write(rxfifo_write),
        .i_data(i_rx_data),
        .o_empty(rxff_empty),
        .o_full(rxff_full),
        .o_data(rxfifo_data)
    );
    
    wire [WORD_WIDTH-1:0] txfifo_i_data;
    wire txfifo_read;
    wire txfifo_write;
    wire txfifo_empty, txfifo_full;
    wire [WORD_WIDTH-1:0] txfifo_o_data;
    
    // Tx_FIFO<--Interface
    fifo #(.WORD_WIDTH(WORD_WIDTH),.SIZE(FIFO_SIZE)) Tx_FIFO(
        .i_clock(clk),
        .i_reset(rst),
        .i_read(txfifo_read),
        .i_write(txfifo_write),
        .i_data(txfifo_i_data),
        .o_empty(txfifo_empty),
        .o_full(txfifo_full),
        .o_data(txfifo_o_data)
    );
    
    //Interface solo deberia tener interconexión
    wire [WORD_WIDTH-1:0] operandA, operandB;
    wire [WORD_WIDTH-1:0] opcode;
       
    wire alu_exception, alu_zero, alu_carry, alu_overflow, alu_negative;
    wire [WORD_WIDTH-1:0] alu_result;
    
    alu #(.WORD_WIDTH(WORD_WIDTH)) ALU (
        .i_clock(clk),
        .i_reset(rst),
        .i_operandA(operandA),
        .i_operandB(operandB),
        .i_opcode(opcode[3:0]),
        .o_result(alu_result),
        .o_zero(alu_zero),
        .o_carry(alu_carry),
        .o_overflow(alu_overflow),
        .o_negative(alu_negative),
        .o_exception(alu_exception)
    );
    
    interface dut(
        .i_clock(clk),
        .i_reset(rst),
        .i_result(alu_result),
        .o_operandA(operandA),
        .o_operandB(operandB),
        .o_opcode(opcode),
        .i_rxff_empty(rxff_empty),
        .i_rxff_full(rxff_full),
        .i_rxff_data(rxfifo_data),
        .o_rxff_read(rxff_read),
        .o_rxff_write(rxfifo_write),
        .o_rxff_data(rxfifo_data),
        
        .i_txff_empty(txfifo_empty),
        .i_txff_full(txfifo_full),
        .i_txff_data(txfifo_o_data),
        .o_txff_read(txfifo_read),
        .o_txff_write(txfifo_write),
        .o_txff_data(txfifo_i_data),
        
        .i_rx_data(rx_data),
        .i_rx_done(rx_done),
        .i_tx_ready(tx_ready),
        .o_tx_start(tx_start),
        .o_tx_data(tx_data)
    );
    
    initial begin
        $timeformat(-9, 2, " ns", 20);
        clk = 0;
        rst = 1;
        
        #10 rst = 0;
     end
     
     always begin
        #5 clk = ~clk;     
     end
     
     always @(posedge clk, negedge clk) begin
        //$display("%t:: RX_FIFO_STATUS = %b, FIFO = %b", $time, Rx_FIFO.FIFO_status, Rx_FIFO.FIFO);
       // $display("%t:: TX_FIFO_STATUS = %b, INTER: STATE = %b, INTER_A = %b, B = %b, OPC = %b",
          //      $time, Tx_FIFO.FIFO, interface.state, interface.o_operandA, interface.o_operandB, interface.o_opcode);
          $display("%t:: INTERFACE_RX_STATUS = %b, INTERFACE_TX_STATUS = %b, INTER: STATE = %b",    $time, interface.state_rx, interface.state_tx, interface.state);
     end
     
     initial begin
        #20
         tx_ready = 1;
         
        rx_done = 1;
        rx_data = 8'b00000001;
        #10 rx_done = 0;
        
        #100
        rx_done = 1;
        rx_data = 8'b00000010;
        #10 rx_done = 0;
        
        #100
        rx_done = 1;
        rx_data = 8'b00001000;
        #10 rx_done = 0;
        
     end
endmodule

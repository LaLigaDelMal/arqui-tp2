`timescale 1ns / 1ps

module tb_interface();
    reg clk, rst, i_rx_done;
    reg [7:0] i_rx_data, out;
    interface dut(
        .i_clock(clk),
        .i_reset(rst),
        .i_rx_data(i_rx_data),
        .i_rx_done(i_rx_done)
        //.txfifo_o_data(out)
    );
    
    
    reg [2:0] sig2_sync;
    reg redge;
    initial begin
        $timeformat(-9, 2, " ns", 20);
        clk = 0;
        rst = 1;
        i_rx_done = 0;
        #10 rst = 0;
     end
     
     always begin
        #5 clk = ~clk;     
     end
     
          
     always @(posedge clk, negedge clk) begin
        //$display("A: %b | B: %b | Op %b | Res %b", interface.operandA, interface.operandB, interface.opcode, interface.alu_result);
        $display("%t:: RX_FIFO: %b Rxfifo_stat: %b done: %b state: %b operandA: %b, operandB: %b,  opcode: %b", $time, interface.Rx_FIFO.FIFO,interface.Rx_FIFO.FIFO_status, interface.finished,  interface.state, interface.operandA, interface.operandB, interface.opcode);
        
     end
     
     initial begin
        #10
        i_rx_done = 1;
        i_rx_data = 8'b10000001;
        #1 i_rx_done = 0;
        
        #9
        i_rx_done = 1;
        i_rx_data  = 8'b01111110;
        #1 i_rx_done = 0;
        
        
        #9
        i_rx_done = 1;
        i_rx_data = 8'b00001000;
        #1 i_rx_done = 0;
        
     end
endmodule


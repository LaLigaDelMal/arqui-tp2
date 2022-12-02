`timescale 1ns / 1ps

module tb_fifo;

    // Parameters
    localparam WORD = 8;        //Word Size
    localparam LEN = 4;         //Lenght
    
    //inputs
    reg clk;
    reg rst;
    reg read;
    reg write;
    reg [WORD-1:0] input_data;
    
    //Outputs
    wire empty, full;
    wire [WORD-1:0] output_data;
    
    fifo dut (
        .i_clock(clk),
        .i_reset(rst),
        .i_read(read),
        .i_write(write),
        .i_data(input_data),
        .o_empty(empty),
        .o_full(full),
        .o_data(output_data)
    );
    
    initial begin
        $timeformat(-9, 2, " ns", 20);
        clk = 0;
        read = 0;
        write = 0;
        input_data = 8'b0;
        rst = 1;
        #10 rst = 0;
     end
     
     always begin
        #5 clk = ~clk;     
     end
     
     
     always @(posedge clk, negedge clk) begin
        //$display("FIFO STATUS %b : INDEX_WRT %b : FIFO %b", fifo.FIFO_status, fifo.index_write, fifo.FIFO);
        
        $display("%t:: READ %b = FIFO STATUS %b : INDEX_RD %b : FIFO %b", $time, read, fifo.FIFO_status, fifo.index_read, fifo.FIFO);
        
        
     end
     
     initial begin
        #10
        write=1;
        input_data = 8'b10101010;
        #1 write=0;
        
        #10
        write=1;
        input_data = 8'b11111111;
        #1 write=0;
        
        #10
        read=1;
        write=1;
        input_data = 8'b10000001;
        #1 read=0;
        write=0;
        /*
        #10
        write=1;
        input_data = 8'b00000000;
        #10 write=0;
        
        #10
        write=1;
        input_data = 8'b00001111;
        #10 write=0;
        
        #10
        write=1;
        input_data = 8'b11010011;
        #10 write=0;
        
        #10
        read=1;
        #10 read=0;   
        
        #10
        read=1;
        #10 read=0;
        
        #10
        write=1;
        input_data = 8'b00001111;
        #10 write=0;
        
        #10
        read=1;
        #10 read=0;
        
        //W1001->1011
        #10
        write=1;
        input_data = 8'b00001111;
        #10 write=0;
        
        //R1011->0011->0010->0000
        #10
        read=1;
        #10 read=0;
        
        #10
        read=1;
        #10 read=0;
        
        #10
        read=1;
        #10 read=0;
        /*
        */
     end
endmodule

`timescale 1ns / 1ps


module tb_uart_tx();

    reg [7:0] data;
    reg reset, clock, tx_start;
    wire tx, tx_ready, baud_rate;

    baud_gen baudrate_generator_instance( 
                                                                                 .i_reset(reset),
                                                                                 .i_clock(clock),
                                                                                 .o_baud_rate(baud_rate) 
                                                                                 );
    uart_transmitter dut(
                                           .i_data(data),
                                           .i_clock(clock),
                                           .i_baud(baud_rate),
                                           .i_reset(reset),
                                           .i_tx_start(tx_start),
                                           .o_tx(tx),
                                           .o_tx_ready(tx_ready)
                                            );
                                            
 
    initial begin
        reset = 1'b1;
        clock = 1'b0;
        
        #60
         reset = 1'b0;
         
         #60
         data = 8'b10101011;
         
         #6000
         tx_start = 1'b1;
         #6000
         tx_start = 1'b0;       // Recordar bajar el start !!!
        
    end
    
    always  
                begin
                    #10 clock = ~clock;     // 50Mhz
                end
    
endmodule

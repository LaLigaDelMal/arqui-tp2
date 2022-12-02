`timescale 1ns / 1ps

module tb_baud_gen();

     reg reset, clock;
     wire baud_rate;
     
     baud_gen dut(
                                .i_reset(reset),
                                .i_clock(clock),
                                .o_baud_rate(baud_rate)
                                );
                                
      initial begin
            clock = 0;
            #10 reset = 1;     // Probar sacando el delay en esta linea
            #10 reset = 0;
        end
        
      always  
                begin
                    #5 clock = ~clock;     // 100Mhz
                end
                
endmodule

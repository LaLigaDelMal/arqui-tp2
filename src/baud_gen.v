`timescale 1ns / 1ps

module baud_gen
    #(
        parameter CLOCK = 100000000,
        parameter BAUD_RATE = 9600
    ) (
        input wire i_clock, i_reset,
        
        output wire o_baud_rate
    );

      localparam TICK_RATE = CLOCK/(BAUD_RATE*16);    // (2BAUD_RATE) para Tx, (2BAUD_RATE16) para Rx
      localparam COUNTER_BITS = $clog2(TICK_RATE);

      reg [COUNTER_BITS-1:0] counter;

      initial begin
            counter   = {COUNTER_BITS{1'b0}};
      end

     always @  (posedge i_clock) begin
            if (i_reset || o_baud_rate) begin
                counter <= TICK_RATE-1;
            end else begin
                counter <= counter + 1;
            end
     end

     assign o_baud_rate = ~(|counter);

endmodule

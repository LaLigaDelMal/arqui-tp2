`timescale 1ns / 1ps

module uart_receiver
    #(
        parameter NDATA_BITS = 8,
        parameter NSTOP_BITS = 1,
        parameter OVERSAMPLING = 16
      )
      (
        input wire i_rx,
        input wire i_clock,
        input wire i_baud,
        input wire i_reset,
        output wire [NDATA_BITS-1:0] o_data,
        output wire o_rx_done
      );
    
    //// Finite State Machine 
    localparam NSTATES = 4;
    localparam NSTATE_BITS = $clog2(NSTATES);
  
    // States
    localparam [NSTATE_BITS-1:0] IDLE = 0;
    localparam [NSTATE_BITS-1:0] START = 1;
    localparam [NSTATE_BITS-1:0] DATA = 2;
    localparam [NSTATE_BITS-1:0] STOP = 3;
    
    // Other Variables
    localparam NDATA_COUNTER_BITS = $clog2(NDATA_BITS);
    localparam NSTOP_COUNTER_BITS = $clog2(NSTOP_BITS);
    localparam NTICK_CTR_BITS = $clog2(OVERSAMPLING);
    reg [NDATA_BITS-1:0] data;
    reg [NDATA_COUNTER_BITS-1:0] data_counter, next_data_counter;
    reg [NSTOP_COUNTER_BITS-1:0] stop_counter, next_stop_counter;
    reg [NTICK_CTR_BITS-1:0] tick_counter, next_tick_counter;
    reg [NSTATE_BITS-1:0] state, next_state;
    reg [3:0] rx_samples_counter, next_rx_samples_counter;
    reg [2:0] rx_samples;
    reg sampling, rx_done;
  
    // Update FSM State
    always @ (posedge i_clock) begin
        if (i_reset) begin
            data_counter <= {NDATA_COUNTER_BITS{1'b0}};
            stop_counter <= {NSTOP_COUNTER_BITS{1'b0}};
            tick_counter <= {NTICK_CTR_BITS{1'b0}};
            rx_samples_counter <= 4'b0000;
            rx_samples <= 3'b000;
            state <= IDLE;
        end else begin
            tick_counter <= next_tick_counter;
            data_counter <= next_data_counter;
            stop_counter <= next_stop_counter;
            rx_samples_counter <= next_rx_samples_counter;
            state <= next_state;
        end
    end

    // Next-state logic
    always @  (*) begin
    
        next_state = state;
        next_tick_counter = tick_counter;
        next_data_counter = data_counter;
        next_rx_samples_counter = rx_samples_counter;
        
        case (state)
            IDLE: begin      
                    if (~i_rx) begin
                        next_tick_counter = {NTICK_CTR_BITS{1'b0}};
                        next_state = START;
                    end
            end

            START: begin
                if (i_baud) begin
                    if (tick_counter == (OVERSAMPLING-7)) begin      // OVERSAMPLING - 10 ?  prueba y error no queda otra
                        next_tick_counter = {NTICK_CTR_BITS{1'b0}};
                        next_data_counter = {NDATA_COUNTER_BITS{1'b0}};
                        next_state = DATA;
                    end else
                        next_tick_counter = tick_counter + 1'b1;
                end
            end

            DATA: begin
                if (i_baud) begin
                
                    if (sampling) begin
                        if (rx_samples_counter == 3) begin
                            next_rx_samples_counter = 3'b000;
                            data[data_counter] = (rx_samples[0] &  rx_samples[1]) & (rx_samples[1] &  rx_samples[2]) & (rx_samples[0] &  rx_samples[2]);  // Majority circuit
                        end else begin
                            next_rx_samples_counter = rx_samples_counter + 1'b1;
                            sampling = 1'b0;
                        end
                    end
                    
                    if (tick_counter == (OVERSAMPLING-4)) begin
                        
                        sampling = 1'b1;
                        
                        next_tick_counter = {NTICK_CTR_BITS{1'b0}};
                        if (data_counter == NDATA_BITS-1) begin
                            next_stop_counter = {NSTOP_COUNTER_BITS{1'b0}};
                            next_state = STOP;
                        end else begin
                            next_data_counter = data_counter + 1'b1;
                        end
                    end else
                        next_tick_counter = tick_counter + 1'b1;
                end
            end

            STOP: begin
                if (i_baud) begin
                    if (tick_counter == (OVERSAMPLING-3)) begin
                        next_tick_counter = {NTICK_CTR_BITS{1'b0}};
                        if (stop_counter == NSTOP_BITS-1) begin
                            next_state = IDLE;
                        end else begin
                            next_stop_counter = stop_counter + 1'b1;
                        end        
                    end else
                        next_tick_counter = tick_counter + 1'b1;
                end
            end
            
        endcase
    end
    
endmodule

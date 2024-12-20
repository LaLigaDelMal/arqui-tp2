`timescale 1ns / 1ps

module fifo #(
		parameter WORD_WIDTH = 8, //Columnas
		parameter SIZE = 4	 //Filas
	) (
	    input wire i_clock, i_reset,
		input wire i_read, i_write,
		input wire [WORD_WIDTH-1:0] i_data,  //For Writing to FIFO
		
		output wire o_empty, o_full,
		output wire [WORD_WIDTH-1:0] o_data  //For Reading from FIFO
	);
	
	localparam CTR_SZ = $clog2(SIZE);
	
	reg empty;
	reg full;
	
	reg [WORD_WIDTH-1:0] dataOut;

	reg [WORD_WIDTH-1:0] FIFO[SIZE-1:0];
	reg [SIZE-1:0] FIFO_status;
	
	reg [CTR_SZ-1:0] index_read, index_write;
	reg [CTR_SZ-1:0] next_index_read, next_index_write;

	integer i;
	
    //RESET
	always @ (posedge i_clock) begin
        if (i_reset) begin
            FIFO_status <= {SIZE{1'b0}};
            full <= 1'b0;
            empty <= 1'b1;
            index_read <= {CTR_SZ{1'b0}};
            index_write <= {CTR_SZ{1'b0}};
            next_index_read <= {CTR_SZ{1'b0}};
            next_index_write <= {CTR_SZ{1'b0}};
		end
		else begin
            index_write <= next_index_write;
            index_read <= next_index_read;
		end
	end

	always @ (*) begin
	    next_index_write = index_write;
	    next_index_read = index_read;
	end
    
    //WRITING
    always @ (posedge i_write) begin
        if (~FIFO_status[index_write]) begin
			FIFO[index_write] = i_data;
			FIFO_status[index_write] = 1'b1;
			
			if(index_write == SIZE) begin
				next_index_write = 0;
			end
		end
		
        next_index_write = index_write + 1;
    end
    
    //READING
    always @ (posedge i_read) begin
        if (FIFO_status[index_read]) begin
			dataOut = FIFO[index_read];
			FIFO_status[index_read] = 1'b0;
			next_index_read = index_read + 1;

			if (index_read == SIZE) begin
				next_index_read = 0;
			end 
		end
		
        next_index_read = index_read + 1;
    end
    
	assign o_data = dataOut;
	assign o_empty = ~|FIFO_status;
	assign o_full = &FIFO_status;

endmodule

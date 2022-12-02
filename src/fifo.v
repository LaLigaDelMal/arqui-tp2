`timescale 1ns / 1ps

module fifo #(
		parameter DATA_WIDTH = 8, //Columnas
		parameter LENGTH = 4	 //Filas
	)(
	   //Relevant for Reading: i_read, i_data, o_empty
		input wire i_clock, i_reset,
		input wire i_read, i_write,
		input wire [DATA_WIDTH-1:0] i_data, //For Writing to FIFO
		
		output wire o_empty, o_full,
		output wire [DATA_WIDTH-1:0] o_data //For Reading from FIFO
	);
	
	localparam CTR_SZ = $clog2(LENGTH);
	
	reg empty;
	reg full;
	
	reg [DATA_WIDTH-1:0] dataOut;

	reg [DATA_WIDTH-1:0] FIFO[LENGTH-1:0];
	reg [LENGTH-1:0] FIFO_status;
	
	reg [CTR_SZ-1:0] index_read, index_write;
	reg [CTR_SZ-1:0] next_index_read, next_index_write;

	integer i;

    //RESET
	always @(*) begin
        if (i_reset) begin
            FIFO_status <= {LENGTH{1'b0}};
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

    //READING
	always @(posedge i_clock) begin
		if(i_read && FIFO_status[index_read]) begin
			dataOut <= FIFO[index_read];
			FIFO_status[index_read] <= 1'b0;
			next_index_read <= index_read + 1;

			full <= 1'b0;

			if(index_read == LENGTH) begin
				next_index_read <= 0;
			end 
		end

		if( ~ ( |FIFO_status ) ) begin
			empty <= 1;
		end
	end

    //WRITING
    // When flag full is set you cannot write to FIFO you fool
	always @(posedge i_clock) begin
		
		if(i_write && ~FIFO_status[index_write]) begin
			FIFO[index_write] <= i_data;
			FIFO_status[index_write] <= 1'b1;
			next_index_write <= index_write + 1;

			empty <= 0;
			
			if(index_write == LENGTH) begin
				next_index_write <= 0;
			end 
		end
		
		if(&FIFO_status) begin
			full <= 1'b1;
		end

	end

	assign o_data = dataOut;
	assign o_empty = empty;
	assign o_full = full;

endmodule

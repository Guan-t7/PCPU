// Simulated RAM rather than IP. Easier to build
module data_ram (
	input wire clka,
	input wire cs,
	input wire wea,
	input wire [9:0] addra,
	input wire [31:0] dina,
	output reg [31:0] douta,
	output reg ack
	);
	parameter DELAY = 3;
	reg [DELAY-1:0] sr;
	reg [31:0] data [0:(1<<10)-1];
	
	initial	begin
		$readmemh("D:/Xilinx/14.7/ArchExp03-1/PCPU/lab2_lab3_181105_data.bin", data);
	end
	
	always @(posedge clka) begin
		if (sr) begin
			if (sr[DELAY-1]) begin 
				// the end of multiple cc access, do requested write op
				if (wea) begin
					data[addra] <= dina;
				end
				// wait for #cs to end
				if (~cs) begin
					sr <= 0;
				end
			end
			else
				// delay measured in cc, provided by shift reg
				sr <= sr << 1;
		end
		else // from IDLE
			if (cs) begin
				sr <= 'b1;
			end
	end

	always @(*) begin
		douta = 'bx;
		ack = 0;
		if (sr[DELAY-1]) begin
			ack = 1;
			if (~wea) begin
				douta = data[addra];
			end
		end
	end

endmodule
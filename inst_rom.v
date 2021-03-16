// Simulated ROM rather than IP. Easier to build
module inst_rom (
	input clka,
	input cs,
	input [9:0] a,
	output reg [31:0] spo,
	output reg ack
	);
	parameter DELAY = 3;
	reg [DELAY-1:0] sr;
	reg [31:0] rom [0:(1<<10)-1];
	
	initial	begin
		$readmemh("D:/Xilinx/14.7/ArchExp05/PCPU/lab2_lab3_181105_inst.hex", rom);
		// $readmemb("D:/Xilinx/14.7/ArchExp06/PCPU/fib.bin", rom);
	end

	// support: read restart on address change on 2nd cc
	reg [9:0] req_a;
	wire addr_change = (req_a != a);
	always @(posedge clka) begin
		req_a <= a;
	end

	always @(posedge clka) begin
		if (sr) begin
			if (addr_change) sr <= 'b1;
			else begin
				if (sr[DELAY-1]) begin 
					// the end of multiple cc access
					// wait for #cs to end
					if (~cs) sr <= 0;
				end
				// multiple cc access in progress
				else sr <= sr << 1;				
			end 
		end
		else // from IDLE
			if (cs) sr <= 'b1;
	end
	
	always @(*) begin
		spo = 'bx;
		ack = 0;
		if (sr[DELAY-1]) begin
			ack = ~addr_change; // spo valid
			spo = rom[req_a];
		end
	end
	
endmodule
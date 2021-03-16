// direct-mapped; write-back; write-allocate
module CMU #(
	parameter ADDR_W = 10,
	parameter INDEX_W = 5
) (
	input wire clka,
	// CPU interface
	input wire cs,
	input wire wea,
	input wire [ADDR_W-1:0] addra,
	input wire [31:0] dina,
	output reg [31:0] douta,
	output reg ack,
	// Mem interface
	output reg mem_cs,
	output reg mem_wea,
	output reg [ADDR_W-1:0] mem_addra,
	output reg [31:0] mem_dina,
	input [31:0] mem_douta,
	input mem_ack
	);

	reg _v [0:(1<<INDEX_W)-1];
	reg _d [0:(1<<INDEX_W)-1];
	reg [9-INDEX_W:0] _tag [0:(1<<INDEX_W)-1];
	reg [31:0] _data [0:(1<<INDEX_W)-1];
	
	integer i;
	initial	begin
		for (i=0; i < 1<<INDEX_W; i=i+1) begin
			_v[i] = 0;
		end
	end

	wire [INDEX_W-1:0] index = addra[INDEX_W-1:0];
	wire [ADDR_W-INDEX_W-1:0] tag = addra[ADDR_W-1:INDEX_W];
	wire hit = _v[index] && (_tag[index] == tag);
	
	parameter 
		IDLE = 2'd0,
		BACK = 2'd1,
		ALLOCATE = 2'd2;
	reg [1:0] state = IDLE;

	always @(posedge clka) begin
		case (state)
			IDLE: begin
				if (cs) begin
					if (hit) begin
						if (wea) begin
							_data[index] <= dina;
							_d[index] <= 1;							
						end
					end
					// write allocate
					else begin
						// write back
						if (_v[index] && _d[index])
							state <= BACK;
						else
							state <= ALLOCATE;
					end					
				end
			end
			BACK: begin
				if (mem_ack)
					state <= ALLOCATE;
			end
			ALLOCATE: begin
				if (mem_ack) begin
					_v[index] <= 1;
					_d[index] <= 0;
					_tag[index] <= tag;
					_data[index] <= mem_douta;

					state <= IDLE;
				end
			end
		endcase
	end

	always @(*) begin
		douta = 'bx; ack = 'b0;
		mem_cs = 'b0; mem_wea = 'b0; 
		mem_addra = 'bx; mem_dina = 'bx;
		case (state)
			IDLE: begin
				if (cs) begin
					if (hit) begin
						ack = 1;
						if (~wea)
							douta = _data[index];
					end					
				end
			end
			BACK: begin
				mem_wea = 1;
				mem_cs = ~mem_ack;
				mem_addra = {_tag[index], index};
				mem_dina = _data[index];
			end
			ALLOCATE: begin
				mem_cs = ~mem_ack;
				mem_addra = {tag, index};
			end
		endcase
	end

//! addr_change in BACK state results in new cache block be written
// robust to addr_change in ALLOCATE state
endmodule
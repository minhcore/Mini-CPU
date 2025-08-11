module CIR (
	input wire clk,
	input wire reset,
	input wire in_enable,
	input wire out_enable,
	input wire [15:0] in_data,
	output reg [7:0] opcode,
	output reg [7:0] operand,
	output reg [7:0] bus_out
);

	reg [15:0] data;
	always @(posedge clk) begin
		if (reset)
			data <= 16'b0;
		else if (in_enable)
			data <= in_data;
	end
	always @(*) begin
		opcode = data [15:8]; // MSB
		operand = data [7:0]; // LSB
		
		if (out_enable)
			bus_out = data [7:0];
		else 
			bus_out = 8'bz;
	end
endmodule
	
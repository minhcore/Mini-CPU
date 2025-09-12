module regC #(parameter WIDTH = 8)(
	input wire clk,
	input wire reset,
	input wire in_enable,
	input wire out_enable,
	input wire sel,
	input wire [WIDTH-1:0] ALU_in,
	input wire [WIDTH-1:0] BUS_in,
	output wire [WIDTH-1:0] data_out, // tristate
	output wire [WIDTH-1:0] out_data // direct
);
	reg [WIDTH-1:0] data;
	always @(posedge clk) begin
		if (reset)
			data <= 0;
		else if (in_enable) begin
			case (sel)
				1'b0: data <= ALU_in;
				1'b1: data <= BUS_in;
			endcase
		end
	end
	assign data_out = out_enable ? data : 8'bz;
	assign out_data = data;
endmodule
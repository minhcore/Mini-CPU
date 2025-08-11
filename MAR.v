module MAR #(parameter WIDTH = 8)(
	input  clk,
	input  reset,
	input  in_enable,
	input  [WIDTH-1:0] in_data,
	output reg [WIDTH-1:0] ROM_data
);
	always @(posedge clk) begin
		if (reset)
			ROM_data <= 0;
		else if (in_enable)
			ROM_data <= in_data;
	end
endmodule
				
module register #(parameter WIDTH = 8)(
	input 					clk,
	input					reset,
	input					in_enable,
	input					out_enable,
	input					inc_enable,
	output 	[WIDTH-1:0]		out_data, // Direct read
	output 	[WIDTH-1:0]		data_out, // Bus output
	input 	[WIDTH-1:0]	in_data
);
	reg [WIDTH-1:0] data;
	
	always @(posedge clk) begin
		if (reset)
			data <= {WIDTH{1'b0}};  
		else if (in_enable)
			data <= in_data;
		else if (inc_enable)
			data <= data + 1;
	end

	assign data_out = out_enable ? data : 'bz;
	assign out_data = data;
endmodule
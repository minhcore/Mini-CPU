module SC (
	input 					clk,
	input					reset,
	input					reset_mol,
	input					in_enable,
	input					out_enable,
	input					inc_enable,
	output 	[3:0]		out_data, // Direct read
	output 	[3:0]		data_out, // Bus output
	input   [3:0]	in_data
);
	reg [3:0] data;
	
	always @(posedge clk) begin
		if (reset || reset_mol)
			data <= 4'b0; 
		else if (in_enable)
			data <= in_data;
		else if (inc_enable)
			data <= data + 1;
	end

	assign data_out = out_enable ? data : 'bz;
	assign out_data = data;
endmodule
module ram #(
    parameter WIDTH = 8,  // width of data
    parameter DEPTH = 256 // number of words
)(
    input clk,                            // clock
    input we,                             // write enable
	input re,							  // read enable 
    input [$clog2(DEPTH)-1:0] addr,       // address
    input [WIDTH-1:0] data_in,         // data to write
    output reg [WIDTH-1:0] data_out      // data read out
);
    reg [WIDTH-1:0] mem [0:DEPTH-1];
	always @(posedge clk) begin
		if (we) begin
			mem[addr] <= data_in;      // ghi vào RAM
		end
		if (re) begin
			data_out <= mem[addr];       // đọc từ RAM
		end else begin
			data_out <= {WIDTH{1'bz}};
		end
    end
endmodule

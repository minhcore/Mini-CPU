module flag_check (
	input wire clk,
	input wire [7:0] data,
	input wire latch,
	input wire C_ALU,
	input wire V_ALU,
	output reg Z,
	output reg N,
	output reg C,
	output reg V
);
always @(posedge clk) begin
if (latch) begin
	Z <= (data == 8'b00000000);
	N <= data[7];
	C <= C_ALU;
	V <= V_ALU;
end
end
endmodule


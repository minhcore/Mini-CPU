module alu (
	input [7:0] A,
	input [7:0] B,
	input [7:0] opcode,
	output reg [7:0] result,
	output reg C,
	output reg V
);
reg [7:0] sub;
reg [7:0] V_tmp;
reg [7:0] N_tmp;
always @(*) begin
result = 8'b0;
C = 0; V = 0;
case (opcode)
	8'b0000_0000: begin
		{C,result} = A + B;
		V = ((A[7] == B[7]) && (result[7] != A[7]));
	end
	8'b0000_0001: begin
		{C,result} = A - B;
		V = ((A[7] != B[7]) && (result[7] != A[7]));
	end
	8'b0000_0010: begin
		result = A & B;
	end
	8'b0000_0011: begin
		result = A | B;
	end
	8'b0000_0100: begin
		result = A ^ B;
	end
	8'b0000_0101: begin
		sub = A - B;
		V_tmp = ((A[7] != B[7]) && (sub[7] != A[7]));
		N_tmp = sub[7];
		result = {7'b0, N_tmp ^ V_tmp};
	end
	8'b0000_0110: begin
		{C, result} = B + 1;
		V = ((B[7] == 0) && (result[7] != 0));
	end
	8'b0000_0111: begin
		{C, result} = B - 1;
		V = ((B[7] == 1) && (result[7] != 1));
	end
	8'b0000_1000: begin
		result = B << 1;
		C = B[7];
	end
	8'b0000_1001: begin 
		result = B >> 1;
		C = B[0];
	end
	8'b0000_1010: begin
		result = B >>> 1;
		C = B[0];
	end
	8'b0000_1011: begin
		result = {B[6:0],B[7]};
	end
	8'b0000_1100: begin
		result = {B[0],B[7:1]};
	end
	default: begin
		result = 8'b00000000;
		C = 0;
		V = 0;
	end
endcase
end
endmodule
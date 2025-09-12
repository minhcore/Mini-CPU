module bcd_to_7led (
	input [3:0] bcd,
	input mode,
	output reg [6:0] seg
);
always @(*) begin
	if (mode == 1'b0) begin
	seg = 7'b0000001;
	end else begin
	case (bcd)
		4'd0: seg = 7'b1111110;
		4'd1: seg = 7'b0011000;
		4'd2: seg = 7'b1101101;
		4'd3: seg = 7'b0111101;
		4'd4: seg = 7'b0011011;
		4'd5: seg = 7'b0110111;
		4'd6: seg = 7'b1110111;
		4'd7: seg = 7'b0011100;
		4'd8: seg = 7'b1111111;
		4'd9: seg = 7'b0111111;
		default: seg = 7'b0000000;
	endcase
	end
end
endmodule
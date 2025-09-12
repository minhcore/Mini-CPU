module hex_to_decimal (
	input			[7:0] in,
	input			signed_flag,
	input 			mode,
	output 			[6:0] led_ones,
	output			[6:0] led_tens,
	output			[6:0] led_hundreds,
	output reg		led_signed
);
reg [19:0] tmp;
reg [7:0] data;
reg [3:0] ones, tens, hundreds;
integer i;
always @(*) begin
	if (signed_flag) data = ~in + 1;
	else data = in;
	
	tmp = 20'd0;
	tmp[7:0] = data;
	
	for (i = 0; i < 8; i = i + 1) begin
		if (tmp[11:8] > 4) tmp[11:8] = tmp[11:8] + 3;
		if (tmp[15:12] > 4) tmp[15:12] = tmp[15:12] + 3;
		if (tmp[19:16] > 4) tmp[19:16] = tmp[19:16] + 3;
		tmp = tmp << 1;
	end
	hundreds = tmp[19:16];
	tens = tmp[15:12];
	ones = tmp[11:8];
	led_signed = signed_flag;
end
bcd_to_7led led_ones_module (
	.bcd(ones),
	.mode(mode),
	.seg(led_ones)
);
bcd_to_7led led_tens_module (
	.bcd(tens),
	.mode(mode),
	.seg(led_tens)
);
bcd_to_7led led_hundreds_module (
	.bcd(hundreds),
	.mode(mode),
	.seg(led_hundreds)
);
endmodule
		
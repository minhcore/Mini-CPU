module rom #(
parameter WIDTH = 16,
parameter DEPTH = 256
)(
input [$clog2(DEPTH)-1:0] addr,
output reg [WIDTH-1:0] data
);
always @(*) begin
case(addr)
8'h00: data = 16'h1300;
8'h01: data = 16'h1003;
8'h02: data = 16'h1004;
8'h03: data = 16'h13A6;
8'h04: data = 16'h1000;
8'h05: data = 16'h1142;
8'h06: data = 16'h1306;
8'h07: data = 16'h1001;
8'h08: data = 16'h1A26;
8'h09: data = 16'h0F00;
8'h0A: data = 16'h1A30;
8'h0B: data = 16'h0D00;
8'h0C: data = 16'h0F01;
8'h0D: data = 16'h0550;
8'h0E: data = 16'h1617;
8'h0F: data = 16'h1250;
8'h10: data = 16'h0F01;
8'h11: data = 16'h0150;
8'h12: data = 16'h1142;
8'h13: data = 16'h1253;
8'h14: data = 16'h0600;
8'h15: data = 16'h115A;
8'h16: data = 16'h140C;
8'h17: data = 16'h1253;
8'h18: data = 16'h1005;
8'h19: data = 16'h0F03;
8'h1A: data = 16'h1142;
8'h1B: data = 16'h0F04;
8'h1C: data = 16'h0450;
8'h1D: data = 16'h1524;
8'h1E: data = 16'h13FF;
8'h1F: data = 16'h1142;
8'h20: data = 16'h0F05;
8'h21: data = 16'h0450;
8'h22: data = 16'h0600;
8'h23: data = 16'h1425;
8'h24: data = 16'h1253;
8'h25: data = 16'h0E00;
8'h26: data = 16'h13FF;
8'h27: data = 16'h117A;
8'h28: data = 16'h0F01;
8'h29: data = 16'h0457;
8'h2A: data = 16'h0600;
8'h2B: data = 16'h1001;
8'h2C: data = 16'h1254;
8'h2D: data = 16'h0600;
8'h2E: data = 16'h1003;
8'h2F: data = 16'h1409;
8'h30: data = 16'h13FF;
8'h31: data = 16'h114A;
8'h32: data = 16'h0F00;
8'h33: data = 16'h0451;
8'h34: data = 16'h0600;
8'h35: data = 16'h1000;
8'h36: data = 16'h1142;
8'h37: data = 16'h1255;
8'h38: data = 16'h0600;
8'h39: data = 16'h1004;
8'h3A: data = 16'h140B;
default: data = 16'h0000;
endcase
end
endmodule

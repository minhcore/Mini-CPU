`timescale 1ns/1ps
module tb_uart_ram;
localparam CLK_PERIOD = 37; //~27MHz
localparam DELAY = 234; //baudrate 115200

reg clk, reset, button, rx;
reg [7:0] addrPC = 8'd0;
wire [15:0] dataOut;
wire mode;

uart_ram #(.DELAY(DELAY)) dut (
    .clk(clk),
    .button(button),
    .reset(reset),
    .rx(rx),
    .addrPC(addrPC),
    .dataOut(dataOut),
    .mode(mode)
);

initial clk = 0;
always #(CLK_PERIOD/2) clk = ~clk;

task uart_send_byte(input [7:0] data);
integer i;
    
    begin
        rx <= 1'b0; repeat(DELAY) @(posedge clk);

        for (i=0; i < 8; i = i + 1) begin
            rx <= data[i];
            repeat(DELAY) @(posedge clk);
        end

        rx <= 1'b1; repeat(DELAY) @(posedge clk);
    end
endtask

initial begin
rx = 1;
reset = 1;
button = 1;
addrPC = 8'd0;
repeat (10) @(posedge clk);
reset = 0;


//load mode (mode = 0)
//write w1 130B
uart_send_byte(8'h0B); //low
uart_send_byte(8'h13); //high

//write w2 0E00
uart_send_byte(8'h00); //low
uart_send_byte(8'h0E); //high

//run mode (mode = 1);
repeat (500) @(posedge clk);
button <= 0; repeat (5) @(posedge clk);
button <= 1; repeat (5) @(posedge clk);

//read w1
addrPC = 8'd0; repeat(100) @(posedge clk);
$display("mem[0] = 0x%h", dataOut);

//read w2
addrPC = 8'd1; repeat(100) @(posedge clk);
$display("mem[1] = 0x%h", dataOut);

$stop;
end
endmodule
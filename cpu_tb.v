`timescale 1ns/1ps
module cpu_tb;
localparam CLK_PERIOD = 37;
localparam DELAY = 234;

reg clk, reset_n, n_but, rx;

top_cpu dut (
    .clk(clk),
    .reset_n(reset_n),
    .n_but(n_but),
    .uart_rx(rx),
    .N_led(),
    .led_hundreds(),
    .led_tens(),
    .led_ones(),
    .led_debug()
);

initial
clk = 0;

always #(CLK_PERIOD/2) clk = ~clk;

task uart_send_byte (input [7:0] data);
integer i;

begin
    rx <= 1'b0; repeat(DELAY) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) begin
        rx <= data[i];
        repeat(DELAY) @(posedge clk);
    end
    rx <= 1'b1; repeat (DELAY) @(posedge clk);
end
endtask

initial begin
rx = 1;
reset_n = 1;
n_but = 1;
repeat(5) @(posedge clk);
reset_n = 0;
repeat(5) @(posedge clk);
reset_n = 1;

//load mode (mode = 0)
//write w1 130B
uart_send_byte(8'h0B); //low
uart_send_byte(8'h13); //high

//write w2 0E00
uart_send_byte(8'h00); //low
uart_send_byte(8'h0E); //high

//run mode (mode = 1);
repeat (500) @(posedge clk);
n_but <= 0; repeat (5) @(posedge clk);
n_but <= 1; repeat (5) @(posedge clk);
repeat (DELAY*100) @(posedge clk);
$stop;
end
always @(posedge clk) begin
    $display("Time=%0t | C=%h", $time, dut.regC.out_data);
end
endmodule
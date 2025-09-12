module ram_programable 
#(
    parameter WIDTH = 16,
    parameter DEPTH = 256
)
 
(
    input n_but,
    input clk,
    input uart_rx,
    input [$clog2(DEPTH)-1:0] addr,
    output reg [WIDTH-1:0] data,
    output reg mode 
);

wire [7:0] rx_byte;
wire rx_valid;
reg [WIDTH-1:0] mem [0:DEPTH-1];
reg [7:0] highByte;
reg byteFlag = 0;
reg [$clog2(DEPTH)-1:0] counter = 0;
reg modeType = 0; // 0: load, 1: run


uart reciever (
    .clk(clk),
    .uart_rx(uart_rx),
    .valid(rx_valid),
    .dataOut(rx_byte)
);



always @(posedge clk) begin
    if (!n_but == 1) modeType <= ~modeType;
    if (modeType == 0 && !n_but == 1) begin // loading mode
        if (rx_valid) begin
            if (!byteFlag) begin
                highByte <= rx_byte;
                byteFlag <= 1;
            end else begin
                mem[counter] <= {highByte, rx_byte};
                counter <= counter + 1;
                byteFlag <= 0;
            end
        end
    end else if (modeType == 1) begin
        data <= mem[addr];
        counter <= 0;
        byteFlag <= 0;
    end
mode <= modeType;
end
endmodule   



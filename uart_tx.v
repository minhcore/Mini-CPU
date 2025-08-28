module uart_tx #(
    parameter DELAY = 234
)
(
    input       clk,
    input       reset,
    input       in_enable,
    input       send_data,
    input [7:0] bus,
    output      txPin,
    output      busyFlag
);
localparam IDLE = 3'b000;
localparam START = 3'b001;
localparam WRITE = 3'b010;
localparam STOP = 3'b011;

reg [2:0] txState = 0;
reg [7:0] counter = 0;
reg [7:0] dataOut = 0;
reg txPinRegister = 1;
reg [2:0] txBitNumber = 0;
assign txPin = txPinRegister;
assign busyFlag = (txState != IDLE);

// latch from bus
always @(posedge clk) begin
    if (reset == 1'b1) dataOut <= 8'd0;
    else begin
        if (in_enable == 1'b1) dataOut <= bus;
        else dataOut <= dataOut;
    end
end
//reset
always @(posedge clk ) begin
    if (reset == 1'b1) begin
        txPinRegister <= 1'b1;
        counter <= 8'd0;
        txBitNumber <= 3'd0;
        txState <= IDLE;
    end
    else begin
//process
    case (txState)
        IDLE: begin
            if (send_data == 1'b1) begin
                txState <= START;
                counter <= 8'd0;
            end
            else begin
                txPinRegister <= 1'b1;
            end     
        end 
        START: begin
            txPinRegister <= 1'b0;
            if (counter == (DELAY - 1)) begin
                txState <= WRITE;
                txBitNumber <= 3'd0;
                counter <= 8'd0;
            end 
            else counter <= counter + 8'd1;
        end
        WRITE: begin
            txPinRegister <= dataOut[txBitNumber];
            if (counter == (DELAY - 1)) begin
                if (txBitNumber == 3'b111) begin
                    txState <= STOP;
                end
                else begin
                   txState <= WRITE;
                   txBitNumber <= txBitNumber + 3'd1; 
                end
                counter <= 8'd0;
            end
            else counter <= counter + 8'd1;
        end
        STOP: begin
            txPinRegister <= 1'b1;
            if (counter == (DELAY - 1)) begin
                counter <= 8'd0;
                if (send_data == 1'b1) txState <= START;
                else txState <= IDLE;
            end
            else counter <= counter + 8'd1;
        end
        default: txState <= IDLE;
    endcase
    end
end
endmodule


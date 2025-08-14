module uart_ram #(
    parameter DELAY = 234
)
(
    input clk, button,
    input wire reset,
    input wire rx,
    input [7:0] addrPC;
    output reg [15:0] dataOut,
    output wire mode
);

localparam HALF_DELAY = (DELAY/2);
localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam READ = 2'b10;
localparam STOP = 2'b11;

reg [1:0] state, next;
reg [7:0] counter;
reg [2:0] dataCount;
reg [7:0] dataIn;
reg syncff0, syncff1;
reg rx_;
reg [7:0] lowByte;
reg byteCount;
reg [15:0] buffer;
reg buffReady;
reg [15:0] mem [0:255];
reg modeState = 1'b0; //0: loadmode, 1:runmode
reg [23:0] modeCounter;
reg [7:0] ramAdrr;

wire counter_end, start, start_end, data_end, stop_end, get_data;
assign get_data = (counter == HALF_DELAY);
assign counter_end = (counter == DELAY);
assign start_end = (state == START) && (counter_end == 1'b1);
assign data_end = (state == READ) && (counter_end == 1'b1) && (dataCount == 3'd7);
assign stop_end = (state == STOP) && (counter_end == 1'b1);

// syn ff for rx
always @(posedge clk) begin
    if (reset == 1'b1) begin
        syncff0 <= 1'b1;
        syncff1 <= 1'b1;
    end
    else begin
        syncff0 <= rx;
        syncff1 <= syncff0;
    end
end

//start detected
    always @(posedge clk) begin
        if (reset == 1'b1) rx_ <= 1'b1;
        else rx_ <= syncff1;
    end
    
//start
    assign start = ~syncff1 && rx_;

//state
always @(posedge clk) begin
    if (reset == 1'b1) state <= IDLE;
    else state <= next;
end

//next
always @(*) begin
    case (state) 
        IDLE: begin
            if (start == 1'b1) next = START;
            else next = IDLE;
        end
        START: begin
            if (start_end == 1'b1) next = DATA;
            else next = START;
        end
        READ: begin
            if (data_end == 1'b1) next = STOP;
            else next = DATA;
        end
        STOP: begin
            if (stop_end == 1'b1) next = IDLE;
            else next = STOP;
        end
        default: next = IDLE;
    endcase
end

//counter of baudrate
always @(posedge clk) begin
    if (reset == 1'b1) counter <= 8'd0;
    else begin
        if (state != IDLE) begin
            if (counter_end == 1'b1) counter <= 8'd0;
            else counter <= counter + 8'd1;
        end
    end
end

//rx data counter
always @(posedge clk) begin
    if (reset == 1'b1) dataCount <= 3'b0;
    else if ((state == READ) && (counter_end == 1'b1)) dataCount <= dataCount + 3'd1;
end

//rx data
always @(posedge clk) begin
    if (reset == 1'b1) dataIn <= 8'd0;
    else begin
        if ((state == READ) && (get_data == 1'b1)) dataIn <= {syncff1, dataIn[7:1]};
        else dataIn <= dataIn;
    end
end

//byteLatch
always @(posedge clk) begin
    if (reset == 1'b1) begin
            buffReady == 1'b0;
            byteCount == 1'b0;
    end
    else begin
        buffReady = 1'b0;
        if (stop_end == 1'b1) begin
            if (byteCount == 0) begin
                lowByte <= dataIn;
                byteCount <= 1'b1;
            end
            else begin 
                buffer <= {dataIn, lowByte};
                buffReady <= 1'b1;
                byteCount <= 1'b0;
            end
        end
    end
end

//mode
always @(posedge clk) begin
    if (reset == 1'b1) begin
        modeState = 1'b0;
        modeCounter = 24'd0;
    end
    else begin
        if (button == 1'b0) begin
            modeCounter <= modeCounter + 24'd1;
            if (modeCounter == 24'd13500000) modeState = ~modeState;
        end
        else begin
            modeCounter <= 24'd0;
        end
    end
end

//ram 
always @(posedge clk) begin
    if (reset == 1'b1) ramAdrr == 8'd0;
    else begin
        if (modeState == 1'b0) begin        //loadmode
            if (buffReady == 1'b1) begin
                mem[ramAdrr] <= buffer;
                ramAdrr <= ramAdrr + 8'd1;
            end
            if (ramAdrr == 8'd255) ramAdrr <= 8'd0;
        end
    end
end 
always @(*) begin                           //runmode
    dataOut <= mem[addrPC];
end
assign mode = modeState;
endmodule   
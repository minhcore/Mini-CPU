module uart_ram #(
    parameter DELAY = 234
)
(
    input clk, button,
    input wire reset,
    input wire rx,
    input [7:0] addrPC,
    output reg [15:0] dataOut,
    output wire mode
);

localparam HALF_DELAY = (DELAY/2);
localparam IDLE = 3'b000; //0
localparam START = 3'b001; //1
localparam READ_WAIT = 3'b010; //2
localparam READ = 3'b011; //3
localparam STOP = 3'b100; //4
localparam STOP_WAIT = 3'b101; //5

reg [2:0] state, next;
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
reg modeState; //0: loadmode, 1:runmode
reg [7:0] ramAdrr;
reg button_ff0, button_ff1;

wire counter_end, start, start_end, data_end, stop_end, get_data, button_fall;
assign get_data = (counter == HALF_DELAY);
assign counter_end = (counter == DELAY);
assign start_end = (state == START) && (get_data == 1'b1);
assign data_end = (state == READ) && (dataCount == 3'd7);
assign stop_end = (state == STOP) && (counter == HALF_DELAY);

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
            if (start_end == 1'b1) next = READ_WAIT;
            else next = START;
        end
        READ_WAIT: begin
            if (counter_end) next = READ;
            else next = READ_WAIT;
        end
        READ: begin
            if (data_end) next = STOP_WAIT;
            else next = READ_WAIT;
        end
        STOP_WAIT: begin
            if (counter_end) next = STOP;
            else next = STOP_WAIT;
        end
        STOP: begin
            if (start == 1'b1) 
                next = START;
            else if (counter_end == 1'b1) 
                next = IDLE;
            else
                 next = STOP;
        end
        default: next = IDLE;
    endcase
end

//counter of baudrate
always @(posedge clk) begin
    if (reset == 1'b1) counter <= 8'd0;
    else begin
        if (state != IDLE) begin
            if (state == START && start_end == 1'b1) counter <= 8'd0;
            else if (state == STOP && start == 1'b1) counter <= 8'd0;
            else if (state == READ) counter <= 8'd0;
            else if (counter_end) counter <= 8'd0;
            else counter <= counter + 8'd1;
        end
    end       
end

//rx data counter
always @(posedge clk) begin
    if (reset == 1'b1) dataCount <= 3'b000;
    else if (state == START) begin 
        dataCount <= 3'b000;
    end
    else if (state == READ) dataCount <= dataCount + 3'd1;
end

//rx data
always @(posedge clk) begin
    if (reset == 1'b1) dataIn <= 8'd0;
    else begin
        if (state == READ) begin
            dataIn <= {syncff1,dataIn[7:1]};
        end
        else dataIn <= dataIn;
    end
end
//byteLatch
always @(posedge clk) begin
    if (reset == 1'b1) begin
            buffReady <= 1'b0;
            byteCount <= 1'b0;
    end
    else begin
        buffReady <= 1'b0;
        if ((next == STOP) && (state != STOP)) begin
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
        button_ff0 <= 1'b1;
        button_ff1 <= 1'b1;
    end
    else begin
        button_ff0 <= button;
        button_ff1 <= button_ff0;
    end
end

assign button_fall = (button_ff1 == 1'b1) && (button_ff0 == 1'b0);

always @(posedge clk) begin
    if (reset == 1'b1) begin
        modeState <= 1'b0;
    end
    else begin
        if (button_fall == 1'b1) 
        modeState <= ~modeState;
    end
end

//ram 
always @(posedge clk) begin
    if (reset == 1'b1) begin ramAdrr <= 8'd0; end
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
always @(posedge clk) begin                 //runmode
    if (modeState == 1'b1) begin
    dataOut <= mem[addrPC];
    end
    else dataOut <= 16'd0;
end
assign mode = modeState;
endmodule   
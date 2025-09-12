module mode_switch(
    input clk,
    input n_but,
    output reg mode
);
    reg [15:0] debounce_cnt;
    reg n_but_sync_0, n_but_sync_1;
    reg btn_state, btn_state_last;

 
    always @(posedge clk) begin
        n_but_sync_0 <= n_but;
        n_but_sync_1 <= n_but_sync_0;
    end

    
    always @(posedge clk) begin
        if (n_but_sync_1 == btn_state_last)
            debounce_cnt <= 0;
        else if (debounce_cnt < 50000)
            debounce_cnt <= debounce_cnt + 1;
        else
            btn_state <= n_but_sync_1;
        btn_state_last <= n_but_sync_1;
    end

   
    reg mode_reg;
    always @(posedge clk) begin
        if (btn_state != btn_state_last && btn_state == 1'b0)
            mode <= ~mode;
    end
endmodule

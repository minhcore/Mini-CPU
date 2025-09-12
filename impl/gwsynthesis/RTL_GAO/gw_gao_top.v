module gw_gao(
    \opcode[7] ,
    \opcode[6] ,
    \opcode[5] ,
    \opcode[4] ,
    \opcode[3] ,
    \opcode[2] ,
    \opcode[1] ,
    \opcode[0] ,
    \operand[7] ,
    \operand[6] ,
    \operand[5] ,
    \operand[4] ,
    \operand[3] ,
    \operand[2] ,
    \operand[1] ,
    \operand[0] ,
    \CU/step[3] ,
    \CU/step[2] ,
    \CU/step[1] ,
    \CU/step[0] ,
    \BUS[7] ,
    \BUS[6] ,
    \BUS[5] ,
    \BUS[4] ,
    \BUS[3] ,
    \BUS[2] ,
    \BUS[1] ,
    \BUS[0] ,
    regC_in_enable,
    \CU/SC_reset_next ,
    regC_out_enable,
    regA_in,
    regA_out,
    RAM_in,
    RAM_out,
    \regC/data[7] ,
    \regC/data[6] ,
    \regC/data[5] ,
    \regC/data[4] ,
    \regC/data[3] ,
    \regC/data[2] ,
    \regC/data[1] ,
    \regC/data[0] ,
    \regA/data[7] ,
    \regA/data[6] ,
    \regA/data[5] ,
    \regA/data[4] ,
    \regA/data[3] ,
    \regA/data[2] ,
    \regA/data[1] ,
    \regA/data[0] ,
    clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \opcode[7] ;
input \opcode[6] ;
input \opcode[5] ;
input \opcode[4] ;
input \opcode[3] ;
input \opcode[2] ;
input \opcode[1] ;
input \opcode[0] ;
input \operand[7] ;
input \operand[6] ;
input \operand[5] ;
input \operand[4] ;
input \operand[3] ;
input \operand[2] ;
input \operand[1] ;
input \operand[0] ;
input \CU/step[3] ;
input \CU/step[2] ;
input \CU/step[1] ;
input \CU/step[0] ;
input \BUS[7] ;
input \BUS[6] ;
input \BUS[5] ;
input \BUS[4] ;
input \BUS[3] ;
input \BUS[2] ;
input \BUS[1] ;
input \BUS[0] ;
input regC_in_enable;
input \CU/SC_reset_next ;
input regC_out_enable;
input regA_in;
input regA_out;
input RAM_in;
input RAM_out;
input \regC/data[7] ;
input \regC/data[6] ;
input \regC/data[5] ;
input \regC/data[4] ;
input \regC/data[3] ;
input \regC/data[2] ;
input \regC/data[1] ;
input \regC/data[0] ;
input \regA/data[7] ;
input \regA/data[6] ;
input \regA/data[5] ;
input \regA/data[4] ;
input \regA/data[3] ;
input \regA/data[2] ;
input \regA/data[1] ;
input \regA/data[0] ;
input clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \opcode[7] ;
wire \opcode[6] ;
wire \opcode[5] ;
wire \opcode[4] ;
wire \opcode[3] ;
wire \opcode[2] ;
wire \opcode[1] ;
wire \opcode[0] ;
wire \operand[7] ;
wire \operand[6] ;
wire \operand[5] ;
wire \operand[4] ;
wire \operand[3] ;
wire \operand[2] ;
wire \operand[1] ;
wire \operand[0] ;
wire \CU/step[3] ;
wire \CU/step[2] ;
wire \CU/step[1] ;
wire \CU/step[0] ;
wire \BUS[7] ;
wire \BUS[6] ;
wire \BUS[5] ;
wire \BUS[4] ;
wire \BUS[3] ;
wire \BUS[2] ;
wire \BUS[1] ;
wire \BUS[0] ;
wire regC_in_enable;
wire \CU/SC_reset_next ;
wire regC_out_enable;
wire regA_in;
wire regA_out;
wire RAM_in;
wire RAM_out;
wire \regC/data[7] ;
wire \regC/data[6] ;
wire \regC/data[5] ;
wire \regC/data[4] ;
wire \regC/data[3] ;
wire \regC/data[2] ;
wire \regC/data[1] ;
wire \regC/data[0] ;
wire \regA/data[7] ;
wire \regA/data[6] ;
wire \regA/data[5] ;
wire \regA/data[4] ;
wire \regA/data[3] ;
wire \regA/data[2] ;
wire \regA/data[1] ;
wire \regA/data[0] ;
wire clk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i({\opcode[7] ,\opcode[6] ,\opcode[5] ,\opcode[4] ,\opcode[3] ,\opcode[2] ,\opcode[1] ,\opcode[0] ,\operand[7] ,\operand[6] ,\operand[5] ,\operand[4] ,\operand[3] ,\operand[2] ,\operand[1] ,\operand[0] }),
    .data_i({\opcode[7] ,\opcode[6] ,\opcode[5] ,\opcode[4] ,\opcode[3] ,\opcode[2] ,\opcode[1] ,\opcode[0] ,\operand[7] ,\operand[6] ,\operand[5] ,\operand[4] ,\operand[3] ,\operand[2] ,\operand[1] ,\operand[0] ,\CU/step[3] ,\CU/step[2] ,\CU/step[1] ,\CU/step[0] ,\BUS[7] ,\BUS[6] ,\BUS[5] ,\BUS[4] ,\BUS[3] ,\BUS[2] ,\BUS[1] ,\BUS[0] ,regC_in_enable,\CU/SC_reset_next ,regC_out_enable,regA_in,regA_out,RAM_in,RAM_out,\regC/data[7] ,\regC/data[6] ,\regC/data[5] ,\regC/data[4] ,\regC/data[3] ,\regC/data[2] ,\regC/data[1] ,\regC/data[0] ,\regA/data[7] ,\regA/data[6] ,\regA/data[5] ,\regA/data[4] ,\regA/data[3] ,\regA/data[2] ,\regA/data[1] ,\regA/data[0] }),
    .clk_i(clk)
);

endmodule

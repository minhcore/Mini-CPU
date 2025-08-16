module top_cpu (input clk, input reset_n, input n_but, input uart_rx, output N_led, output [6:0] led_hundreds, output [6:0] led_tens, output [6:0] led_ones, output led_debug);
	// Control Signals
wire [7:0] opcode;   // opcode direct from CIR
wire [7:0] operand;  // operand direct from AR
wire [3:0] step;
wire       Z, N, C, V, mode;

// Control outputs
wire       PC_out;
wire       PC_inc;
wire       PC_in;
wire       PC_reset;
wire       MAR_in;
wire       MAR_reset;
wire       MDR_in;
wire       MDR_reset;
wire       CIR_in;
wire       CIR_out;
wire       CIR_reset;
wire       SC_reset;
wire       SC_inc;
wire       regA_in;
wire       regA_out;
wire       regA_reset;
wire       regB_in;
wire       regB_out;
wire       regB_reset;
wire       regD_in;
wire       regD_out;
wire       regD_reset;
wire       regE_in;
wire       regE_out;
wire       regE_reset;
wire       regF_in;
wire       regF_out;
wire       regF_reset;
wire       regG_in;
wire       regG_out;
wire       regG_reset;
wire       regH_in;
wire       regH_out;
wire       regH_reset;
wire       regC_in_enable;
wire       regC_out_enable;
wire       regC_rst;
wire       regC_sel;
wire       AR_in;
wire       AR_reset;
wire       AR_out;
wire	   AR_sel;
wire       RAM_in;
wire       RAM_out;
wire       flag_in;
wire       HALT;
wire [7:0] BUS;
wire [7:0] ALU_output;
wire [7:0] flag_input;
wire [7:0] RAM_addr_input;
wire [7:0] ROM_addr_input;
wire [15:0] ROM_output;
wire [15:0] CIR_input;
wire C_ALU, V_ALU;
reg cpu_run;
wire reset;
assign reset = ~reset_n;
wire tmp_dummy_wire = CIR_input[0] || opcode[0] || operand[0] || ROM_output[0];
assign led_debug = tmp_dummy_wire;

always @(posedge clk) begin
	if (reset) begin
		cpu_run <= 1;
	end
	else if (HALT) begin
		cpu_run <= 0;
	end 
end
	
	// INSTANT MODULE 
	// Register A
	register #(.WIDTH(8)) regA (
		.clk(clk),
		.reset(reset),
		.in_enable(regA_in),
		.out_enable(regA_out),
		.inc_enable(1'b0),
		.out_data(), // direct
		.data_out(BUS), // tristate
		.in_data(BUS)
	);
	// Register B
	register #(.WIDTH(8)) regB (
		.clk(clk),
		.reset(reset),
		.in_enable(regB_in),
		.out_enable(regB_out),
		.inc_enable(1'b0),
		.out_data(), // direct
		.data_out(BUS), // tristate
		.in_data(BUS)
	);
	// Register C
	regC regC (
		.clk(clk),
		.reset(reset),
		.in_enable(regC_in_enable),
		.out_enable(regC_out_enable),
		.sel(regC_sel),
		.ALU_in(ALU_output),
		.BUS_in(BUS),
		.data_out(BUS), // tristate
		.out_data(flag_input) // direct
	);
	// Register D
	register #(.WIDTH(8)) regD (
		.clk(clk),
		.reset(reset),
		.in_enable(regD_in),
		.out_enable(regD_out),
		.inc_enable(1'b0),
		.out_data(), // direct
		.data_out(BUS), // tristate
		.in_data(BUS)
	);
	// Register E
	register #(.WIDTH(8)) regE (
		.clk(clk),
		.reset(reset),
		.in_enable(regE_in),
		.out_enable(regE_out),
		.inc_enable(1'b0),
		.out_data(), // direct
		.data_out(BUS), // tristate
		.in_data(BUS)
	);
	// Register F
	register #(.WIDTH(8)) regF (
		.clk(clk),
		.reset(reset),
		.in_enable(regF_in),
		.out_enable(regF_out),
		.inc_enable(1'b0),
		.out_data(), // direct
		.data_out(BUS), // tristate
		.in_data(BUS)
	);
	// Register G
	register #(.WIDTH(8)) regG (
		.clk(clk),
		.reset(reset),
		.in_enable(regG_in),
		.out_enable(regG_out),
		.inc_enable(1'b0),
		.out_data(), // direct
		.data_out(BUS), // tristate
		.in_data(BUS)
	);
	// Register H
	register #(.WIDTH(8)) regH (
		.clk(clk),
		.reset(reset),
		.in_enable(regH_in),
		.out_enable(regH_out),
		.inc_enable(1'b0),
		.out_data(), // direct
		.data_out(BUS), // tristate
		.in_data(BUS)
	);
	// MAR
	MAR MAR (
		.clk(clk),
		.reset(reset),
		.in_enable(MAR_in),
		.in_data(BUS),
		.ROM_data(ROM_addr_input)
	);
	// MDR
	register #(.WIDTH(16)) MDR (
		.clk(clk),
		.reset(reset),
		.in_enable(MDR_in),
		.inc_enable(1'b0),
		.out_enable(1'b1),
		.out_data(CIR_input), // direct
		.data_out(),		  // tristate
		.in_data(ROM_output)
	);
	// CIR 
	CIR CIR (
		.clk(clk),
		.reset(reset),
		.in_enable(CIR_in),
		.out_enable(CIR_out),
		.in_data(CIR_input),
		.opcode(opcode),
		.operand(operand),
		.bus_out(BUS)
	);
	// AR
	register #(.WIDTH(8)) AR (
		.clk(clk),
		.reset(reset),
		.in_enable(AR_in),
		.out_enable(AR_out),
		.inc_enable(1'b0),
		.out_data(RAM_addr_input), // direct
		.data_out(BUS),		  // tristate
		.in_data(BUS)
	);
	// flag_check
	flag_check flag_check (
		.clk(clk),
		.data(flag_input),
		.latch(flag_in),
		.C_ALU(C_ALU),
		.V_ALU(V_ALU),
		.Z(Z),
		.N(N),
		.C(C), 
		.V(V)
	);
	// ALU
	alu ALU (
		.A(BUS),
		.B(flag_input),
		.opcode(opcode),
		.result(ALU_output),
		.C(C_ALU),
		.V(V_ALU)
	);
	// SC
	SC SC (
		.clk(clk),
		.reset(reset),
		.reset_mol(SC_reset),
		.in_enable(1'b0),
		.out_enable(1'b1),
		.inc_enable(SC_inc),
		.out_data(step), // direct
		.data_out(), // tristate
		.in_data(4'b0)
	);
	// PC
	register #(.WIDTH(8)) PC (
	.clk(clk),
	.reset(reset),
	.in_enable(PC_in),
	.out_enable(PC_out),
	.inc_enable(PC_inc),
	.in_data(BUS),
	.data_out(BUS),		// tri-state
	.out_data()
	);
	// CU
	CU CU (
	.clk(clk),
	.cpu_run(cpu_run),
	.opcode(opcode), .operand(operand), .step(step),
	.Z(Z), .N(N), .C(C), .V(V),
	.PC_out(PC_out),
	.PC_inc(PC_inc),
	.PC_in(PC_in),
	.PC_reset(PC_reset),
	.MAR_in(MAR_in),
	.MAR_reset(MAR_reset),
	.MDR_in(MDR_in),
	.MDR_reset(MDR_reset),
	.CIR_in(CIR_in),
	.CIR_out(CIR_out),
	.CIR_reset(CIR_reset),
	.SC_reset(SC_reset),
	.SC_inc(SC_inc),
	.regA_in(regA_in),
	.regA_out(regA_out),
	.regA_reset(regA_reset),
	.regB_in(regB_in),
	.regB_out(regB_out),
	.regB_reset(regB_reset),
	.regD_in(regD_in),
	.regD_out(regD_out),
	.regD_reset(regD_reset),
	.regE_in(regE_in),
	.regE_out(regE_out),
	.regE_reset(regE_reset),
	.regF_in(regF_in),
	.regF_out(regF_out),
	.regF_reset(regF_reset),
	.regG_in(regG_in),
	.regG_out(regG_out),
	.regG_reset(regG_reset),
	.regH_in(regH_in),
	.regH_out(regH_out),
	.regH_reset(regH_reset),
	.regC_in_enable(regC_in_enable),
	.regC_out_enable(regC_out_enable),
	.regC_rst(regC_rst),
	.regC_sel(regC_sel),
	.AR_in(AR_in),
	.AR_reset(AR_reset),
	.AR_out(AR_out),
	.RAM_in(RAM_in),
	.RAM_out(RAM_out),
	.flag_in(flag_in),
	.HALT(HALT)
	);
	// RAM
	ram RAM (
		.clk(clk),
		.we(RAM_in),
		.re(RAM_out),
		.addr(RAM_addr_input),
		.data_in(BUS),
		.data_out(BUS)
	);
	//uart_ram
	uart_ram uart_ram (
		.clk(clk),
		.button(n_but),
		.reset(reset),
		.rx(uart_rx),
		.addrPC(ROM_addr_input),
		.dataOut(ROM_output),
		.mode(mode)
	);
	hex_to_decimal led_segment (
		.in(flag_input),
		.signed_flag(N),
		.mode(mode),
		.led_hundreds(led_hundreds),
		.led_tens(led_tens),
		.led_ones(led_ones),
		.led_signed(N_led)
	);
endmodule
	


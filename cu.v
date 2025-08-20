module CU (
	input wire			clk, cpu_run, reset,
	input wire [7:0]	opcode, // opcode direct from CIR
	input wire [7:0]	operand, // operand direct from AR
	input wire [3:0] 	step,
	input wire 			Z, N, C, V,
	output reg			PC_out,
	output reg			PC_inc,
	output reg			PC_in,
	output reg			PC_reset,
	output reg			MAR_in,
	output reg 			MAR_reset,
	output reg 			MDR_in,
	output reg 			MDR_reset,
	output reg 			CIR_in,
	output reg 			CIR_out,
	output reg 			CIR_reset,
	output reg 			SC_reset,
	output reg			SC_inc,
	output reg 			regA_in,
	output reg 			regA_out,
	output reg 			regA_reset,
	output reg 			regB_in,
	output reg 			regB_out,
	output reg 			regB_reset,
	output reg 			regD_in,
	output reg 			regD_out,
	output reg 			regD_reset,
	output reg 			regE_in,
	output reg 			regE_out,
	output reg 			regE_reset,
	output reg 			regF_in,
	output reg 			regF_out,
	output reg 			regF_reset,
	output reg 			regG_in,
	output reg 			regG_out,
	output reg 			regG_reset,
	output reg 			regH_in,
	output reg 			regH_out,
	output reg 			regH_reset,
	output reg 			regC_in_enable,
	output reg 			regC_out_enable,
	output reg 			regC_rst,
	output reg			regC_sel,
	output reg 			AR_in,
	output reg 			AR_reset,
	output reg 			AR_out,
	output reg			RAM_in,
	output reg			RAM_out,
	output reg			flag_in,
	output reg			HALT
);
reg SC_reset_next;

	// Task : Operand Processing (mode, reg dest, reg src)
	task handle_operand(
		input [7:0] operand,
		input		dest_en,
		input		src_en
	);
	reg [1:0] mode;
	reg [2:0] dest;
	reg [2:0] src;
	begin
		mode = operand [7:6];
		dest = operand [5:3];
		src  = operand [2:0];
		
		// Mode Processing
		case (mode)
			2'b01: begin // Register Direct Mode
				if (src_en) begin
					case (src) 
						3'b000: regA_out = 1;
						3'b001: regB_out = 1;
						3'b010: regC_out_enable = 1;
						3'b011: regD_out = 1;
						3'b100: regE_out = 1;
						3'b101: regF_out = 1;
						3'b110: regH_out = 1;
						3'b111: regG_out = 1;
						default: ;
					endcase
				end
				if (dest_en) begin
					case (dest)
						3'b000: regA_in = 1;
						3'b001: regB_in = 1;
						3'b010: regC_in_enable = 1;
						3'b011: regD_in = 1;
						3'b100: regE_in = 1;
						3'b101: regF_in = 1;
						3'b110: regH_in = 1;
						3'b111: regG_in = 1;
						default: ;
					endcase
				end
			end
			default: ; // Reserved
		endcase
	end
	endtask
	
	// Main Control Logic
	always @(posedge clk) begin
		if (reset) begin
			SC_reset <= 1;
			SC_inc <= 0;
		end
		else begin
			SC_reset <= SC_reset_next;
			if (cpu_run) begin
				if (SC_reset) begin
					SC_inc <= 0;
				end
				else begin
					SC_inc <= 1;
				end
			end
			else begin
				SC_inc <= 0;
			end
		end
	end
	always @(*) begin
		// Reset all control signals every cycle
		{PC_out,PC_inc,PC_in,PC_reset,MAR_in,MAR_reset,MDR_in,MDR_reset,CIR_in,CIR_out,CIR_reset,
		SC_reset_next,regA_in,regA_out,regA_reset,regB_in,regB_out,regB_reset,regD_in,regD_out,regD_reset,
		regE_in,regE_out,regE_reset,regF_in,regF_out,regF_reset,regG_in,regG_out,regG_reset,regH_in,regH_out,regH_reset,regC_in_enable,regC_out_enable,
		regC_rst,regC_sel,AR_in,AR_reset,AR_out,RAM_in,RAM_out,flag_in,HALT} = 0;
		
		if (step < 4'd5 ) begin
			// FETCH ( 4 step )
				case (step)
					4'b0000: begin PC_out = 1; MAR_in = 1; end
					4'b0001: begin MDR_in = 1; end // ROM_out = 1'b1
					4'b0010: begin CIR_in = 1; end // MDR_out = 1'b1
					4'b0011: begin PC_inc = 1; end
					4'b0100: begin CIR_out = 1; AR_in = 1; end
				endcase
		end else begin
			// EXCUTE (step >= 5)
			case (opcode)
				8'h00 : begin // ADD
					if (step == 4'd5) begin
						handle_operand(operand, 1, 1);
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h01 : begin // SUB
					if (step == 4'd5) begin
						handle_operand(operand, 1, 1);
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h02 : begin // AND 
					if (step == 4'd5) begin
						handle_operand(operand, 1, 1);
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h03 : begin // OR
					if (step == 4'd5) begin
						handle_operand(operand, 1, 1);
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h04 : begin // XOR 
					if (step == 4'd5) begin
						handle_operand(operand, 1, 1);
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h05 : begin // SLT
					if (step == 4'd5) begin
						handle_operand(operand, 1, 1);
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h06 : begin // INC
					if (step == 4'd5) begin
						regC_in_enable = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h07 : begin // DEC
					if (step == 4'd5) begin
						regC_in_enable = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h08 : begin // LSL
					if (step == 4'd5) begin
						regC_in_enable = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h09 : begin // LSR
					if (step == 4'd5) begin
						regC_in_enable = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h0A : begin // ASR
					if (step == 4'd5) begin
						regC_in_enable = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h0B : begin // ROL
					if (step == 4'd5) begin
						regC_in_enable = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h0C : begin // ROR
					if (step == 4'd5) begin
						regC_in_enable = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h0D : begin // NOP
					if (step == 4'd5) begin
					end
					if (step == 4'd6) begin
						SC_reset_next = 1;
					end
				end
				8'h0E : begin // HLT
					if (step == 4'd5) begin
						HALT = 1;
					end
				end
				8'h0F : begin // LOAD addr
					if (step == 4'd5) begin
						RAM_out = 1;
						
					end
					if (step == 4'd6) begin
						RAM_out = 1;
						regC_in_enable = 1;
						regC_sel = 1;
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
						flag_in = 1;
					end
					if (step == 4'd8) begin
						SC_reset_next = 1;
					end
				end
				8'h10 : begin // STORE addr
					if (step == 4'd5) begin
						regC_out_enable = 1;
						RAM_in = 1;
					end
					if (step == 4'd6) begin
						SC_reset_next = 1;
					end
				end
				8'h11 : begin // MOV Rs, C
					if (step == 4'd5) begin
						handle_operand(operand, 1, 1);
					end
					if (step == 4'd6) begin
						SC_reset_next = 1;
					end
				end
				8'h12 : begin // MOV C, Rs
					if (step == 4'd5) begin
						handle_operand(operand, 1, 1);
						regC_sel = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h13 : begin // MOV C, #Immediate
					if (step == 4'd5) begin
						AR_out = 1;
						regC_sel = 1;
						regC_in_enable = 1;
					end
					if (step == 4'd6) begin
						flag_in = 1;
					end
					if (step == 4'd7) begin
						SC_reset_next = 1;
					end
				end
				8'h14 : begin // JMP addr
					if (step == 4'd5) begin 
						AR_out = 1;
						PC_in = 1;
					end
					if (step == 4'd6) begin
						SC_reset_next = 1;
					end
				end
				8'h15 : begin // JZ addr
					if (Z == 1) begin
						if (step == 4'd5) begin 
							AR_out = 1;
							PC_in = 1;
						end
						if (step == 4'd6) begin
							SC_reset_next = 1;
						end
					end else begin 
							SC_reset_next = 1;
						end
				end
				8'h16 : begin // JNZ addr
					if (Z == 0) begin
						if (step == 4'd5) begin 
							AR_out = 1;
							PC_in = 1;
						end
						if (step == 4'd6) begin
							SC_reset_next = 1;
						end
					end else begin 
							SC_reset_next = 1;
						end
				end
				8'h17 : begin // JC addr
					if (C == 1) begin
						if (step == 4'd5) begin 
							AR_out = 1;
							PC_in = 1;
						end
						if (step == 4'd6) begin
							SC_reset_next = 1;
						end
					end else begin 
							SC_reset_next = 1;
						end
				end
				8'h18 : begin // JNC addr
					if (C == 0) begin
						if (step == 4'd5) begin 
							AR_out = 1;
							PC_in = 1;
						end
						if (step == 4'd6) begin
							SC_reset_next = 1;
						end
					end else begin 
							SC_reset_next = 1;
						end
				end
				8'h19 : begin // JP addr
					if (N == 0) begin
						if (step == 4'd5) begin 
							AR_out = 1;
							PC_in = 1;
						end
						if (step == 4'd6) begin
							SC_reset_next = 1;
						end
					end else begin 
							SC_reset_next = 1;
						end
				end
				8'h1A : begin // JN addr
					if (N == 1) begin
						if (step == 4'd5) begin 
							AR_out = 1;
							PC_in = 1;
						end
						if (step == 4'd6) begin
							SC_reset_next = 1;
						end
					end else begin 
							SC_reset_next = 1;
						end
				end
				8'h1B : begin // JO addr
					if (V == 1) begin
						if (step == 4'd5) begin 
							AR_out = 1;
							PC_in = 1;
						end
						if (step == 4'd6) begin
							SC_reset_next = 1;
						end
					end else begin 
							SC_reset_next = 1;
						end
				end
				8'h1C : begin // JZ addr
					if (V == 0) begin
						if (step == 4'd5) begin 
							AR_out = 1;
							PC_in = 1;
						end
						if (step == 4'd6) begin
							SC_reset_next = 1;
						end
					end else begin 
							SC_reset_next = 1;
						end
				end
				default :SC_reset_next = 1;
			endcase
		end
	end 
endmodule

						
				
				
				
				

	
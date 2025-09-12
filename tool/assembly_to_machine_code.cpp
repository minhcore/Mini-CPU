#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define name_length 32
#define table_size 256
#define line_length 128
typedef struct {
	char name[name_length];
	uint8_t addr;
} label ;

label table[table_size];
	int label_count = 0;

typedef struct {
	char mnemonic[8];
	uint8_t opcode;
	uint8_t	has_operand; // 0: none, 1: imm, 2: reg
} Instruction;

Instruction ins_table[] = {
	{"ADD",	0x00, 2},
	{"SUB",	0x01, 2},
	{"AND",	0x02, 2},
	{"OR",	0x03, 2},
	{"XOR",	0x04, 2},
	{"SLT",	0x05, 2},
	{"INC",	0x06, 0},
	{"DEC",	0x07, 0},
	{"LSL",	0x08, 0},
	{"LSR",	0x09, 0},
	{"ASR",	0x0A, 0},
	{"ROL",	0x0B, 0},
	{"ROR",	0x0C, 0},
	{"NOP",	0x0D, 0},
	{"HLT",	0x0E, 0},
	{"LOAD",0x0F, 1},
	{"STR",	0X10, 1},
	{"MOV_Rs",0x11,2},
	{"MOV_C",0x12, 2},
	{"MOV",	0x13, 1},
	{"JMP",	0x14, 1},
	{"JZ",	0x15, 1},
	{"JNZ",	0x16, 1},
	{"JC",	0x17, 1},
	{"JNC",	0x18, 1},
	{"JP",	0x19, 1},
	{"JN",	0x1A, 1},
	{"JO",	0x1B, 1},
	{"JNO",	0x1C, 1},
	{"STR_Rs", 0x1D, 2},
	{"LOAD_Rs", 0x1E, 2}
	 	
};
const int ins_count = sizeof(ins_table)/sizeof(ins_table[0]);


void add_label (const char* label_name, uint8_t address) {
		strncpy(table[label_count].name, label_name, name_length - 1);
		table[label_count].name[name_length - 1] = '\0';
		table[label_count].addr = address;
		label_count++;
}


int find_label(const char* label_name) {
	for (int i = 0; i < label_count; i++) {
		if (strcmp(table[i].name, label_name) == 0) {
			return table[i].addr;
		}
	}
	return -1;
}


int find_opcode(const char* mnemonic) {
	for (int i = 0; i < ins_count; i++) {
		if (strcmp(ins_table[i].mnemonic, mnemonic) == 0) {
			return ins_table[i].opcode;
		}
	}
	return -1;
}

const char* reg_names[] = {"A", "B", "C", "D", "E", "F", "G", "H"};
int reg_code(const char*reg) {
	for (int i = 0; i < 8; i++) {
		if(strcmp(reg, reg_names[i]) == 0) return i;
	}
	return -1;
}
int main () {
	
	FILE *f;
	f=fopen("assembly.txt", "r");
	if (f!= NULL) {
		char line[line_length];
		uint8_t pc = 0;
		
	while (fgets(line, line_length, f)) {
    	line[strcspn(line, "\n")] = '\0';
		char* p = line;
    	while (*p == ' ' || *p == '\t') p++;
    	memmove(line, p, strlen(p) + 1);
    	if (strlen(line) == 0) continue;

   
    	char *colon = strchr(line, ':');
            if (colon) {
                *colon = '\0';
                add_label(line, pc);
                p = colon + 1;
                while (*p == ' ' || *p == '\t') p++;
                if (*p == '\0') continue;
                memmove(line, p, strlen(p) + 1);
            }

    
    char mnemonic[16], op1[16], op2[16];
    op1[0] = op2[0] = '\0';
    sscanf(line, "%s %[^,], %s", mnemonic, op1, op2);
    int opcode = find_opcode(mnemonic);
    if (find_opcode(mnemonic) >= 0) {
                pc++;  // only +1 per instruction
            }
        }



    

		fclose(f);
}
		f = fopen("assembly.txt", "r");
		if (f != NULL) {
			FILE *out = fopen("program.hex", "w");
			char line[line_length];
			uint8_t pc = 0;
			
			while (fgets(line, line_length, f)) {
				line[strcspn(line, "\n")] = '\0';
				char *p = line;
				while (*p == ' ' || *p == '\t') p++;
				memmove(line, p, strlen(p) + 1);
			 	if (strlen(line) == 0) continue;
			 	
			 	char *colon = strchr(line, ':');
            	if (colon) {
                p = colon + 1;
                while (*p == ' ' || *p == '\t') p++;
                if (*p == '\0') continue;
                memmove(line, p, strlen(p) + 1);
            }
				
				char mnemonic[16], op1[16], op2[16];
            op1[0] = op2[0] = '\0';
            int num = sscanf(line, "%s %s %s", mnemonic, op1, op2);
            if (op1[strlen(op1) - 1] == ',') op1[strlen(op1) - 1] = '\0';
            int opcode = find_opcode(mnemonic);
            if (opcode < 0) continue;

            uint8_t operand = 0x00;
            int dst = -1, src = -1;

            for (int i = 0; i < ins_count; i++) {
                if (strcmp(ins_table[i].mnemonic, mnemonic) == 0) {
                    if (ins_table[i].has_operand == 0) {
                        operand = 0x00;
                    } else if (ins_table[i].has_operand == 1) {
                        if (strcmp(mnemonic, "LOAD") == 0 || strcmp(mnemonic, "STR") == 0) {
							if (strcmp(op1, "UART_TX") == 0) {
            					operand = 0xFE;
        					} else if (strcmp(op1, "UART_RX") == 0) {
            					operand = 0xFF;
							} else if (isdigit(op1[0])) {
								operand = (uint8_t)strtol(op1, NULL, 10);  
							} else {
								int addr = find_label(op1);
								operand = (addr >= 0) ? addr : 0x00;
							}
					} else {					
						if (op1[0] == '#') {
                            operand = (uint8_t)strtol(op1 + 1, NULL, 10);
                        } else if (op2[0] == '#') {
                            operand = (uint8_t)strtol(op2 + 1, NULL, 10);
                        } else {
                            int addr = find_label(op1);
                            operand = (addr >= 0) ? addr : 0x00;
                        }
                    } 
                 }
					else if (ins_table[i].has_operand == 2) {
                        if (strcmp(mnemonic, "MOV_Rs") == 0) {
                            dst = reg_code(op1);
                            src = reg_code(op2);
                        } else if (
                            strcmp(mnemonic, "ADD") == 0 || strcmp(mnemonic, "SUB") == 0 ||
                            strcmp(mnemonic, "AND") == 0 || strcmp(mnemonic, "OR") == 0 ||
                            strcmp(mnemonic, "XOR") == 0 || strcmp(mnemonic, "SLT") == 0) {
                            dst = reg_code("C");
                            src = reg_code(op1);
                        } else {
                            dst = reg_code(op1);
                            src = reg_code(op2);
                        }

                        if (src >= 0 && dst >= 0) {
                        	if (strcmp(mnemonic, "STR_Rs") == 0 || strcmp(mnemonic, "LOAD_Rs") == 0) {
                        		operand = (0 << 6) | (dst << 3) | src;
							} else {
                            	operand = (1 << 6) | (dst << 3) | src;
                        	}
                        } else {
                            operand = 0x00;
                        }
                    }
                    break;
                }
            }

            fprintf(out, "%02X%02X\n", opcode, operand);
            pc++;
        }

        fclose(f);
        fclose(out);
        printf("Completed!\n");
    } else {
        printf("Error opening file.\n");
    }

    return 0;
}

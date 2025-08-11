#include <stdio.h>
#include <stdint.h>

int main () {
	FILE* fin = fopen("program.hex", "r");
	if (!fin) {
		printf("Program.hex >>> ERROR");
		return 1;
	}
	FILE* fout = fopen("rom.v", "w");
	if (!fout) {
		printf("rom.v >>> ERROR");
		fclose(fin);
		return 1;
	}
	uint16_t data;
	uint8_t i = 0;
	fprintf(fout, "module rom #(\n");
	fprintf(fout, "parameter WIDTH = 16,\nparameter DEPTH = 256\n)(\n");
	fprintf(fout, "input [$clog2(DEPTH)-1:0] addr,\n");
	fprintf(fout, "output reg [WIDTH-1:0] data\n);\n");
	fprintf(fout, "always @(*) begin\n");
	fprintf(fout, "case(addr)\n");
	while (fscanf(fin, "%4hX", &data) == 1) {
		fprintf(fout, "8'h%02X: data = 16'h%04X;\n", i, data);
		i++;
	}
	fprintf(fout, "default: data = 16'h0000;\n");
	fprintf(fout, "endcase\n");
	fprintf(fout, "end\n");
	fprintf(fout, "endmodule\n");
	fclose(fin);
	fclose(fout);
	printf(">>> Completed creating rom.v from program.hex with %u line of codes\n", i);
}

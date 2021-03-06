module testbench (
	input clk, reset
);
	`RVFI_WIRES

`ifdef YOSYS
	assume property (reset == $initstate);
`endif

	rvfi_wrapper uut (
		.clock (clk  ),
		.reset (reset),
		`RVFI_CONN
	);

`define RVFI_CHANNEL_POSTFIX _ch0
`RVFI_CHANNEL(0)

`define RVFI_CHANNEL_POSTFIX _ch1
`RVFI_CHANNEL(1)

	localparam [31:0] opcode0 = 32'h00051663; // bnez a0,18 <foo+0xc>
	localparam [31:0] opcode1 = 32'h00310093; // addi ra,sp,3
	localparam [31:0] opcode2 = 32'h005201b3; // add  gp,tp,t0
	localparam [31:0] opcode3 = 32'h0003a303; // lw   t1,0(t2)
	localparam [31:0] opcode4 = 32'h0084a023; // sw   s0,0(s1)

	reg p0o0 = 0, p1o0 = 0;
	reg p0o1 = 0, p1o1 = 0;
	reg p0o2 = 0, p1o2 = 0;
	reg p0o3m0 = 0, p0o3m1 = 0, p1o3m0 = 0, p1o3m1 = 0;
	reg p0o4m0 = 0, p0o4m1 = 0, p1o4m0 = 0, p1o4m1 = 0;

	wire [3:0] icount_p0 = p0o0 + p1o0 + p0o1;
	wire [3:0] icount_p1 = p1o1 + p0o2 + p1o2;
	wire [3:0] mcount_p0 = p0o3m0 + p0o3m1 + p0o4m0 + p0o4m1;
	wire [3:0] mcount_p1 = p1o3m0 + p1o3m1 + p1o4m0 + p1o4m1;
	wire [3:0] tcount = |icount_p0 + |icount_p1 + |mcount_p0 + |mcount_p1;

	wire o0 = p0o0 || p1o0;
	wire o1 = p0o1 || p1o1;
	wire o2 = p0o2 || p1o2;
	wire o3 = p0o3m0 || p0o3m1 || p1o3m0 || p1o3m1;
	wire o4 = p0o4m0 || p0o4m1 || p1o4m0 || p1o4m1;

	wire is_p0_ch0 = (rvfi_pc_rdata_ch0 & 32'hffff0000) == 32'h00010000;
	wire is_p1_ch0 = (rvfi_pc_rdata_ch0 & 32'hffff0000) == 32'h00020000;

	wire is_m0_ch0 = (rvfi_mem_addr_ch0 & 32'hffff0000) == 32'h00010000;
	wire is_m1_ch0 = (rvfi_mem_addr_ch0 & 32'hffff0000) == 32'h00020000;

	wire is_p0_ch1 = (rvfi_pc_rdata_ch1 & 32'hffff0000) == 32'h00010000;
	wire is_p1_ch1 = (rvfi_pc_rdata_ch1 & 32'hffff0000) == 32'h00020000;

	wire is_m0_ch1 = (rvfi_mem_addr_ch1 & 32'hffff0000) == 32'h00010000;
	wire is_m1_ch1 = (rvfi_mem_addr_ch1 & 32'hffff0000) == 32'h00020000;

	always @(posedge clk) begin
		if (!reset) begin
			if (rvfi_valid_ch0) begin
				if (rvfi_insn_ch0 == opcode0) begin
					if (is_p0_ch0) p0o0 <= 1;
					if (is_p1_ch0) p1o0 <= 1;
				end
				if (rvfi_insn_ch0 == opcode1) begin
					if (is_p0_ch0) p0o1 <= 1;
					if (is_p1_ch0) p1o1 <= 1;
				end
				if (rvfi_insn_ch0 == opcode2) begin
					if (is_p0_ch0) p0o2 <= 1;
					if (is_p1_ch0) p1o2 <= 1;
				end
				if (rvfi_insn_ch0 == opcode3) begin
					if (is_p0_ch0 && is_m0_ch0) p0o3m0 <= 1;
					if (is_p0_ch0 && is_m1_ch0) p0o3m1 <= 1;
					if (is_p1_ch0 && is_m0_ch0) p1o3m0 <= 1;
					if (is_p1_ch0 && is_m1_ch0) p1o3m1 <= 1;
				end
				if (rvfi_insn_ch0 == opcode4) begin
					if (is_p0_ch0 && is_m0_ch0) p0o4m0 <= 1;
					if (is_p0_ch0 && is_m1_ch0) p0o4m1 <= 1;
					if (is_p1_ch0 && is_m0_ch0) p1o4m0 <= 1;
					if (is_p1_ch0 && is_m1_ch0) p1o4m1 <= 1;
				end
			end
			if (rvfi_valid_ch1) begin
				if (rvfi_insn_ch1 == opcode0) begin
					if (is_p0_ch1) p0o0 <= 1;
					if (is_p1_ch1) p1o0 <= 1;
				end
				if (rvfi_insn_ch1 == opcode1) begin
					if (is_p0_ch1) p0o1 <= 1;
					if (is_p1_ch1) p1o1 <= 1;
				end
				if (rvfi_insn_ch1 == opcode2) begin
					if (is_p0_ch1) p0o2 <= 1;
					if (is_p1_ch1) p1o2 <= 1;
				end
				if (rvfi_insn_ch1 == opcode3) begin
					if (is_p0_ch1 && is_m0_ch1) p0o3m0 <= 1;
					if (is_p0_ch1 && is_m1_ch1) p0o3m1 <= 1;
					if (is_p1_ch1 && is_m0_ch1) p1o3m0 <= 1;
					if (is_p1_ch1 && is_m1_ch1) p1o3m1 <= 1;
				end
				if (rvfi_insn_ch1 == opcode4) begin
					if (is_p0_ch1 && is_m0_ch1) p0o4m0 <= 1;
					if (is_p0_ch1 && is_m1_ch1) p0o4m1 <= 1;
					if (is_p1_ch1 && is_m0_ch1) p1o4m0 <= 1;
					if (is_p1_ch1 && is_m1_ch1) p1o4m1 <= 1;
				end
			end
		end
	end

	always @* begin
		cover (icount_p0 == 1);
		cover (icount_p0 == 2);
		cover (icount_p0 == 3);

		cover (icount_p1 == 1);
		cover (icount_p1 == 2);
		cover (icount_p1 == 3);

		cover (mcount_p0 == 1);
		cover (mcount_p0 == 2);
		cover (mcount_p0 == 3);
		cover (mcount_p0 == 4);

		cover (mcount_p1 == 1);
		cover (mcount_p1 == 2);
		cover (mcount_p1 == 3);
		cover (mcount_p1 == 4);

		cover (tcount == 2);
		cover (tcount == 3);
		cover (tcount == 4);
	end
endmodule

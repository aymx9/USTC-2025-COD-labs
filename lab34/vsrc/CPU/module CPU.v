`include "./include/config.v"
`define PC_INIT             32'H1c000000
`define HALT_INST           32'H80000000

module CPU (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            global_en,

/* ------------------------------ Memory (inst) ----------------------------- */
    output                  [31 : 0]            imem_raddr,
    input                   [31 : 0]            imem_rdata,

/* ------------------------------ Memory (data) ----------------------------- */
    input                   [31 : 0]            dmem_rdata,
    output                  [ 0 : 0]            dmem_we,
    output                  [31 : 0]            dmem_addr,
    output                  [31 : 0]            dmem_wdata,

/* ---------------------------------- Debug --------------------------------- */
    output                  [ 0 : 0]            commit,
    output                  [31 : 0]            commit_pc,
    output                  [31 : 0]            commit_instr,
    output                  [ 0 : 0]            commit_halt,
    output                  [ 0 : 0]            commit_reg_we,
    output                  [ 4 : 0]            commit_reg_wa,
    output                  [31 : 0]            commit_reg_wd,
    output                  [ 0 : 0]            commit_dmem_we,
    output                  [31 : 0]            commit_dmem_wa,
    output                  [31 : 0]            commit_dmem_wd,

    input                   [ 4 : 0]            debug_reg_ra,  
    output                  [31 : 0]            debug_reg_rd    
);



wire [31:0] cur_npc;
wire [31:0] cur_pc, cur_inst, cur_imm;
//assign cur_npc = cur_pc + 4;变成多选了



wire [4:0] cur_rf_ra0, cur_rf_ra1, cur_rf_wa, cur_debug_reg_ra;
wire cur_rf_we;
wire [31:0] cur_rf_wd, cur_debug_reg_rd, cur_rf_rd0, cur_rf_rd1;
wire [0:0]cur_alu_src0_sel, cur_alu_src1_sel;
wire [4:0] cur_alu_op;
wire [31:0] cur_alu_src0,cur_alu_src1;
wire [3:0] cur_dmem_access;
wire [3:0] cur_br_type;
wire cur_npc_sel;
wire [31:0] cur_rd_out;
wire [1:0] cur_rd_wd_sel;
wire [31:0] cur_alu_res;


assign cur_inst = imem_rdata;
assign debug_reg_rd = cur_debug_reg_rd;
assign cur_debug_reg_ra = debug_reg_ra;
assign imem_raddr = cur_pc;//output


PC my_pc (
    .clk    (clk        ),
    .rst    (rst        ),
    .en     (global_en  ),    // 当 global_en 为高电平时，PC 才会更新，CPU 才会执行指令。
    .npc    (cur_npc    ),
    .pc     (cur_pc     )   // 当前指令的地址
);

DECODER my_decoder (
    .inst   (cur_inst   ),
    .alu_op (cur_alu_op ),
    .imm    (cur_imm),
    .rf_ra0 (cur_rf_ra0),
    .rf_ra1 (cur_rf_ra1),
    .rf_wa  (cur_rf_wa),
    .rf_we  (cur_rf_we),
    .alu_src0_sel (cur_alu_src0_sel),
    .alu_src1_sel (cur_alu_src1_sel),
    .rd_wd_sel (cur_rd_wd_sel),
    .dmem_access (cur_dmem_access),
    .br_type (cur_br_type),
    .dmem_we(dmem_we)
);

REG_FILE my_regfile(
    .clk    (clk        ),
    .rf_ra0    (cur_rf_ra0 ),
    .rf_ra1    (cur_rf_ra1 ),
    .dbg_reg_ra (cur_debug_reg_ra),
    .rf_wa     (cur_rf_wa  ),
    .rf_we     (cur_rf_we  ),
    .rf_wd     (cur_rf_wd  ),
    .rf_rd0    (cur_rf_rd0 ),
    .rf_rd1    (cur_rf_rd1 ),
    .dbg_reg_rd (cur_debug_reg_rd)
);

MUX  #(
    .WIDTH  (32)
)mux1(
    .src0   (cur_pc),
    .src1   (cur_rf_rd0),
    .sel    (cur_alu_src0_sel),
    .res    (cur_alu_src0)
);

MUX  #(
    .WIDTH  (32)
)mux2(
    .src0   (cur_rf_rd1),
    .src1   (cur_imm),
    .sel    (cur_alu_src1_sel),
    .res    (cur_alu_src1)
);

ALU my_alu (
    .alu_src0   (cur_alu_src0),
    .alu_src1   (cur_alu_src1),
    .alu_op     (cur_alu_op),
    .alu_res    (cur_alu_res)  // ALU 的输出结果  = 寄存器的写入数据,省略一个寄存器
);

BRANCH my_branch (
    .br_type    (cur_br_type   ),
    .br_src0    (cur_rf_rd0 ),
    .br_src1    (cur_rf_rd1),
    .npc_sel    (cur_npc_sel   )
);

NPC_MUX my_npc_mux (
    .pc_offset  (cur_alu_res   ),
    .npc_sel    (cur_npc_sel   ),
    .npc        (cur_npc   ),
    .pc_add4    (cur_pc + 4)
);

SLU my_slu (
    .addr       (cur_alu_res),
    .dmem_access(cur_dmem_access),
    .rd_in       (dmem_rdata),
    .wd_in       (cur_rf_rd1),
    .rd_out      (cur_rd_out),
    .wd_out      (dmem_wdata)
);

MUX2 #(
    .WIDTH  (32)
) my_mux2(
    .src0      (cur_pc + 4),
    .src1      (cur_alu_res),
    .src2      (cur_rd_out),
    .src3      (32'h0),
    .sel       (cur_rd_wd_sel),
    .res       (cur_rf_wd)
);
assign dmem_addr = (cur_dmem_access == 4'b1000)? 0 :cur_alu_res;//判断是否存入寄存器中







    // Commit
    reg  [ 0 : 0]   commit_reg          ;
    reg  [31 : 0]   commit_pc_reg       ;
    reg  [31 : 0]   commit_instr_reg     ;
    reg  [ 0 : 0]   commit_halt_reg     ;
    reg  [ 0 : 0]   commit_reg_we_reg   ;
    reg  [ 4 : 0]   commit_reg_wa_reg   ;
    reg  [31 : 0]   commit_reg_wd_reg   ;
    reg  [ 0 : 0]   commit_dmem_we_reg  ;
    reg  [31 : 0]   commit_dmem_wa_reg  ;
    reg  [31 : 0]   commit_dmem_wd_reg  ;

    // Commit
    always @(posedge clk) begin
        if (rst) begin
            commit_reg          <= 1'B0;
            commit_pc_reg       <= 32'H0;
            commit_instr_reg     <= 32'H0;
            commit_halt_reg     <= 1'B0;
            commit_reg_we_reg   <= 1'B0;
            commit_reg_wa_reg   <= 5'H0;
            commit_reg_wd_reg   <= 32'H0;
            commit_dmem_we_reg  <= 1'B0;
            commit_dmem_wa_reg  <= 32'H0;
            commit_dmem_wd_reg  <= 32'H0;
        end
        else if (global_en) begin
            commit_reg          <= 1'B1;
            commit_pc_reg       <= cur_pc;   // TODO
            commit_instr_reg     <= cur_inst;   // TODO
            commit_halt_reg     <= (cur_inst ==  32'H80000000);   // TODO
            commit_reg_we_reg   <= cur_rf_we;   // TODO
            commit_reg_wa_reg   <= cur_rf_wa;   // TODO
            commit_reg_wd_reg   <= cur_rf_wd;   // TODO
            commit_dmem_we_reg  <= dmem_we;   // TODO
            commit_dmem_wa_reg  <= dmem_addr;   // TODO
            commit_dmem_wd_reg  <= dmem_wdata;   // TODO
        end
    end

    assign commit           = commit_reg;
    assign commit_pc        = commit_pc_reg;
    assign commit_instr     = commit_instr_reg;
    assign commit_halt      = commit_halt_reg;
    assign commit_reg_we    = commit_reg_we_reg;
    assign commit_reg_wa    = commit_reg_wa_reg;
    assign commit_reg_wd    = commit_reg_wd_reg;
    assign commit_dmem_we   = commit_dmem_we_reg;
    assign commit_dmem_wa   = commit_dmem_wa_reg;
    assign commit_dmem_wd   = commit_dmem_wd_reg;

endmodule
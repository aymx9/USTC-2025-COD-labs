`include "./include/config.v"

module CPU (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            global_en,

/* ------------------------------ Memory (inst) ----------------------------- */
    output                  [31 : 0]            imem_raddr,
    input                   [31 : 0]            imem_rdata,

/* ------------------------------ Memory (data) ----------------------------- */
    input                   [31 : 0]            dmem_rdata, // Unused
    output                  [ 0 : 0]            dmem_we,    // Unused
    output                  [31 : 0]            dmem_addr,  // Unused
    output                  [31 : 0]            dmem_wdata, // Unused

/* ---------------------------------- Debug --------------------------------- */
    output                  [ 0 : 0]            commit,
    output                  [31 : 0]            commit_pc,
    output                  [31 : 0]            commit_inst,
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

// TODO
wire [31: 0] pc_if, pcadd4_if, inst_if;
wire [31: 0] pc_id, pcadd4_id, inst_id, rfrd0_id, rfrd1_id, imm_id;
wire [ 4: 0] rfwa_id, rfra0_id, rfra1_id, aluop_id;
wire [ 3: 0] dmemaccess_id, brtype_id;
wire [ 1: 0] rfwdsel_id;
wire         rfwe_id, alusrc0sel_id, alusrc1sel_id, commit_id;

wire [31: 0] pc_ex, inst_ex, npc_ex, pcadd4_ex, rfrd0_ex, rfrd1_ex, imm_ex, alusrc0_ex, alusrc1_ex, alures_ex,rfrd0raw_ex,rfrd1raw_ex;
wire [ 4: 0] rfwa_ex, aluop_ex, rfra0_ex, rfra1_ex;
wire [ 3: 0] dmemaccess_ex, brtype_ex;
wire [ 1: 0] rfwdsel_ex, npcsel_ex;
wire         rfwe_ex, alusrc0sel_ex, alusrc1sel_ex, commit_ex;

wire [31: 0] pc_mem, inst_mem, pcadd4_mem, alures_mem, rfrd1_mem, dmem_rd_out_mem;
wire [ 4: 0] rfwa_mem;
wire [ 3: 0] dmemaccess_mem;
wire [ 1: 0] rfwdsel_mem; 
wire         rfwe_mem, commit_mem;

wire [31: 0] pc_wb, inst_wb, pcadd4_wb, alures_wb, dmem_rd_out_wb, rfwd_wb, dmem_addr_wb, dmem_wdata_wb;
wire [ 4: 0] rfwa_wb;
wire [ 1: 0] rfwdsel_wb;
wire         rfwe_wb, commit_wb, dmem_we_wb;

wire [31: 0] rfrd0_fd, rfrd1_fd;
wire         rfrd0_fe, rfrd0_fe;

wire stall_ifid, stall_idex, stall_exmem, stall_memwb, stall_pc;
wire flush_ifid, flush_idex, flush_exmem, flush_memwb;

assign pcadd4_if = pc_if + 4;
assign imem_raddr = pc_if;
assign inst_if = imem_rdata;
assign dmem_addr = alures_mem;
assign dmem_we = dmemaccess_mem[2];
//assign stall_ifid = 0;
assign stall_idex = 0;
assign stall_exmem = 0;
assign stall_memwb = 0;
//assign flush_ifid = (npcsel_ex == 2'b11);
//assign flush_idex = (npcsel_ex == 2'b11);
assign flush_exmem = 0;
assign flush_memwb = 0;

//id
PC Pc(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .npc(npc_ex),
    .stall_pc(stall_pc),
    .pc(pc_if)
);

REG_FILE reg_file(
    .clk(clk),
    .rf_ra0(rfra0_id),
    .rf_ra1(rfra1_id),
    .rf_wa(rfwa_wb),
    .rf_we(rfwe_wb),
    .rf_wd(rfwd_wb),
    .rf_rd0(rfrd0_id),
    .rf_rd1(rfrd1_id),
    .dbg_reg_ra(debug_reg_ra),
    .dbg_reg_rd(debug_reg_rd)
);

DECODE decode(
    .inst(inst_id),
    .alu_op(aluop_id),
    .imm(imm_id),
    .dmem_access(dmemaccess_id),
    .rf_ra0(rfra0_id),
    .rf_ra1(rfra1_id),
    .rf_wa(rfwa_id),
    .rf_we(rfwe_id),
    .rf_wd_sel(rfwdsel_id),
    .alu_src0_sel(alusrc0sel_id),
    .alu_src1_sel(alusrc1sel_id),
    .br_type(brtype_id)
);

//ex
MUX #(32) alu0(
    .src0(pc_ex),
    .src1(rfrd0_ex),
    .sel(alusrc0sel_ex),
    .res(alusrc0_ex)
);

MUX #(32) alu1(
    .src0(imm_ex),
    .src1(rfrd1_ex),
    .sel(alusrc1sel_ex),
    .res(alusrc1_ex)
);

ALU alu(
    .alu_src0(alusrc0_ex),
    .alu_src1(alusrc1_ex),
    .alu_op(aluop_ex),
    .alu_res(alures_ex)
);

BRANCH branch(
    .br_type(brtype_ex),
    .br_src0(rfrd0_ex),
    .br_src1(rfrd1_ex),
    .npc_sel(npcsel_ex)
);

NPCMUX npcmux(
    .pc_add4(pcadd4_if),
    .pc_offset(alures_ex),
    .pc_j(32'b0),
    .sel(npcsel_ex),
    .res(npc_ex)
);

//mem
SLU slu(
    .addr(alures_mem),
    .dmem_access(dmemaccess_mem),
    .rd_in(dmem_rdata),
    .wd_in(rfrd1_mem),
    .rd_out(dmem_rd_out_mem),
    .wd_out(dmem_wdata)
);

//wb
MUX2 #(32) mux2(
    .src0(pcadd4_wb),
    .src1(alures_wb),
    .src2(dmem_rd_out_wb),
    .src3(32'b0),
    .sel(rfwdsel_wb),
    .res(rfwd_wb)
);

//fowarding
MUX #(32) fw0(
    .src0(rfrd0raw_ex),
    .src1(rfrd0_fd),
    .sel(rfrd0_fe),
    .res(rfrd0_ex)
);

MUX #(32) fw1(
    .src0(rfrd1raw_ex),
    .src1(rfrd1_fd),
    .sel(rfrd1_fe),
    .res(rfrd1_ex)
);

FOWARDING fowarding(
    .rf_we_mem(rfwe_mem),
    .rf_we_wb(rfwe_wb),
    .rf_wa_mem(rfwa_mem),
    .rf_wa_wb(rfwa_wb),
    .rf_wd_mem(alures_mem),
    .rf_wd_wb(rfwd_wb),
    .rf_ra0_ex(rfra0_ex),
    .rf_ra1_ex(rfra1_ex),
    .rf_wd_sel_mem(rfwdsel_mem),
    .rf_rd0_fe(rfrd0_fe),
    .rf_rd1_fe(rfrd1_fe),
    .rf_rd0_fd(rfrd0_fd),
    .rf_rd1_fd(rfrd1_fd)
);

SEGCTRL segctrl(
    .rf_we_ex(rfwe_ex),
    .rf_wd_sel_ex(rfwdsel_ex),
    .rf_wa_ex(rfwa_ex),
    .rf_ra0_id(rfra0_id),
    .rf_ra1_id(rfra1_id),
    .npc_sel_ex(npcsel_ex),
    .stall_pc(stall_pc),
    .stall_ifid(stall_ifid),
    .flush_ifid(flush_ifid),
    .flush_idex(flush_idex)
);

INTERSEGMENTREGFILE intersegmentregfile(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall_ifid(stall_ifid),
    .stall_idex(stall_idex),
    .stall_exmem(stall_exmem),
    .stall_memwb(stall_memwb),
    .flush_ifid(flush_ifid),
    .flush_idex(flush_idex),
    .flush_exmem(flush_exmem),
    .flush_memwb(flush_memwb),

    .inst_if_out(inst_if),
    .pcadd4_if_out(pcadd4_if),
    .pc_if_out(pc_if),
    .inst_id_in(inst_id),
    .pcadd4_id_in(pcadd4_id),
    .pc_id_in(pc_id),

    .pcadd4_id_out(pcadd4_id),
    .pc_id_out(pc_id),
    .rfrd0_id_out(rfrd0_id),
    .rfrd1_id_out(rfrd1_id),
    .imm_id_out(imm_id),
    .rfwa_id_out(rfwa_id),
    .rfwe_id_out(rfwe_id),
    .rfra0_id_out(rfra0_id),
    .rfra1_id_out(rfra1_id),
    .pcadd4_ex_in(pcadd4_ex),
    .pc_ex_in(pc_ex),
    .rfrd0_ex_in(rfrd0raw_ex),
    .rfrd1_ex_in(rfrd1raw_ex),
    .imm_ex_in(imm_ex),
    .rfwa_ex_in(rfwa_ex),
    .rfwe_ex_in(rfwe_ex),
    .rfra0_ex_in(rfra0_ex),
    .rfra1_ex_in(rfra1_ex),

    .pcadd4_ex_out(pcadd4_ex),
    .alures_ex_out(alures_ex),
    .rfrd1_ex_out(rfrd1_ex),
    .rfwa_ex_out(rfwa_ex),
    .rfwe_ex_out(rfwe_ex),
    .pcadd4_mem_in(pcadd4_mem),
    .alures_mem_in(alures_mem),
    .rfrd1_mem_in(rfrd1_mem),
    .rfwa_mem_in(rfwa_mem),
    .rfwe_mem_in(rfwe_mem),

    .pcadd4_mem_out(pcadd4_mem),
    .alures_mem_out(alures_mem),
    .dmem_rd_out_mem_out(dmem_rd_out_mem),
    .rfwa_mem_out(rfwa_mem),
    .rfwe_mem_out(rfwe_mem),
    .pcadd4_wb_in(pcadd4_wb),
    .alures_wb_in(alures_wb),
    .dmem_rd_out_wb_in(dmem_rd_out_wb),
    .rfwa_wb_in(rfwa_wb),
    .rfwe_wb_in(rfwe_wb),

    .aluop_id_out(aluop_id),
    .aluop_ex_in(aluop_ex),

    .dmemaccess_id_out(dmemaccess_id),
    .dmemaccess_ex_in(dmemaccess_ex),
    .dmemaccess_ex_out(dmemaccess_ex),
    .dmemaccess_mem_in(dmemaccess_mem),

    .rfwdsel_id_out(rfwdsel_id),
    .rfwdsel_ex_in(rfwdsel_ex),
    .rfwdsel_ex_out(rfwdsel_ex),
    .rfwdsel_mem_in(rfwdsel_mem),
    .rfwdsel_mem_out(rfwdsel_mem),
    .rfwdsel_wb_in(rfwdsel_wb),

    .alusrc0sel_id_out(alusrc0sel_id),
    .alusrc1sel_id_out(alusrc1sel_id),
    .alusrc0sel_ex_in(alusrc0sel_ex),
    .alusrc1sel_ex_in(alusrc1sel_ex),

    .brtype_id_out(brtype_id),
    .brtype_ex_in(brtype_ex),

    .commit_if_out(commit_if),
    .commit_id_out(commit_id),
    .commit_ex_out(commit_ex),
    .commit_mem_out(commit_mem),
    .commit_id_in(commit_id),
    .commit_ex_in(commit_ex),
    .commit_mem_in(commit_mem),
    .commit_wb_in(commit_wb),

    .pc_ex_out(pc_ex),
    .pc_mem_out(pc_mem),
    .pc_mem_in(pc_mem),
    .pc_wb_in(pc_wb),

    .inst_id_out(inst_id),
    .inst_ex_out(inst_ex),
    .inst_mem_out(inst_mem),
    .inst_ex_in(inst_ex),
    .inst_mem_in(inst_mem),
    .inst_wb_in(inst_wb),

    .dmem_we_mem_out(dmem_we),
    .dmem_addr_mem_out(dmem_addr),
    .dmem_wdata_mem_out(dmem_wdata),
    .dmem_we_wb_in(dmem_we_wb),
    .dmem_addr_wb_in(dmem_addr_wb),
    .dmem_wdata_wb_in(dmem_wdata_wb)
);



/* -------------------------------------------------------------------------- */
/*                                    Commit                                  */
/* -------------------------------------------------------------------------- */

    wire [ 0 : 0] commit_if     ;
    assign commit_if = 1'H1;

    reg  [ 0 : 0]   commit_reg          ;
    reg  [31 : 0]   commit_pc_reg       ;
    reg  [31 : 0]   commit_inst_reg     ;
    reg  [ 0 : 0]   commit_halt_reg     ;
    reg  [ 0 : 0]   commit_reg_we_reg   ;
    reg  [ 4 : 0]   commit_reg_wa_reg   ;
    reg  [31 : 0]   commit_reg_wd_reg   ;
    reg  [ 0 : 0]   commit_dmem_we_reg  ;
    reg  [31 : 0]   commit_dmem_wa_reg  ;
    reg  [31 : 0]   commit_dmem_wd_reg  ;

    always @(posedge clk) begin
        if (rst) begin
            commit_reg          <= 1'H0;
            commit_pc_reg       <= 32'H0;
            commit_inst_reg     <= 32'H0;
            commit_halt_reg     <= 1'H0;
            commit_reg_we_reg   <= 1'H0;
            commit_reg_wa_reg   <= 5'H0;
            commit_reg_wd_reg   <= 32'H0;
            commit_dmem_we_reg  <= 1'H0;
            commit_dmem_wa_reg  <= 32'H0;
            commit_dmem_wd_reg  <= 32'H0;
        end
        else if (global_en) begin
            commit_reg          <= commit_wb;
            commit_pc_reg       <= pc_wb;                          // TODO
            commit_inst_reg     <= inst_wb;                        // TODO
            commit_halt_reg     <= (inst_wb == 32'H8000_0000);     // TODO
            commit_reg_we_reg   <= rfwe_wb;                       // TODO
            commit_reg_wa_reg   <= rfwa_wb;                       // TODO
            commit_reg_wd_reg   <= rfwd_wb;                       // TODO
            commit_dmem_we_reg  <= dmem_we_wb;
            commit_dmem_wa_reg  <= dmem_addr_wb;
            commit_dmem_wd_reg  <= dmem_wdata_wb;

        end
    end

    assign commit               = commit_reg;
    assign commit_pc            = commit_pc_reg;
    assign commit_inst          = commit_inst_reg;
    assign commit_halt          = commit_halt_reg;
    assign commit_reg_we        = commit_reg_we_reg;
    assign commit_reg_wa        = commit_reg_wa_reg;
    assign commit_reg_wd        = commit_reg_wd_reg;
    assign commit_dmem_we       = commit_dmem_we_reg;
    assign commit_dmem_wa       = commit_dmem_wa_reg;
    assign commit_dmem_wd       = commit_dmem_wd_reg;
endmodule
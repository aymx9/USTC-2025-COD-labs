module INTERSEGMENTREGFILE (
    input                   clk,
    input                   rst,
    input                   en,
    input                   stall_ifid,
    input                   stall_idex,
    input                   stall_exmem,
    input                   stall_memwb,
    input                   flush_ifid,
    input                   flush_idex,
    input                   flush_exmem,
    input                   flush_memwb,

    input       [31: 0]     inst_if_out,
    input       [31: 0]     pcadd4_if_out,
    input       [31: 0]     pc_if_out,
    output  reg [31: 0]     inst_id_in,
    output  reg [31: 0]     pcadd4_id_in,
    output  reg [31: 0]     pc_id_in,

    input       [31: 0]     pcadd4_id_out,
    input       [31: 0]     pc_id_out,
    input       [31: 0]     rfrd0_id_out,
    input       [31: 0]     rfrd1_id_out,
    input       [31: 0]     imm_id_out,
    input       [ 4: 0]     rfwa_id_out,
    input       [ 0: 0]     rfwe_id_out,
    input       [ 4: 0]     rfra0_id_out,
    input       [ 4: 0]     rfra1_id_out,
    output  reg [31: 0]     pcadd4_ex_in,
    output  reg [31: 0]     pc_ex_in,
    output  reg [31: 0]     rfrd0_ex_in,
    output  reg [31: 0]     rfrd1_ex_in,
    output  reg [31: 0]     imm_ex_in,
    output  reg [ 4: 0]     rfwa_ex_in,
    output  reg [ 0: 0]     rfwe_ex_in,
    output  reg [ 4: 0]     rfra0_ex_in,
    output  reg [ 4: 0]     rfra1_ex_in,

    input       [31: 0]     pcadd4_ex_out,
    input       [31: 0]     alures_ex_out,
    input       [31: 0]     rfrd1_ex_out,
    input       [ 4: 0]     rfwa_ex_out,
    input       [ 0: 0]     rfwe_ex_out,
    output  reg [31: 0]     pcadd4_mem_in,
    output  reg [31: 0]     alures_mem_in,
    output  reg [31: 0]     rfrd1_mem_in,
    output  reg [ 4: 0]     rfwa_mem_in,
    output  reg [ 0: 0]     rfwe_mem_in,

    input       [31: 0]     pcadd4_mem_out,
    input       [31: 0]     alures_mem_out,
    input       [31: 0]     dmem_rd_out_mem_out,
    input       [ 4: 0]     rfwa_mem_out,
    input       [ 0: 0]     rfwe_mem_out,
    output  reg [31: 0]     pcadd4_wb_in,
    output  reg [31: 0]     alures_wb_in,
    output  reg [31: 0]     dmem_rd_out_wb_in,
    output  reg [ 4: 0]     rfwa_wb_in,
    output  reg [ 0: 0]     rfwe_wb_in,

    input       [ 4: 0]     aluop_id_out,
    output  reg [ 4: 0]     aluop_ex_in,

    input       [ 3: 0]     dmemaccess_id_out,
    output  reg [ 3: 0]     dmemaccess_ex_in,
    input       [ 3: 0]     dmemaccess_ex_out,
    output  reg [ 3: 0]     dmemaccess_mem_in,

    input       [ 1: 0]     rfwdsel_id_out,
    output  reg [ 1: 0]     rfwdsel_ex_in,
    input       [ 1: 0]     rfwdsel_ex_out,
    output  reg [ 1: 0]     rfwdsel_mem_in,
    input       [ 1: 0]     rfwdsel_mem_out,
    output  reg [ 1: 0]     rfwdsel_wb_in,

    input                   alusrc0sel_id_out,
    input                   alusrc1sel_id_out,
    output  reg             alusrc0sel_ex_in,
    output  reg             alusrc1sel_ex_in,

    input       [ 3: 0]     brtype_id_out,
    output  reg [ 3: 0]     brtype_ex_in,

    input                   commit_if_out,
    input                   commit_id_out,
    input                   commit_ex_out,
    input                   commit_mem_out,
    output  reg             commit_id_in,
    output  reg             commit_ex_in,
    output  reg             commit_mem_in,
    output  reg             commit_wb_in,

    input       [31: 0]     pc_ex_out,
    input       [31: 0]     pc_mem_out,
    output  reg [31: 0]     pc_mem_in,
    output  reg [31: 0]     pc_wb_in,

    input       [31: 0]     inst_id_out,
    input       [31: 0]     inst_ex_out,
    input       [31: 0]     inst_mem_out,
    output  reg [31: 0]     inst_ex_in,
    output  reg [31: 0]     inst_mem_in,
    output  reg [31: 0]     inst_wb_in,

    input                   dmem_we_mem_out,
    input       [31: 0]     dmem_addr_mem_out,
    input       [31: 0]     dmem_wdata_mem_out,
    output  reg             dmem_we_wb_in,
    output  reg [31: 0]     dmem_addr_wb_in,
    output  reg [31: 0]     dmem_wdata_wb_in
);  

//ifid
always @(posedge clk) begin
    if (rst) begin
        pc_id_in <= 32'h1c00_0000;
        inst_id_in <= 0;
        pcadd4_id_in <= 0;
        commit_id_in <= 0;
    end
    else if (en) begin
        // flush 和 stall 操作的逻辑, flush 的优先级更高
        if(flush_ifid) begin
            pc_id_in <= 32'h1c00_0000;
            inst_id_in <= 0;
            pcadd4_id_in <= 0;
            commit_id_in <= 0;
        end
        else if(stall_ifid) begin
            pc_id_in <= pc_id_in;
            inst_id_in <= inst_id_in;
            pcadd4_id_in <= pcadd4_id_in;
            commit_id_in <= commit_id_in;
        end
        else begin
            pc_id_in <= pc_if_out;
            inst_id_in <= inst_if_out;
            pcadd4_id_in <= pcadd4_if_out;
            commit_id_in <= commit_if_out;
        end
    end
end

//idex
always @(posedge clk) begin
    if (rst) begin
        pcadd4_ex_in <= 0;
        pc_ex_in <= 0;
        rfrd0_ex_in <= 0;
        rfrd1_ex_in <= 0;
        imm_ex_in <= 0;
        rfwa_ex_in <= 0;
        rfwe_ex_in <= 0;
        rfra0_ex_in <= 0;
        rfra1_ex_in <= 0;
        aluop_ex_in <= 0;
        dmemaccess_ex_in <= 0;
        rfwdsel_ex_in <= 0;
        alusrc0sel_ex_in <= 0;
        alusrc1sel_ex_in <= 0;
        brtype_ex_in <= 0;
        commit_ex_in <= 0;
        inst_ex_in <= 0;
    end
    else if (en) begin
        // flush 和 stall 操作的逻辑, flush 的优先级更高
        if(flush_idex) begin
            pcadd4_ex_in <= 0;
            pc_ex_in <= 0;
            rfrd0_ex_in <= 0;
            rfrd1_ex_in <= 0;
            imm_ex_in <= 0;
            rfwa_ex_in <= 0;
            rfwe_ex_in <= 0;
            rfra0_ex_in <= 0;
            rfra1_ex_in <= 0;
            aluop_ex_in <= 0;
            dmemaccess_ex_in <= 0;
            rfwdsel_ex_in <= 0;
            alusrc0sel_ex_in <= 0;
            alusrc1sel_ex_in <= 0;
            brtype_ex_in <= 0;
            commit_ex_in <= 0;
            inst_ex_in <= 0;
        end
        else if(stall_idex) begin
            pcadd4_ex_in <= pcadd4_ex_in;
            pc_ex_in <= pc_ex_in;
            rfrd0_ex_in <= rfrd0_ex_in;
            rfrd1_ex_in <= rfrd1_ex_in;
            imm_ex_in <= imm_ex_in;
            rfwa_ex_in <= rfwa_ex_in;
            rfwe_ex_in <= rfwe_ex_in;
            rfra0_ex_in <= rfra0_ex_in;
            rfra1_ex_in <= rfra1_ex_in;
            aluop_ex_in <= aluop_ex_in;
            dmemaccess_ex_in <= dmemaccess_ex_in;
            rfwdsel_ex_in <= rfwdsel_ex_in;
            alusrc0sel_ex_in <= alusrc0sel_ex_in;
            alusrc1sel_ex_in <= alusrc1sel_ex_in;
            brtype_ex_in <= brtype_ex_in;
            commit_ex_in <= commit_ex_in;
            inst_ex_in <= inst_ex_in;
        end
        else begin
            pcadd4_ex_in <= pcadd4_id_out;
            pc_ex_in <= pc_id_out;
            rfrd0_ex_in <= rfrd0_id_out;
            rfrd1_ex_in <= rfrd1_id_out;
            imm_ex_in <= imm_id_out;
            rfwa_ex_in <= rfwa_id_out;
            rfwe_ex_in <= rfwe_id_out;
            rfra0_ex_in <= rfra0_id_out;
            rfra1_ex_in <= rfra1_id_out;
            aluop_ex_in <= aluop_id_out;
            dmemaccess_ex_in <= dmemaccess_id_out;
            rfwdsel_ex_in <= rfwdsel_id_out;
            alusrc0sel_ex_in <= alusrc0sel_id_out;
            alusrc1sel_ex_in <= alusrc1sel_id_out;
            brtype_ex_in <= brtype_id_out;
            commit_ex_in <= commit_id_out;
            inst_ex_in <= inst_id_out;
        end
    end
end

//exmem
always @(posedge clk) begin
    if (rst) begin
        pcadd4_mem_in <= 0;
        alures_mem_in <= 0;
        rfrd1_mem_in <= 0;
        rfwa_mem_in <= 0;
        rfwe_mem_in <= 0;
        dmemaccess_mem_in <= 0;
        rfwdsel_mem_in <= 0;
        commit_mem_in <= 0;
        pc_mem_in <= 0;
        inst_mem_in <= 0;
    end
    else if (en) begin
        // flush 和 stall 操作的逻辑, flush 的优先级更高
        if(flush_exmem) begin
            pcadd4_mem_in <= 0;
            alures_mem_in <= 0;
            rfrd1_mem_in <= 0;
            rfwa_mem_in <= 0;
            rfwe_mem_in <= 0;
            dmemaccess_mem_in <= 0;
            rfwdsel_mem_in <= 0;
            commit_mem_in <= 0;
            pc_mem_in <= 0;
            inst_mem_in <= 0;
        end
        else if(stall_exmem) begin
            pcadd4_mem_in <= pcadd4_mem_in;
            alures_mem_in <= alures_mem_in;
            rfrd1_mem_in <= rfrd1_mem_in;
            rfwa_mem_in <= rfwa_mem_in;
            rfwe_mem_in <= rfwe_mem_in;
            dmemaccess_mem_in <= dmemaccess_mem_in;
            rfwdsel_mem_in <= rfwdsel_mem_in;
            commit_mem_in <= commit_mem_in;
            pc_mem_in <= pc_mem_in;
            inst_mem_in <= inst_mem_in;
        end
        else begin
            pcadd4_mem_in <= pcadd4_ex_out;
            alures_mem_in <= alures_ex_out;
            rfrd1_mem_in <= rfrd1_ex_out;
            rfwa_mem_in <= rfwa_ex_out;
            rfwe_mem_in <= rfwe_ex_out;
            dmemaccess_mem_in <= dmemaccess_ex_out;
            rfwdsel_mem_in <= rfwdsel_ex_out;
            commit_mem_in <= commit_ex_out;
            pc_mem_in <= pc_ex_out;
            inst_mem_in <= inst_ex_out;
        end
    end
end

//memwb
always @(posedge clk) begin
    if (rst) begin
        pcadd4_wb_in <= 0;
        alures_wb_in <= 0;
        dmem_rd_out_wb_in <= 0;
        rfwa_wb_in <= 0;
        rfwe_wb_in <= 0;
        rfwdsel_wb_in <= 0;
        commit_wb_in <= 0;
        pc_wb_in <= 0;
        inst_wb_in <= 0;
        dmem_we_wb_in <= 0;
        dmem_addr_wb_in <= 0;
        dmem_wdata_wb_in <= 0;
    end
    else if (en) begin
        // flush 和 stall 操作的逻辑, flush 的优先级更高
        if(flush_memwb) begin
            pcadd4_mem_in <= 0;
            alures_mem_in <= 0;
            rfrd1_mem_in <= 0;
            rfwa_mem_in <= 0;
            rfwe_mem_in <= 0;
            dmemaccess_mem_in <= 0;
            rfwdsel_mem_in <= 0;
            commit_mem_in <= 0;
            pc_mem_in <= 0;
            inst_mem_in <= 0;
            dmem_we_wb_in <= 0;
            dmem_addr_wb_in <= 0;
            dmem_wdata_wb_in <= 0;
        end
        else if(stall_memwb) begin
            pcadd4_wb_in <= pcadd4_wb_in;
            alures_wb_in <= alures_wb_in;
            dmem_rd_out_wb_in <= dmem_rd_out_wb_in;
            rfwa_wb_in <= rfwa_wb_in;
            rfwe_wb_in <= rfwe_wb_in;
            rfwdsel_wb_in <= rfwdsel_wb_in;
            commit_wb_in <= commit_wb_in;
            pc_wb_in <= pc_wb_in;
            inst_wb_in <= inst_wb_in;
            dmem_we_wb_in <= dmem_we_wb_in;
            dmem_addr_wb_in <= dmem_addr_wb_in;
            dmem_wdata_wb_in <= dmem_wdata_wb_in;
        end
        else begin
            pcadd4_wb_in <= pcadd4_mem_out;
            alures_wb_in <= alures_mem_out;
            dmem_rd_out_wb_in <= dmem_rd_out_mem_out;
            rfwa_wb_in <= rfwa_mem_out;
            rfwe_wb_in <= rfwe_mem_out;
            rfwdsel_wb_in <= rfwdsel_mem_out;
            commit_wb_in <= commit_mem_out;
            pc_wb_in <= pc_mem_out;
            inst_wb_in <= inst_mem_out;
            dmem_we_wb_in <= dmem_we_mem_out;
            dmem_addr_wb_in <= dmem_addr_mem_out;
            dmem_wdata_wb_in <= dmem_wdata_mem_out;
        end
    end
end

endmodule
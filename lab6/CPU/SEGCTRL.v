module SEGCTRL(
    input                   rf_we_ex,
    input       [ 1: 1]     rf_wd_sel_ex,
    input       [ 4: 0]     rf_wa_ex,
    input       [ 4: 0]     rf_ra0_id,
    input       [ 4: 0]     rf_ra1_id,
    input       [ 1: 0]     npc_sel_ex,

    output  reg             stall_pc,
    output  reg             stall_ifid,
    output  reg             flush_ifid,
    output  reg             flush_idex
);

always @(*) begin
    if(rf_wd_sel_ex == 2'b10) begin
        if(rf_wa_ex != 5'b00000) begin
            if(rf_wa_ex == rf_ra0_id || rf_wa_ex == rf_ra1_id) begin
                stall_pc = 1;
                stall_ifid = 1;
            end
            else begin
                stall_pc = 0;
                stall_ifid = 0;
            end
        end
    end
end

always @(*) begin
    if(npc_sel_ex == 2'b11) begin
        flush_ifid = 1;
    end
    else begin
        flush_ifid = 0;
    end
end

always @(*) begin
    if(npc_sel_ex == 2'b11) begin
        flush_idex = 1;
    end
    else if(rf_wd_sel_ex == 2'b10) begin
        if(rf_wa_ex != 5'b00000) begin
            if(rf_wa_ex == rf_ra0_id || rf_wa_ex == rf_ra1_id) begin
                flush_idex = 1;
            end
        end
    end
    else flush_idex = 0;
end


endmodule
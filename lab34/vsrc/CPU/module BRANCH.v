module BRANCH(
    input                   [ 3 : 0]            br_type,//

    input                   [31 : 0]            br_src0,
    input                   [31 : 0]            br_src1,

    output      reg         [ 0 : 0]            npc_sel
);

always@(*) begin
    //初始化
    npc_sel = 1'b0;
    
    case(br_type)
        4'b0000: npc_sel = (br_src0 == br_src1) ? 1 : 0;//如果相等则跳转
        4'b0001: npc_sel = ($signed(br_src0) >= $signed(br_src1)) ? 1 : 0;//有符号大于等于跳转
        4'b0010: npc_sel = (br_src0 >= br_src1) ? 1 : 0;//无符号大于等于跳转
        4'b0011: npc_sel = ($signed(br_src0) < $signed(br_src1)) ? 1 : 0;//有符号小于跳转
        4'b0100: npc_sel = (br_src0 < br_src1) ? 1 : 0;//无符号小于跳转
        4'b0101: npc_sel = (br_src0 != br_src1) ? 1 : 0;//不等于跳转
        4'b0110: npc_sel = 1;//无条件跳转
        default: npc_sel = 0;
     endcase

end


endmodule
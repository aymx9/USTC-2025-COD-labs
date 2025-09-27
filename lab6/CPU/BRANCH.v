module BRANCH(
    input                   [ 3 : 0]            br_type,

    input                   [31 : 0]            br_src0,
    input                   [31 : 0]            br_src1,

    output      reg         [ 1 : 0]            npc_sel
);

wire ul, sl;

COMP comp_bra(
    .a(br_src0),
    .b(br_src1),
    .ul(ul),
    .sl(sl)
);

always @(*) begin
    case(br_type)
        4'b0011, 4'b0100, 4'b0101:npc_sel = 2'b11;
        4'b0110:begin
            if(br_src0 == br_src1)
                npc_sel = 2'b11;
            else npc_sel = 2'b10;
        end
        4'b0111:begin
            if(br_src0 != br_src1)
                npc_sel = 2'b11;
            else npc_sel = 2'b10;
        end
        4'b1000:begin
            if(sl == 1'b1)
                npc_sel = 2'b11;
            else npc_sel = 2'b10;
        end
        4'b1001:begin
            if(sl == 1'b0)
                npc_sel = 2'b11;
            else npc_sel = 2'b10;
        end
        4'b1010:begin
            if(ul == 1'b1)
                npc_sel = 2'b11;
            else npc_sel = 2'b10;
        end
        4'b1011:begin
            if(ul == 1'b0)
                npc_sel = 2'b11;
            else npc_sel = 2'b10;
        end
        default: npc_sel = 2'b10;
    endcase
end


endmodule
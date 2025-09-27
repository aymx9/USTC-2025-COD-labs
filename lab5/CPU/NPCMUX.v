module NPCMUX(
    input                   [31: 0]           pc_add4, pc_offset, pc_j,
    input                   [ 1: 0]           sel,

    output                  [31: 0]           res
);

assign res = sel[1] ? (sel[0] ? pc_offset : pc_add4) : pc_j;
//00:pc_j
//01:pc_j
//10:pc_add4
//11:pc_offset


endmodule

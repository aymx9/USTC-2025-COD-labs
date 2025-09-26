module NPC_MUX(
    input           [31:0]      pc_add4,
    input           [31:0]      pc_offset,
    input           [0: 0]      npc_sel,
    output          [31:0]      npc
);
    assign npc = npc_sel ? pc_offset : pc_add4;
endmodule
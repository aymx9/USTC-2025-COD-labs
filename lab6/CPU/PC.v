module PC (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,
    input                   [ 0 : 0]            en,
    input                   [31 : 0]            npc,
    input                                       stall_pc,

    output      reg         [31 : 0]            pc
);

initial begin
    pc = 32'h1c00_0000;
end

always @(posedge clk) begin
    if(rst)
        pc <= 32'h1c00_0000;
    else if(en) begin
        if(stall_pc) 
            pc <= pc;
        else pc <= npc;
    end
    else pc <= pc;
end


endmodule
module PC (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,
    input                   [ 0 : 0]            en,
    input                   [31 : 0]            npc,

    output      reg         [31 : 0]            pc
);//使能信号en还未接入模块

    reg     [31 : 0]        q;

    always @(posedge clk) begin
        if (rst)
            pc <= 32'H1C000000; 
        else
            if(en)
                pc <= npc;     // q stores the value inside the register
    end

endmodule
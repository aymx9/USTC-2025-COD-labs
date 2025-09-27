`define ADD_W               5'B00000 
`define SUB_W               5'B00010
`define SLT                 5'B00100
`define SLTU                5'B00101
`define AND                 5'B01001
`define OR                  5'B01010
`define XOR                 5'B01011
`define SLL_W               5'B01110
`define SRL_W               5'B01111
`define SRA_W               5'B10000
`define SRC0                5'B10001
`define SRC1                5'B10010

module ALU (
    input                   [31 : 0]            alu_src0,
    input                   [31 : 0]            alu_src1,
    input                   [ 4 : 0]            alu_op,

    output      reg         [31 : 0]            alu_res
);

wire ul, sl;

COMP comp_alu(
    .a(alu_src0),
    .b(alu_src1),
    .ul(ul),
    .sl(sl)
);
    
always @(*) begin
    case(alu_op)
        `ADD_W  :alu_res = alu_src0 + alu_src1;
        `SUB_W  :alu_res = alu_src0 - alu_src1;
        `SLT    :alu_res = ({31'b0000_0000_0000_0000_0000_0000_0000_000,{sl}});
        `SLTU   :alu_res = ({31'b0000_0000_0000_0000_0000_0000_0000_000,{ul}});
        `AND    :alu_res = alu_src0 & alu_src1;
        `OR     :alu_res = alu_src0 | alu_src1;
        `XOR    :alu_res = alu_src0 ^ alu_src1;
        `SLL_W  :alu_res = alu_src0 << alu_src1[4:0];
        `SRL_W  :alu_res = alu_src0 >> alu_src1[4:0];
        `SRA_W  :alu_res = $signed(alu_src0) >>> alu_src1[4:0];
        `SRC0   :alu_res = alu_src0;
        `SRC1   :alu_res = alu_src1;
        default :
            alu_res = 32'H0;
    endcase
end

endmodule

`define LDB     4'b0000
`define LDH     4'b0001
`define LDW     4'b0010
`define STB     4'b0100
`define STH     4'b0101
`define STW     4'b0110
`define LDBU    4'b1000
`define LDHU    4'b1001

module SLU (
    input                   [31 : 0]                addr,
    input                   [ 3 : 0]                dmem_access,

    input                   [31 : 0]                rd_in,
    input                   [31 : 0]                wd_in,

    output      reg         [31 : 0]                rd_out,
    output      reg         [31 : 0]                wd_out
);

wire x0, x1, x2, x3;
assign x0 = (addr[1:0] == 2'b00);
assign x1 = (addr[1:0] == 2'b01);
assign x2 = (addr[1:0] == 2'b10);
assign x3 = (addr[1:0] == 2'b11);

always @(*) begin
    wd_out = wd_in;
    rd_out = rd_in;
    case(dmem_access)
        `LDB    :rd_out = ({{24{rd_in[ 7]}}, rd_in[ 7: 0]} & {32{x0}}) | ({{24{rd_in[15]}}, rd_in[15: 8]} & {32{x1}})
                        | ({{24{rd_in[23]}}, rd_in[23:16]} & {32{x2}}) | ({{24{rd_in[31]}}, rd_in[31:24]} & {32{x3}});
        `LDH    :rd_out = ({{16{rd_in[15]}}, rd_in[15: 0]} & {32{x0 | x1}})
                        | ({{16{rd_in[31]}}, rd_in[31:16]} & {32{x2 | x3}});
        `LDW    :rd_out = rd_in;
        `LDBU   :rd_out = ({{24'b0}, rd_in[ 7: 0]} & {32{x0}}) | ({{24'b0}, rd_in[15: 8]} & {32{x1}})
                        | ({{24'b0}, rd_in[23:16]} & {32{x2}}) | ({{24'b0}, rd_in[31:24]} & {32{x3}});
        `LDHU   :rd_out = ({{16'b0}, rd_in[15: 0]} & {32{x0 | x1}})
                        | ({{16'b0}, rd_in[31:16]} & {32{x2 | x3}});

        `STB    :wd_out = ({rd_in[31: 8], wd_in[ 7: 0]              } & {32{x0}})
                        | ({rd_in[31:16], wd_in[ 7: 0], rd_in[ 7: 0]} & {32{x1}})
                        | ({rd_in[31:24], wd_in[ 7: 0], rd_in[15: 0]} & {32{x2}})
                        | ({              wd_in[ 7: 0], rd_in[23: 0]} & {32{x3}});
        `STH    :wd_out = ({rd_in[31:16], wd_in[15: 0]} & {32{x0 | x1}})
                        | ({wd_in[15: 0], rd_in[15: 0]} & {32{x2 | x3}});
        `STW    :wd_out = wd_in;
        default :begin
            wd_out = wd_in;
            rd_out = rd_in;
        end
    endcase
end

endmodule
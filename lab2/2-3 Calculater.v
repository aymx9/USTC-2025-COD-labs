module TOP (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            enable,
    input                   [ 4 : 0]            in,
    input                   [ 1 : 0]            ctrl,

    output                  [ 3 : 0]            seg_data,
    output                  [ 2 : 0]            seg_an
);

    reg     [31 : 0]        alu_src0;
    reg     [31 : 0]        alu_src1;
    reg     [ 4 : 0]        alu_op;
    reg     [31 : 0]        temp;
    wire    [31 : 0]        res;

ALU alu (
    .alu_src0(alu_src0),
    .alu_src1(alu_src1),
    .alu_op(alu_op),

    .alu_res(res)
);

Segment segment (
    .clk(clk),
    .rst(rst),
    .output_data(temp),
    .seg_data(seg_data),
    .seg_an(seg_an)
);

always @(*) begin
        if(enable) begin
            case(ctrl)
                2'B00:
                    alu_op = in;
                2'B01:
                    alu_src0[31:0] = {{27{in[4]}}, in[4:0]};
                2'B10:
                    alu_src1[31:0] = {{27{in[4]}}, in[4:0]};
                2'B11:
                    temp = res; 
            endcase
        end
        if(rst) begin
            temp = 0;
        end
    end

endmodule
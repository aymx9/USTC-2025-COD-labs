module SLU (
    input                   [31 : 0]                addr,//地址
    input                   [ 3 : 0]                dmem_access,

    input                   [31 : 0]                rd_in,//从存储器读到的原始数据(LD)
    input                   [31 : 0]                wd_in,//要写入存储器的原始数据（SD）

    output      reg         [31 : 0]                rd_out,//要写入存储器的数据
    output      reg         [31 : 0]                wd_out//要写入存储器的数据
);

//dmem_access
`define LDW 4'b0000
`define STW 4'b0001
`define LDH 4'b0010
`define STH 4'b0011
`define LDB 4'b0100
`define STB 4'b0101
`define LDHU 4'b0110
`define LDBU 4'b0111
`define NONE 4'b1000

always @(*) begin
    //初始化
    rd_out = 32'h0;
    wd_out = 32'h0;
    case (dmem_access)
        `LDW: begin                   //LDW、STW整字操作
            rd_out = rd_in;    
        end
        `STW: begin
            wd_out = wd_in;
        end

        //LDH、STH为半字
        //loongarch采用小端序，所以低地址存低位
        `LDH: begin
            case (addr[1])//地址的第二位
                1'b0: begin
                    //一个字为4个字节，所以一个半字为2个字节
                    rd_out = {{16{rd_in[15]}}, rd_in[15:0]};//低地址存低位
                end
                1'b1: begin
                    rd_out = {{16{rd_in[31]}}, rd_in[31:16]};//高地址存高位
                end
            endcase
        end
        `STH: begin
            case (addr[1])
                1'b0: begin
                    wd_out = {rd_in[31:16], wd_in[15:0]};//要修改的是低位，rd_in[]读入高位值，再和寄存器低位值拼接
                end
                1'b1: begin
                    wd_out = {wd_in[15:0], rd_in[15:0]};
                end
            endcase
        end

        //LDB、STB为字节
        `LDB: begin
            case(addr[1:0])
                2'b00: begin
                    rd_out = {{24{rd_in[7]}}, rd_in[7:0]};
                end
                2'b01: begin
                    rd_out = {{24{rd_in[15]}}, rd_in[15:8]};
                end
                2'b10: begin
                    rd_out = {{24{rd_in[23]}}, rd_in[23:16]};
                end
                2'b11: begin
                    rd_out = {{24{rd_in[31]}}, rd_in[31:24]};
                end
            endcase
        end
        `STB: begin
            case(addr[1:0])
                2'b00: begin
                    wd_out = {rd_in[31:8], wd_in[7:0]};
                end
                2'b01: begin
                    wd_out = {rd_in[31:16], wd_in[7:0], rd_in[7:0]};
                end
                2'b10: begin
                    wd_out = {rd_in[31:24], wd_in[7:0], rd_in[15:0]};
                end
                2'b11: begin
                    wd_out = {wd_in[7:0], rd_in[23:0]};
                end
            endcase
        end

        //LDHU、LDBU为无符号扩展
        `LDHU: begin
            case (addr[1])
                1'b0: begin
                    rd_out = {16'b0, rd_in[15:0]};
                end
                1'b1: begin
                    rd_out = {16'b0, rd_in[31:16]};
                end
            endcase
        end
        `LDBU: begin
            case(addr[1:0])
                2'b00: begin
                    rd_out = {24'h0, rd_in[7:0]};
                end
                2'b01: begin
                    rd_out = {24'h0, rd_in[15:8]};
                end
                2'b10: begin
                    rd_out = {24'h0, rd_in[23:16]};
                end
                2'b11: begin
                    rd_out = {24'h0, rd_in[31:24]};
                end
            endcase
        end
        default: begin
            // 无访存操作
        end
    endcase
end
endmodule

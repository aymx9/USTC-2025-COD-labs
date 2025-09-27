module DECODE (
    input                   [31 : 0]            inst,

    output                  [ 4 : 0]            alu_op,
    output                  [31 : 0]            imm,
    output                  [ 3 : 0]            dmem_access,

    output                  [ 4 : 0]            rf_ra0,
    output                  [ 4 : 0]            rf_ra1,
    output                  [ 4 : 0]            rf_wa,
    output                  [ 0 : 0]            rf_we,
    output                  [ 1 : 0]            rf_wd_sel,

    output                  [ 0 : 0]            alu_src0_sel,
    output                  [ 0 : 0]            alu_src1_sel,

    output                  [ 3 : 0]            br_type
);

wire add, addi, sub, slt, sltu, i_and, i_or, i_xor, sll, srl, sra, slli, srli, srai, slti, sltui, andi, ori, xori, lu12i, pcaddu12i;

assign add      = (inst[31:15] == 17'b0000_0000_0001_0000_0);
assign addi     = (inst[31:22] == 10'b0000_0010_10);
assign sub      = (inst[31:15] == 17'b0000_0000_0001_0001_0);
assign slt      = (inst[31:15] == 17'b0000_0000_0001_0010_0);
assign sltu     = (inst[31:15] == 17'b0000_0000_0001_0010_1);
assign i_and    = (inst[31:15] == 17'b0000_0000_0001_0100_1);
assign i_or     = (inst[31:15] == 17'b0000_0000_0001_0101_0);
assign i_xor    = (inst[31:15] == 17'b0000_0000_0001_0101_1);
assign sll      = (inst[31:15] == 17'b0000_0000_0001_0111_0);
assign srl      = (inst[31:15] == 17'b0000_0000_0001_0111_1);
assign sra      = (inst[31:15] == 17'b0000_0000_0001_1000_0);
assign slli     = (inst[31:15] == 17'b0000_0000_0100_0000_1);
assign srli     = (inst[31:15] == 17'b0000_0000_0100_0100_1);
assign srai     = (inst[31:15] == 17'b0000_0000_0100_1000_1);
assign slti     = (inst[31:22] == 10'b0000_0010_00);
assign sltui    = (inst[31:22] == 10'b0000_0010_01);
assign andi     = (inst[31:22] == 10'b0000_0011_01);
assign ori      = (inst[31:22] == 10'b0000_0011_10);
assign xori     = (inst[31:22] == 10'b0000_0011_11);
assign lu12i    = (inst[31:25] ==  7'b0001_010);
assign pcaddu12i= (inst[31:25] ==  7'b0001_110);

assign alu_op = (5'b00000 & { 5{add     | addi  | pcaddu12i | jump | sl} })  //ADD
            |   (5'b00010 & { 5{sub} })             //SUB
            |   (5'b00100 & { 5{slt     | slti} })  //SLT
            |   (5'b00101 & { 5{sltu    | sltui} }) //SLTU
            |   (5'b01001 & { 5{i_and   | andi} })  //AND
            |   (5'b01010 & { 5{i_or    | ori} })   //OR
            |   (5'b01011 & { 5{i_xor   | xori} })  //XOR
            |   (5'b01110 & { 5{sll     | slli} })  //SLL
            |   (5'b01111 & { 5{srl     | srli} })  //SRL
            |   (5'b10000 & { 5{sra     | srai} })  //SRA
            //|   (5'b10001 & { 5{(inst[31:15] == 17'b0000_0000_0001_0001_0)} })  //SRC0
            |   (5'b10010 & { 5{lu12i} }); //SRC1

assign rf_wa  = bl   ?  5'b00001 : inst[ 4: 0];
assign rf_ra0 = inst[ 9: 5];
assign rf_ra1 = (jump|sl) ? inst[ 4: 0] : inst[14:10];
assign rf_we  = (inst != 32'H8000_0000) & (!(jump|stb|sth|stw) | jirl | bl);

assign imm = ({{21{inst[21]}}, inst[20:10]} & {32{addi | slti | sltui | sl}})
        |    ({{20'b0},        inst[21:10]} & {32{andi | ori  | xori}})
        |    ({{27'b0},        inst[14:10]} & {32{slli | srli | srai}})
        |    ({inst[24: 5], {12'b0}}        & {32{lu12i| pcaddu12i}})
        |    ({{15{inst[25]}}, inst[24:10], 2'b00} & {32{jirl|beq|bne|blt|bge|bltu|bgeu}})
        |    ({{ 5{inst[ 9]}}, inst[8:0], inst[25:10], 2'b00} & {32{b|bl}});

assign alu_src0_sel = (~|inst[31:28]) | sl | jirl;//add | addi | sub | slt | sltu | i_and | i_or | i_xor | sll | srl | sra | slli | srli | srai |slti | sltui | andi | ori | xori | sl |jirl;
assign alu_src1_sel = (inst[31:20] == 12'b0000_0000_0001);//add | sub | slt | sltu | i_and | i_or | i_xor | sll | srl | sra;
//assign alu_src1_sel = add |        sub | slt | sltu | i_and | i_or | i_xor | sll | srl | sra;


//lab4
wire ldw, ldh, ldb, ldhu, ldbu, stw, sth, stb, jirl, b, bl, beq, bne, blt, bge, bltu, bgeu;
wire jump, sl;
assign jump = inst[30];//jirl|b|bl|beq|bne|blt|bge|bltu|bgeu;
assign sl   = inst[29] & (~inst[30]);//ldb|ldh|ldw|ldbu|ldhu|stb|sth|stw;

assign ldw      = (inst[31:22] == 10'b0010_1000_10);
assign ldh      = (inst[31:22] == 10'b0010_1000_01);
assign ldb      = (inst[31:22] == 10'b0010_1000_00);
assign ldhu     = (inst[31:22] == 10'b0010_1010_01);
assign ldbu     = (inst[31:22] == 10'b0010_1010_00);
assign stw      = (inst[31:22] == 10'b0010_1001_10);
assign sth      = (inst[31:22] == 10'b0010_1001_01);
assign stb      = (inst[31:22] == 10'b0010_1001_00);

assign jirl     = (inst[31:26] ==  6'b0100_11);//3
assign b        = (inst[31:26] ==  6'b0101_00);//4
assign bl       = (inst[31:26] ==  6'b0101_01);//5
assign beq      = (inst[31:26] ==  6'b0101_10);
assign bne      = (inst[31:26] ==  6'b0101_11);
assign blt      = (inst[31:26] ==  6'b0110_00);
assign bge      = (inst[31:26] ==  6'b0110_01);
assign bltu     = (inst[31:26] ==  6'b0110_10);
assign bgeu     = (inst[31:26] ==  6'b0110_11);//11

assign br_type  = (inst[29:26] & {4{inst[30]}});
assign dmem_access = inst[25:22] & {4{sl}};
assign rf_wd_sel = ((2'b01 & {2{(~|inst[31:28])|lu12i|pcaddu12i}}))//add|addi|sub|slt|sltu|i_and|i_or|i_xor|sll|srl|sra|slli|srli|srai|slti|sltui|andi|ori|xori|lu12i|pcaddu12i
                |  ((2'b10 & {2{(~inst[30]) &inst[29] & (~inst[24])}}));//ldb|ldh|ldw|ldbu|ldhu

endmodule
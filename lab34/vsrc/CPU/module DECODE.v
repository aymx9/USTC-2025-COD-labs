module DECODER (
    input                   [31 : 0]            inst,

    output      reg            [ 4 : 0]            alu_op,
    output      reg            [31 : 0]            imm,

    output      reg            [ 4 : 0]             rf_ra0,
    output      reg           [ 4 : 0]              rf_ra1,
    output      reg          [ 4 : 0]               rf_wa,
    output      reg            [ 0 : 0]             rf_we,

    output      reg            [ 0 : 0]            alu_src0_sel,
    output      reg            [ 0 : 0]            alu_src1_sel,

    output      reg            [ 3 : 0]            dmem_access,//内存访问类型
    output      reg            [ 1 : 0]            rd_wd_sel,//0:pc+4,1:alu,2:mem,寄存器堆写入数据选择
    output      reg            [ 3 : 0]            br_type,//
    output      reg            [ 0 : 0]            dmem_we//是否写内存
);

always @(*)begin
    // Reset outputs
    alu_op = 5'b00000;
    imm = 32'b0;
    rf_ra0 = inst[9:5];
    rf_ra1 = inst[14:10];
    rf_wa = inst[4:0];
    rf_we = 1'b0;
    alu_src0_sel = 1'b0;
    alu_src1_sel = 1'b0;

     
    casez(inst[31:15])
        17'b00000000000100000:begin //add.w
            alu_op = 5'b00000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;//选寄存器
            alu_src1_sel = 1'b0;//选寄存器
            imm = 32'b0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end
        17'b0000000000100010:begin//sub.w
            alu_op = 5'b00010;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end
        
        17'b00000000000100100:begin//slt.w
            alu_op = 5'b00100;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end
        
        17'b00000000000100101:begin//sltu.w
            alu_op = 5'b00101;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存

        end

        17'b00000000000101001:begin//and.w
            alu_op = 5'b01001;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b00000000000101010:begin//or.w
            alu_op = 5'b01010;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b00000000000101011:begin//xor.w
            alu_op = 5'b01011;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b00000000000101110:begin//sll.w
            alu_op = 5'b01110;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b00000000000101111:begin//srl.w
            alu_op = 5'b01111;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b00000000000110000:begin//sra.w
            alu_op = 5'b10000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b0;
            imm = 32'd0;
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b0000001010???????:begin//addi.w,
            alu_op = 5'b00000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;//imm
            //立即数进行符号位扩展
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end 
        17'b0000001000???????:begin//slti
            alu_op = 5'b00100;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;
            //立即数进行符号位扩展
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b0000001001???????:begin//sltiu
            alu_op = 5'b00101;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;
            //立即数进行符号位扩展
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b0000001101???????:begin//andi
            alu_op = 5'b01001;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;
            //立即数进行0扩展
            imm = {{20{1'b0}},inst[21:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b0000001110???????:begin//ori
            alu_op = 5'b01010;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;
            //立即数进行0扩展
            imm = {{20{1'b0}},inst[21:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b0000001111???????:begin//xori
            alu_op = 5'b01011;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;
            //立即数进行0扩展
            imm = {{20{1'b0}},inst[21:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b00000000010000001:begin//slli.w
            alu_op = 5'b01110;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;
            //ui5
            imm = {{27{1'b0}},inst[14:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b00000000010001001:begin//srli.w
            alu_op = 5'b01111;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;
            //ui5
            imm = {{27{1'b0}},inst[14:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b00000000010010001:begin//srai.w
            alu_op = 5'b10000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;
            alu_src1_sel = 1'b1;
            //ui5
            imm = {{27{1'b0}},inst[14:10]};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b0001010??????????:begin//lu12i.w
            alu_op = 5'b10010;
            rf_we = 1'b1;
            alu_src0_sel = 1'b0;
            alu_src1_sel = 1'b1;//imm
            imm = {inst[24:5],{12{1'b0}}};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b0001110??????????:begin//pcaddu12i
            alu_op = 5'b00000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            imm = {inst[24:5],{12{1'b0}}};
            dmem_access = 4'h8;//NONE
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b01;//alu
            dmem_we = 1'b0;//不写内存
        end

        17'b0010100010???????:begin//ld.w
            alu_op = 5'b00000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h0;//LDW
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b10;//mem
            dmem_we = 1'b0;//不写内存

        end

        17'b0010100001???????:begin//ld.h
            alu_op = 5'b00000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h2;//LDH
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b10;//mem
            dmem_we = 1'b0;//不写内存
        end

        17'b0010100000???????:begin//ld.b
            alu_op = 5'b00000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h4;//LDB
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b10;//mem
            dmem_we = 1'b0;//不写内存
        end

        17'b0010101001???????:begin//ld.hu
            alu_op = 5'b00000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h6;//LDHU
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b10;//mem
            dmem_we = 1'b0;//不写内存         
        end

        17'b0010101000???????:begin//ld.bu
            alu_op = 5'b00000;
            rf_we = 1'b1;
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h7;//LDBU
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b10;//mem
            dmem_we = 1'b0;//不写内存
        end

        17'b0010100110???????:begin//st.w
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            rf_we = 1'b0;
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h1;//STW
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b1;//写内存
        end

        17'b0010100101???????:begin//st.h
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            rf_we = 1'b0;
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h3;//STH
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b1;//写内存
        end

        17'b0010100100???????:begin//st.b
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            rf_we = 1'b0;
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            imm = {{20{inst[21]}},inst[21:10]};
            dmem_access = 4'h5;//STB
            br_type = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b1;//写内存
        end

        17'b010011???????????:begin//jirl
            alu_op = 5'b00000;//rj+imm
            imm = {{14{inst[25]}}, inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b1;//ra0
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h6;//JIRL
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b00;//pc+4
            dmem_we = 1'b0;//不写内存
            if(rf_wa ==5'b00000)
                rf_we = 1'b0;//不写寄存器,非调用跳转
            else
                rf_we = 1'b1;//写寄存器
        end

        17'b010100???????????:begin//b
            alu_op = 5'b00000;
            imm = {{4{inst[9]}}, inst[9:0],inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h6;//B
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b0;//不写内存
            rf_we = 1'b0;//不写寄存器   
        end

        17'b010101???????????:begin//bl
            alu_op = 5'b00000;
            rf_wa = 5'b00001;//写回一号寄存器
            imm = {{4{inst[9]}}, inst[9:0],inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h6;//BL
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b00;//pc+4
            dmem_we = 1'b0;//不写内存
            rf_we = 1'b1;//写寄存器
        end

        17'b010110???????????:begin//beq
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            imm = {{14{inst[25]}}, inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h0;//BEQ
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b0;//不写内存
            rf_we = 1'b0;//不写寄存器
            
        end

        17'b010111???????????:begin//bne
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            imm = {{14{inst[25]}}, inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h5;//BNE
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b0;//不写内存
            rf_we = 1'b0;//不写寄存器
        end

        17'b011000???????????:begin//blt
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            imm = {{14{inst[25]}}, inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h3;//BLT
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b0;//不写内存
            rf_we = 1'b0;//不写寄存器
        end

        17'b011001???????????:begin//bge
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            imm = {{14{inst[25]}}, inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h1;//BGE
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b0;//不写内存
            rf_we = 1'b0;//不写寄存器
        end


        17'b011011???????????:begin//bgeu
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            imm = {{14{inst[25]}}, inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h2;//BGEU
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b0;//不写内存
            rf_we = 1'b0;//不写寄存器
        end

        17'b011010???????????:begin//bltu
            alu_op = 5'b00000;
            rf_ra1 = inst[4:0];
            imm = {{14{inst[25]}}, inst[25:10], 2'b0};//左移两位后进行符号位扩展
            alu_src0_sel = 1'b0;//pc
            alu_src1_sel = 1'b1;//imm
            br_type = 4'h4;//BLTU
            dmem_access = 4'h8;//NONE
            rd_wd_sel = 2'b11;//none
            dmem_we = 1'b0;//不写内存
            rf_we = 1'b0;//不写寄存器
        end

    endcase
end

endmodule
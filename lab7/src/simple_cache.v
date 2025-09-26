/*
2路组相联Cache
- 块大小：4字（16字节 128位）
- 采用写回写分配策略
- 支持LRU替换策略
*/
module cache #(
    parameter INDEX_WIDTH       = 3,    // Cache索引位宽 2^3=8行
    parameter LINE_OFFSET_WIDTH = 2,    // 行偏移位宽，决定了一行的宽度 2^2=4字
    parameter SPACE_OFFSET      = 2,    // 一个地址空间占1个字节，因此一个字需要4个地址空间，由于假设为整字读取，处理地址的时候可以默认后两位为0
    parameter REPLACE_STRATEGY  = 0,    // 0: LRU, 1: FIFO, 2: RANDOM
    parameter WAY_NUM           = 2
)(
    input                     clk,    
    input                     rstn,  
    /* CPU接口 */  
    input [31:0]              addr,    // CPU地址
    input                     r_req,   // CPU读请求
    input                     w_req,   // CPU写请求
    input [31:0]              w_data,  // CPU写数据
    output [31:0]             r_data,  // CPU读数据
    output reg                miss,    // 缓存未命中
    /* 内存接口 */  
    output reg                     mem_r,       // 内存读请求
    output reg                     mem_w,       // 内存写请求
    output reg [31:0]              mem_addr,    // 内存地址
    output reg [127:0]             mem_w_data,  // 内存写数据 一次写一行
    input      [127:0]             mem_r_data,  // 内存读数据 一次读一行
    input                          mem_ready    // 内存就绪信号
);

    // Cache参数
    localparam
        // Cache行宽度
        LINE_WIDTH = 32 << LINE_OFFSET_WIDTH,
        // 标记位宽度
        TAG_WIDTH = 32 - INDEX_WIDTH - LINE_OFFSET_WIDTH - SPACE_OFFSET,
        // Cache行数
        SET_NUM   = 1 << INDEX_WIDTH,
        // 替换LRU计数器宽度
        REPLACE_COUNTER_WIDTH = 1;  // 2路只需要1位

    integer i;
    
    // Cache相关寄存器
    reg [31:0]           addr_buf;    // 请求地址缓存-用于保留CPU请求地址
    reg [31:0]           w_data_buf;  // 写数据缓存
    reg                  op_buf;      // 读写操作缓存，用于在MISS状态下判断是读还是写，如果是写则需要将数据写回内存 0:读 1:写
    reg [LINE_WIDTH-1:0] ret_buf;     // 返回数据缓存-用于保留内存返回数据

    // 替换策略相关寄存器
    reg [REPLACE_COUNTER_WIDTH-1:0] fifo_counter [0:SET_NUM-1]; // FIFO计数器
    reg [1:0] lru_counter [0:SET_NUM-1];  // LRU计数器 (2位足够)
    reg [31:0] rand_seed;                                       // 伪随机数种子

    // Cache导线
    wire [INDEX_WIDTH-1:0] r_index;  // 索引读地址
    wire [INDEX_WIDTH-1:0] w_index;  // 索引写地址
    wire [LINE_WIDTH-1:0]  r_line [0:1];   // Data Bram读数据 (2路)
    wire [LINE_WIDTH-1:0]  w_line [0:1];   // Data Bram写数据 (2路)
    wire [LINE_WIDTH-1:0]  w_line_mask;  // Data Bram写数据掩码
    wire [LINE_WIDTH-1:0]  w_data_line;  // 输入写数据移位后的数据
    wire [TAG_WIDTH-1:0]   tag;      // CPU请求地址中分离的标记 用于比较 也可用于写入
    wire [TAG_WIDTH-1:0]   r_tag [0:1];    // Tag Bram读数据 用于比较 (2路)
    wire [LINE_OFFSET_WIDTH-1:0] word_offset;  // 字偏移
    reg  [31:0]            cache_data [0:1];  // Cache数据 (2路)
    reg  [31:0]            mem_data;    // 内存数据
    wire [31:0]            dirty_mem_addr [0:1]; // 通过读出的tag和对应的index，偏移等得到脏块对应的内存地址并写回到正确的位置
    wire valid [0:1];  // Cache有效位 (2路)
    wire dirty [0:1];  // Cache脏位 (2路)
    reg [0:1] w_valid;  // Cache写有效位 (2路)
    reg [0:1] w_dirty;  // Cache写脏位 (2路)
    wire [0:1] hit;    // Cache命中 (2路)
    wire any_hit;
    wire [0:1] empty;

    // Cache相关控制信号
    reg addr_buf_we;  // 请求地址缓存写使能
    reg ret_buf_we;   // 返回数据缓存写使能
    reg [0:1] data_we;      // Cache写使能 (2路)
    reg [0:1] tag_we;       // Cache标记写使能 (2路)
    reg data_from_mem;  // 从内存读取数据
    reg refill;       // 标记需要重新填充，在MISS状态下接受到内存数据后置1,在IDLE状态下进行填充后置0
    reg [0:1] way_select;

    // 状态机信号
    localparam 
        IDLE      = 3'd0,  // 空闲状态
        READ      = 3'd1,  // 读状态
        MISS      = 3'd2,  // 缺失时等待主存读出新块
        WRITE     = 3'd3,  // 写状态
        W_DIRTY   = 3'd4;  // 写缺失时等待主存写入脏块
    reg [2:0] CS;  // 状态机当前状态
    reg [2:0] NS;  // 状态机下一状态

    // 状态机
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            CS <= IDLE;
        end else begin
            CS <= NS;
        end
    end

    // 中间寄存器保留初始的请求地址和写数据
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            addr_buf <= 0;
            ret_buf <= 0;
            w_data_buf <= 0;
            op_buf <= 0;
            refill <= 0;
            rand_seed <= 32'h12345678;
            for (i=0;i<SET_NUM;i=i+1)begin
                fifo_counter[i]<=0;
                lru_counter[i]<=0;
            end
        end else begin
            // 伪随机数生成
            rand_seed <= rand_seed ^ (rand_seed << 13);
            rand_seed <= rand_seed ^ (rand_seed >> 17);
            rand_seed <= rand_seed ^ (rand_seed << 5);

            if (addr_buf_we) begin
                addr_buf <= addr;
                w_data_buf <= w_data;
                op_buf <= w_req;
            end
            if (ret_buf_we) begin
                ret_buf <= mem_r_data;
            end
            if (CS == MISS && mem_ready) begin
                refill <= 1;
            end
            if (CS == IDLE) begin
                refill <= 0;
            end
            
            //更新FIFO计数器
            if (CS == IDLE && refill)begin
                if(REPLACE_STRATEGY == 1)begin
                    fifo_counter[w_index]<=fifo_counter[w_index]+1;
                    if (fifo_counter[w_index] == 1) begin  // 2路只需要0和1
                        fifo_counter[w_index] <= 0;
                    end
                end
            end

            if (any_hit && (CS == READ || CS == WRITE))begin
                if (REPLACE_STRATEGY == 0) begin
                    // 更新LRU计数器
                    if(hit[0])begin
                        lru_counter[w_index][0] <= 0;
                        lru_counter[w_index][1] <= 1;
                    end
                    else if(hit[1])begin
                        lru_counter[w_index][0] <= 1;
                        lru_counter[w_index][1] <= 0;
                    end
                end
            end 
        end
    end

    // 对输入地址进行解码
    assign r_index = addr[INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET - 1: LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign w_index = addr_buf[INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET - 1: LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign tag = addr_buf[31:INDEX_WIDTH+LINE_OFFSET_WIDTH+SPACE_OFFSET];
    assign word_offset = addr_buf[LINE_OFFSET_WIDTH+SPACE_OFFSET-1:SPACE_OFFSET];

    // 脏块地址计算
    assign dirty_mem_addr[0] = {r_tag[0], w_index} << (LINE_OFFSET_WIDTH+SPACE_OFFSET);
    assign dirty_mem_addr[1] = {r_tag[1], w_index} << (LINE_OFFSET_WIDTH+SPACE_OFFSET);

    // 写回地址、数据寄存器
    reg [31:0] dirty_mem_addr_buf;
    reg [127:0] dirty_mem_data_buf;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dirty_mem_addr_buf <= 0;
            dirty_mem_data_buf <= 0;
        end else begin
            if (CS == READ || CS == WRITE) begin
                if (way_select[0])begin
                    dirty_mem_addr_buf <= dirty_mem_addr[0];
                    dirty_mem_data_buf <= r_line[0];
                end
                else if (way_select[1])begin
                    dirty_mem_addr_buf <= dirty_mem_addr[1];
                    dirty_mem_data_buf <= r_line[1];
                end
            end
        end
    end

    // 生成2路Tag和Data BRAM
    // 第0路
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2) // 最高位为有效位，次高位为脏位，低位为标记位
    ) tag_bram_0(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid[0], w_dirty[0], tag}),
        .we(tag_we[0]),
        .dout({valid[0], dirty[0], r_tag[0]})
    );

    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_0(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line[0]),
        .we(data_we[0]),
        .dout(r_line[0])
    );
    
    // 第1路
    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(TAG_WIDTH + 2)
    ) tag_bram_1(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din({w_valid[1], w_dirty[1], tag}),
        .we(tag_we[1]),
        .dout({valid[1], dirty[1], r_tag[1]})
    );

    bram #(
        .ADDR_WIDTH(INDEX_WIDTH),
        .DATA_WIDTH(LINE_WIDTH)
    ) data_bram_1(
        .clk(clk),
        .raddr(r_index),
        .waddr(w_index),
        .din(w_line[1]),
        .we(data_we[1]),
        .dout(r_line[1])
    );

    // 判定Cache是否命中
    assign hit[0] = valid[0] && (r_tag[0] == tag);
    assign hit[1] = valid[1] && (r_tag[1] == tag);
    assign any_hit = hit[0] | hit[1];

    // 检查空路
    assign empty[0] = ~valid[0];
    assign empty[1] = ~valid[1];

    // 替换策略选择
    always @(*) begin
        way_select = 2'b00;
        if (any_hit) begin
            way_select = hit;
        end else begin
            case (REPLACE_STRATEGY)
                0: begin // LRU
                    // 查找优先级最低的路
                    if (lru_counter[w_index][0] > lru_counter[w_index][1]) begin
                        way_select = 2'b10; // 选择第1路
                    end else begin
                        way_select = 2'b01; // 选择第0路
                    end
                end
                1: begin // FIFO
                    way_select = (fifo_counter[w_index] == 0) ? 2'b01 : 2'b10;
                end
                2: begin // RANDOM
                    way_select = (rand_seed[1] == 0) ? 2'b01 : 2'b10;
                end
                default: begin // 默认LRU
                    if (lru_counter[w_index][0] > lru_counter[w_index][1]) begin
                        way_select = 2'b10;
                    end else begin
                        way_select = 2'b01;
                    end
                end
            endcase
            
            // 优先选择空路
            if (empty[0]) begin
                way_select = 2'b01;
            end else if (empty[1]) begin
                way_select = 2'b10;
            end
        end
    end

    // 写入Cache
    assign w_line_mask = 32'hFFFFFFFF << (word_offset*32);   // 写入数据掩码
    assign w_data_line = w_data_buf << (word_offset*32);     // 写入数据移位
    
    // 第0路写数据
    assign w_line[0] = (CS == IDLE && op_buf && way_select[0]) ? ret_buf & ~w_line_mask | w_data_line : // 写入未命中
                      (CS == IDLE && way_select[0]) ? ret_buf : // 读取未命中
                      (CS == WRITE && way_select[0]) ? r_line[0] & ~w_line_mask | w_data_line : // 写入命中
                      r_line[0]; // 其他情况保持不变
    
    // 第1路写数据
    assign w_line[1] = (CS == IDLE && op_buf && way_select[1]) ? ret_buf & ~w_line_mask | w_data_line : // 写入未命中
                      (CS == IDLE && way_select[1]) ? ret_buf : // 读取未命中
                      (CS == WRITE && way_select[1]) ? r_line[1] & ~w_line_mask | w_data_line : // 写入命中
                      r_line[1]; // 其他情况保持不变

    // 选择输出数据
    always @(*) begin
        // 第0路数据
        case (word_offset)
            0: cache_data[0] = r_line[0][31:0];
            1: cache_data[0] = r_line[0][63:32];
            2: cache_data[0] = r_line[0][95:64];
            3: cache_data[0] = r_line[0][127:96];
            default: cache_data[0] = 0;
        endcase
        
        // 第1路数据
        case (word_offset)
            0: cache_data[1] = r_line[1][31:0];
            1: cache_data[1] = r_line[1][63:32];
            2: cache_data[1] = r_line[1][95:64];
            3: cache_data[1] = r_line[1][127:96];
            default: cache_data[1] = 0;
        endcase
        
        // 内存数据
        case (word_offset)
            0: mem_data = ret_buf[31:0];
            1: mem_data = ret_buf[63:32];
            2: mem_data = ret_buf[95:64];
            3: mem_data = ret_buf[127:96];
            default: mem_data = 0;
        endcase
    end

    // 输出数据选择
    reg [31:0] hit_data;
    always @(*) begin
        hit_data = 0;
        if (hit[0]) begin
            hit_data = cache_data[0];
        end
        else if (hit[1]) begin
            hit_data = cache_data[1];
        end
    end

    assign r_data = data_from_mem ? mem_data : any_hit ? hit_data : 0;
    
    // 检查是否有脏块
    reg has_dirty;
    always @(*) begin
        has_dirty = 1'b0;
        if ((dirty[0] && way_select[0]) || (dirty[1] && way_select[1])) begin
            has_dirty = 1'b1;
        end
    end
    
    // 状态机更新逻辑
    always @(*) begin
        case(CS)
            IDLE: begin
                if (r_req) begin
                    NS = READ;
                end else if (w_req) begin
                    NS = WRITE;
                end else begin
                    NS = IDLE;
                end
            end
            READ: begin
                if (miss && !has_dirty) begin
                    NS = MISS;
                end else if (miss && has_dirty) begin
                    NS = W_DIRTY;
                end else if (r_req) begin
                    NS = READ;
                end else if (w_req) begin
                    NS = WRITE;
                end else begin
                    NS = IDLE;
                end
            end
            MISS: begin
                if (mem_ready) begin
                    NS = IDLE;
                end else begin
                    NS = MISS;
                end
            end
            WRITE: begin
                if (miss && !has_dirty) begin
                    NS = MISS;
                end else if (miss && has_dirty) begin
                    NS = W_DIRTY;
                end else if (r_req) begin
                    NS = READ;
                end else if (w_req) begin
                    NS = WRITE;
                end else begin
                    NS = IDLE;
                end
            end
            W_DIRTY: begin
                if (mem_ready) begin
                    NS = MISS;
                end else begin
                    NS = W_DIRTY;
                end
            end
            default: begin
                NS = IDLE;
            end
        endcase
    end

    // 状态机控制信号
    always @(*) begin
        addr_buf_we   = 1'b0;
        ret_buf_we    = 1'b0;
        data_we       = 2'b00;
        tag_we        = 2'b00;
        w_valid       = 2'b00;
        w_dirty       = 2'b00;
        data_from_mem = 1'b0;
        miss          = 1'b0;
        mem_r         = 1'b0;
        mem_w         = 1'b0;
        mem_addr      = 32'b0;
        mem_w_data    = 0;
        
        case(CS)
            IDLE: begin
                addr_buf_we = 1'b1; // 请求地址缓存写使能
                miss = 1'b0;
                ret_buf_we = 1'b0;
                if(refill) begin
                    data_from_mem = 1'b1;
                    w_valid = way_select;
                    w_dirty = 2'b00;
                    data_we = way_select;
                    tag_we = way_select;
                    if (op_buf) begin // 写
                        w_dirty = way_select;
                    end 
                end
            end
            READ: begin
                data_from_mem = 1'b0;
                if (any_hit) begin // 命中
                    miss = 1'b0;
                    addr_buf_we = 1'b1; // 请求地址缓存写使能
                end else begin // 未命中
                    miss = 1'b1;
                    addr_buf_we = 1'b0; 
                    if (has_dirty) begin // 脏数据需要写回
                        mem_w = 1'b1;
                        if (way_select[0]) begin
                            mem_addr = dirty_mem_addr[0];
                            mem_w_data = r_line[0];
                        end else if (way_select[1]) begin
                            mem_addr = dirty_mem_addr[1];
                            mem_w_data = r_line[1];
                        end
                    end
                end
            end
            MISS: begin
                miss = 1'b1;
                mem_r = 1'b1;
                mem_addr = addr_buf;
                if (mem_ready) begin
                    mem_r = 1'b0;
                    ret_buf_we = 1'b1;
                end 
            end
            WRITE: begin
                data_from_mem = 1'b0;
                if (any_hit) begin // 命中
                    miss = 1'b0;
                    addr_buf_we = 1'b1; // 请求地址缓存写使能
                    w_valid = way_select;
                    w_dirty = way_select;
                    data_we = way_select;
                    tag_we = way_select;
                end else begin // 未命中
                    miss = 1'b1;
                    addr_buf_we = 1'b0; 
                    if (has_dirty) begin // 脏数据需要写回
                        mem_w = 1'b1;
                        if (way_select[0]) begin
                            mem_addr = dirty_mem_addr[0];
                            mem_w_data = r_line[0];
                        end else if (way_select[1]) begin
                            mem_addr = dirty_mem_addr[1];
                            mem_w_data = r_line[1];
                        end
                    end
                end
            end
            W_DIRTY: begin
                miss = 1'b1;
                mem_w = 1'b1;
                mem_addr = dirty_mem_addr_buf;
                mem_w_data = dirty_mem_data_buf;
                if (mem_ready) begin
                    mem_w = 1'b0;
                end
            end
            default:;
        endcase
    end

endmodule
module mips (
        input wire debug_en,  // debug enable
        input wire debug_step,  // debug step clock
        input wire [6:0] debug_addr,  // debug address
        output wire [31:0] debug_data,  // debug data
        input wire clk,  // main clock
        input wire rst  // synchronous reset
        );

// debug control
reg cpu_en;
reg if_rst, if_CE, id_rst, id_CE, ex_rst, ex_CE, mem_rst, mem_CE, wb_rst, wb_CE;

// IfStage Outputs     
wire  [31:0]  if_pc;   
wire  [31:0]  if_pc_p4;
wire  [31:0]  if_inst; 
wire  if_stall;        

// IdStage Outputs     
wire  [31:0]  id_target;
wire  id_BRANCH;
wire  [4:0]  id_rs;
wire  [4:0]  id_rt;
wire  [31:0]  id_debug_data;
wire  [31:0]  id_Q1;
wire  [31:0]  id_Q2;
wire  [1:0]  id_FWDA;
wire  [1:0]  id_FWDB;
wire  id_FQ1_stall;
wire  id_FQ2_stall;
wire  id_stall;
wire  [31:0]  id_FQ1;
wire  [31:0]  id_FQ2;
wire  [31:0]  id_EXT_imm16;
wire  [2:0]  id_ALU_Ctr;
wire  id_ALUIMM;
wire  id_SHIFT;
wire  id_JAL;
wire  id_LUI;
wire  id_RMEM;
wire  id_WMEM;
wire  [4:0]  id_nd;
wire  id_M2REG;
wire  id_WREG;

// ExStage Outputs
wire  [31:0]  ex_alu_out;
wire  [31:0]  ex_A;
wire  [31:0]  ex_B;

// MemStage Outputs
wire  [31:0]  mem_d;
wire  mem_stall;

// WbStage Outputs
wire  [31:0]  wb_RegDataIn;

// IfIdRegisters Outputs
wire  [31:0]  id_pc_p4;
wire  [31:0]  id_pc;
wire  [31:0]  id_inst;

// IdExRegisters Outputs
wire  ex_WMEM;
wire  ex_WREG;
wire  [31:0]  ex_pc;
wire  ex_JAL;
wire  ex_M2REG;
wire  [31:0]  ex_FQ1;
wire  ex_LUI;
wire  [2:0]  ex_ALU_Ctr;
wire  ex_SHIFT;
wire  [31:0]  ex_inst;
wire  ex_ALUIMM;
wire  [31:0]  ex_pc_p4;
wire  [4:0]  ex_nd;
wire  ex_RMEM;
wire  [31:0]  ex_EXT_imm16;
wire  [31:0]  ex_FQ2;

// ExMemRegisters Outputs
wire  mem_WMEM;
wire  mem_WREG;
wire  [31:0]  mem_pc;
wire  mem_M2REG;
wire  [31:0]  mem_inst;
wire  [31:0]  mem_alu_out;
wire  [4:0]  mem_nd;
wire  mem_RMEM;
wire  [31:0]  mem_FQ2;

// MemWbRegisters Outputs
wire  wb_WREG;
wire  [31:0]  wb_pc;
wire  [31:0]  wb_alu_out;
wire  wb_M2REG;
wire  [4:0]  wb_nd;
wire  [31:0]  wb_d;
wire  [31:0]  wb_inst;

IfStage  u_IfStage (
    .clk                     ( clk         ),
    .rst                     ( if_rst         ),
    .id_target               ( id_target   ),
    .id_BRANCH               ( id_BRANCH   ),
    .CE                      ( if_CE          ),

    .pc                      ( if_pc          ),
    .pc_p4                   ( if_pc_p4       ),
    .inst                    ( if_inst        ),
    .stall                   ( if_stall       )
);

IdStage  u_IdStage (
    .clk                     ( clk            ),
    .inst                    ( id_inst           ),
    .pc_p4                   ( id_pc_p4          ),
    .debug_addr              ( id_debug_addr     ),
    .ex_WREG                 ( ex_WREG        ),
    .ex_nd                   ( ex_nd          ),
    .ex_M2REG                ( ex_M2REG       ),
    .ex_alu_out              ( ex_alu_out     ),
    .mem_WREG                ( mem_WREG       ),
    .mem_nd                  ( mem_nd         ),
    .mem_M2REG               ( mem_M2REG      ),
    .mem_alu_out             ( mem_alu_out    ),
    .mem_d                   ( mem_d          ),
    .wb_nd                   ( wb_nd          ),
    .wb_RegDataIn            ( wb_RegDataIn   ),
    .wb_WREG                 ( wb_WREG        ),

    .target                  ( id_target         ),
    .BRANCH                  ( id_BRANCH         ),
    .rs                      ( id_rs             ),
    .rt                      ( id_rt             ),
    .debug_data              ( id_debug_data     ),
    .Q1                      ( id_Q1             ),
    .Q2                      ( id_Q2             ),
    .FWDA                    ( id_FWDA           ),
    .FWDB                    ( id_FWDB           ),
    .FQ1_stall               ( id_FQ1_stall      ),
    .FQ2_stall               ( id_FQ2_stall      ),
    .stall                   ( id_stall          ),
    .FQ1                     ( id_FQ1            ),
    .FQ2                     ( id_FQ2            ),
    .EXT_imm16               ( id_EXT_imm16      ),
    .ALU_Ctr                 ( id_ALU_Ctr        ),
    .ALUIMM                  ( id_ALUIMM         ),
    .SHIFT                   ( id_SHIFT          ),
    .JAL                     ( id_JAL            ),
    .LUI                     ( id_LUI            ),
    .RMEM                    ( id_RMEM           ),
    .WMEM                    ( id_WMEM           ),
    .nd                      ( id_nd             ),
    .M2REG                   ( id_M2REG          ),
    .WREG                    ( id_WREG           )
);

ExStage  u_ExStage (
    .FQ1                     ( ex_FQ1         ),
    .FQ2                     ( ex_FQ2         ),
    .EXT_imm16               ( ex_EXT_imm16   ),
    .SHIFT                   ( ex_SHIFT       ),
    .ALUIMM                  ( ex_ALUIMM      ),
    .ALU_Ctr                 ( ex_ALU_Ctr     ),
    .pc_p4                   ( ex_pc_p4       ),
    .JAL                     ( ex_JAL         ),
    .inst                    ( ex_inst        ),
    .LUI                     ( ex_LUI         ),

    .alu_out                 ( ex_alu_out     ),
    .A                       ( ex_A           ),
    .B                       ( ex_B           )
);

MemStage  u_MemStage (
    .clk                     ( clk       ),
    .alu_out                 ( mem_alu_out   ),
    .FQ2                     ( mem_FQ2       ),
    .WMEM                    ( mem_WMEM      ),
    .RMEM                    ( mem_RMEM      ),

    .d                       ( mem_d         ),
    .stall                   ( mem_stall     )
);

WbStage  u_WbStage (
    .alu_out                 ( wb_alu_out     ),
    .d                       ( wb_d           ),
    .M2REG                   ( wb_M2REG       ),
    .inst                    ( wb_inst        ),
    .pc                      ( wb_pc          ),

    .RegDataIn               ( wb_RegDataIn   )
);

IfIdRegisters  u_IfIdRegisters (
    .clk                     ( clk        ),
    .rst                     ( id_rst        ),
    .CE                      ( id_CE         ),
    .if_pc_p4                ( if_pc_p4   ),
    .if_pc                   ( if_pc      ),
    .if_inst                 ( if_inst    ),

    .id_pc_p4                ( id_pc_p4   ),
    .id_pc                   ( id_pc      ),
    .id_inst                 ( id_inst    )
);

IdExRegisters  u_IdExRegisters (
    .clk                     ( clk            ),
    .rst                     ( ex_rst            ),
    .CE                      ( ex_CE             ),
    .id_WMEM                 ( id_WMEM        ),
    .id_WREG                 ( id_WREG        ),
    .id_pc                   ( id_pc          ),
    .id_JAL                  ( id_JAL         ),
    .id_M2REG                ( id_M2REG       ),
    .id_FQ1                  ( id_FQ1         ),
    .id_LUI                  ( id_LUI         ),
    .id_ALU_Ctr              ( id_ALU_Ctr     ),
    .id_SHIFT                ( id_SHIFT       ),
    .id_inst                 ( id_inst        ),
    .id_ALUIMM               ( id_ALUIMM      ),
    .id_pc_p4                ( id_pc_p4       ),
    .id_nd                   ( id_nd          ),
    .id_RMEM                 ( id_RMEM        ),
    .id_EXT_imm16            ( id_EXT_imm16   ),
    .id_FQ2                  ( id_FQ2         ),

    .ex_WMEM                 ( ex_WMEM        ),
    .ex_WREG                 ( ex_WREG        ),
    .ex_pc                   ( ex_pc          ),
    .ex_JAL                  ( ex_JAL         ),
    .ex_M2REG                ( ex_M2REG       ),
    .ex_FQ1                  ( ex_FQ1         ),
    .ex_LUI                  ( ex_LUI         ),
    .ex_ALU_Ctr              ( ex_ALU_Ctr     ),
    .ex_SHIFT                ( ex_SHIFT       ),
    .ex_inst                 ( ex_inst        ),
    .ex_ALUIMM               ( ex_ALUIMM      ),
    .ex_pc_p4                ( ex_pc_p4       ),
    .ex_nd                   ( ex_nd          ),
    .ex_RMEM                 ( ex_RMEM        ),
    .ex_EXT_imm16            ( ex_EXT_imm16   ),
    .ex_FQ2                  ( ex_FQ2         )
);

ExMemRegisters  u_ExMemRegisters (
    .clk                     ( clk           ),
    .rst                     ( mem_rst           ),
    .CE                      ( mem_CE            ),
    .ex_WMEM                 ( ex_WMEM       ),
    .ex_WREG                 ( ex_WREG       ),
    .ex_pc                   ( ex_pc         ),
    .ex_M2REG                ( ex_M2REG      ),
    .ex_inst                 ( ex_inst       ),
    .ex_alu_out              ( ex_alu_out    ),
    .ex_nd                   ( ex_nd         ),
    .ex_RMEM                 ( ex_RMEM       ),
    .ex_FQ2                  ( ex_FQ2        ),

    .mem_WMEM                ( mem_WMEM      ),
    .mem_WREG                ( mem_WREG      ),
    .mem_pc                  ( mem_pc        ),
    .mem_M2REG               ( mem_M2REG     ),
    .mem_inst                ( mem_inst      ),
    .mem_alu_out             ( mem_alu_out   ),
    .mem_nd                  ( mem_nd        ),
    .mem_RMEM                ( mem_RMEM      ),
    .mem_FQ2                 ( mem_FQ2       )
);

MemWbRegisters  u_MemWbRegisters (
    .clk                     ( clk           ),
    .rst                     ( wb_rst           ),
    .CE                      ( wb_CE            ),
    .mem_WREG                ( mem_WREG      ),
    .mem_pc                  ( mem_pc        ),
    .mem_alu_out             ( mem_alu_out   ),
    .mem_M2REG               ( mem_M2REG     ),
    .mem_nd                  ( mem_nd        ),
    .mem_d                   ( mem_d         ),
    .mem_inst                ( mem_inst      ),

    .wb_WREG                 ( wb_WREG       ),
    .wb_pc                   ( wb_pc         ),
    .wb_alu_out              ( wb_alu_out    ),
    .wb_M2REG                ( wb_M2REG      ),
    .wb_nd                   ( wb_nd         ),
    .wb_d                    ( wb_d          ),
    .wb_inst                 ( wb_inst       )
);

// step posedge detection
reg debug_step_prev;
always @(posedge clk) begin
        debug_step_prev <= debug_step;
end
// step exec
always @(*) begin
        if (debug_en & ~(~debug_step_prev & debug_step)) begin
                cpu_en = 0;
    end else begin
        cpu_en = 1;
    end
end
// comprehensive pp. flow control
always @(*) begin
    // normal execution
    {if_rst, id_rst, ex_rst, mem_rst, wb_rst} = 0;
    {if_CE, id_CE, ex_CE, mem_CE, wb_CE} = -1;
    // highest prio
    if (rst)
        {if_rst, id_rst, ex_rst, mem_rst, wb_rst} = -1;
    else if (~cpu_en) begin
        {if_CE, id_CE, ex_CE, mem_CE, wb_CE} = 0;
    end
    // process stall from last stage
    else begin
        if (mem_stall) begin
            wb_rst = -1;
            {if_CE, id_CE, ex_CE, mem_CE} = 0;
        end
        else if (id_stall) begin
            ex_rst = -1;
            {if_CE, id_CE} = 0;
        end
        // no stalls other than if_stall;
        else begin
            if (id_BRANCH) begin
                id_rst = -1;
            end
            else if (if_stall) begin
                id_rst = -1;
                if_CE = 0;
            end
        end
    end
end

reg [31:0] debug_data_signal;

always @(*) begin
    case (debug_addr[4:0])
        0: debug_data_signal = if_pc;
        1: debug_data_signal = if_inst;
        2: debug_data_signal = id_pc;
        3: debug_data_signal = id_inst;
        4: debug_data_signal = ex_pc;
        5: debug_data_signal = ex_inst;
        6: debug_data_signal = mem_pc;
        7: debug_data_signal = mem_inst;
        8: debug_data_signal = id_rs;
        9: debug_data_signal = id_Q1;
        10: debug_data_signal = id_rt;
        11: debug_data_signal = id_Q2;
        12: debug_data_signal = id_EXT_imm16;
        13: debug_data_signal = ex_A;
        14: debug_data_signal = ex_B;
        15: debug_data_signal = ex_alu_out;
        16: debug_data_signal = 0;
        17: debug_data_signal = {15'b0, id_stall, 3'b0, id_FQ1_stall, 3'b0, id_FQ2_stall, 2'b0, id_FWDA, 2'b0, id_FWDB};
        18: debug_data_signal = {19'b0, mem_stall, 7'b0, mem_RMEM, 3'b0, mem_WMEM};
        19: debug_data_signal = mem_alu_out;
        20: debug_data_signal = mem_d;
        21: debug_data_signal = mem_FQ2;
        22: debug_data_signal = wb_nd;
        23: debug_data_signal = wb_RegDataIn;
        default: debug_data_signal = 32'hFFFF_FFFF;
    endcase
end

assign
    debug_data = debug_addr[6] ? 'b0 :
                debug_addr[5] ? debug_data_signal : id_debug_data;

endmodule

// TODO
//! debugger disengaged
// *Registers.rst(  )
// *Registers.CE(  )
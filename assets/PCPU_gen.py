"""Instantiate 5+4 modules, declare and connect wires and debug signals, to generate a PCPU replacing "module mips".

vInstance_Gen是1个VSCode Verilog插件的一部分。本脚本建立在这个自动例化轮子的基础上。
"""

import re
import subprocess
import shlex

# interface+
print(
'''module mips (
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
''')

stages = ['IF', 'ID', 'EX', 'MEM', 'WB']
wire_list = [] # 需要先声明线网，否则报错，SB综合器
instance_list = []

wireRe = re.compile(r'wire((\s*(?P<width>\[\d+:\d+\])\s*)|\s+)(?P<name>\w+);')
connRe = re.compile(r'\.(?P<name>\w+)\s*\(\s*((?P=name))\s*\)')

# stage 要前缀_
for stage in stages:
    args = shlex.split(
        f'python ./PCPU/assets/vInstance_Gen.py ./PCPU/{stage.capitalize()}Stage.v')
    p = subprocess.run(args, stdout=subprocess.PIPE)
    lines = p.stdout.splitlines()
    phase = 'IDLE'
    for line in lines:
        line = line.decode()
        if phase == 'IDLE':
            if re.match(r'//.*Outputs', line):
                phase = 'WIRE'
                wire_list.append(line) 
        elif phase == 'WIRE':
            if not line:
                phase = 'INSTANCE'
            else:
                wireMatch = wireRe.match(line)
                name = wireMatch.group('name')
                line = line.replace(name, f'{stage.lower()}_' + name)
            wire_list.append(line)
        elif phase == 'INSTANCE':
            connMatch = connRe.search(line)
            if connMatch:
                name = connMatch.group('name')
                if name in ['clk', ] or name.startswith(tuple(f'{some.lower()}_' for some in stages)):
                    pass
                else:
                    i = connMatch.start(2)
                    line = line[:i] + line[i:].replace(name, f'{stage.lower()}_' + name)
            instance_list.append(line)
    instance_list.append('')

# registers 按 decl 例化
for i in range(1, len(stages)):
    args = shlex.split(
        f'python ./PCPU/assets/vInstance_Gen.py ./PCPU/{stages[i-1].capitalize()}{stages[i].capitalize()}Registers.v')
    p = subprocess.run(args, stdout=subprocess.PIPE)
    lines = p.stdout.splitlines()
    phase = 'IDLE'
    for line in lines:
        line = line.decode()
        if phase == 'IDLE':
            if re.match(r'//.*Outputs', line):
                phase = 'WIRE'
                wire_list.append(line)
        elif phase == 'WIRE':
            if not line:
                phase = 'INSTANCE'
            wire_list.append(line)
        elif phase == 'INSTANCE':
            instance_list.append(line)
    instance_list.append('')

print('\n'.join(wire_list))
print('\n'.join(instance_list))

# debug & end
print(
'''// step posedge detection
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
// TODO ROM read be restarted with new address in case of id_BRANCH
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

endmodule'''
)
print(
'''
// TODO 
//! debugger disengaged
// *Registers.rst(  )
// *Registers.CE(  )
'''
)

"""Parse the I/O declaration of the 5-stage pipeline CPU to generate 4 registers in between. 

sketch; .md
"""

from functools import partial
from collections import namedtuple
from pprint import pprint
import re

stages = ['IF', 'ID', 'EX', 'MEM', 'WB']
Port = namedtuple('Port', ['direction', 'width', 'name'])
# Port is actually a subclass of Signal

def parse_decl(f):
    ''' Parse I/O declaration in a module file and return a list of ports '''
    f.seek(0, 0)
    portList = []
    portRe = re.compile(
        r'(?P<direction>(input|output))((\s*(?P<width>\[\d+:\d+\])\s*)|\s+)(?P<name>\w+),?.*'
    )  # Python 扩展语法 命名捕获组
    for line in f:
        line = line.strip()
        if line.startswith('module') or line.startswith('//'):
            continue
        elif ');' in line:
            break
        elif line:
            portMatch = portRe.match(line)
            port = Port(**portMatch.groupdict())
            portList.append(port)
    return portList


# Parse *Stage I/O declaration. Special cases excluded from consideration.
# Output: portListDict
portListDict = {}
for stage in stages:
    with open(f'PCPU/{stage.capitalize()}Stage.v') as f:
        portList = [port for port in parse_decl(f) if \
            port.name not in ['clk', 'rst', 'CE', 'debug_addr', 'debug_data']]
        portListDict[stage] = portList

# determine what signal should be available, in Registers before *Stage
# Output: stageSignals

# 1st run: stageSignals[s] = (pipelined through + output) in s
Signal = namedtuple('Signal', ['width', 'name'])
stageSignals = {stage: set() for stage in stages}
ppSignals = set()
# we trace from last stage
for stage in reversed(stages):
    # first, signals asked from stages after
    stageSignals[stage] |= ppSignals
    # traverse port to add signal accordingly
    for port in portListDict[stage]:
        # input of the stage must be satisfied
        if port.direction == 'input':
            # signal forwarded?
            if re.match(f'({"|".join([stage.lower() for stage in stages])})_\\w+', port.name):
                # signal should be available in the stage from which it's forwarded
                portPrefix, signalName = port.name.split('_', maxsplit=1)
                stageSignals[portPrefix.upper()].add(Signal(port.width, signalName))
            else:  # default: this stage
                stageSignals[stage].add(Signal(port.width, port.name))
                # and it should be pipelined here
                ppSignals.add(Signal(port.width, port.name))
        else:
            # port.direction == 'output': found the src of a pipelined signal
            signal = Signal(port.width, port.name)
            ppSignals.discard(signal)

# doing again: consider wb_nd. 
# exclude output of this stage and propagate
# state stable after 2 runs.
ppSignals = set()
for stage in reversed(stages):
    stageOutputs = {Signal(port.width, port.name)
                    for port in portListDict[stage] if port.direction == 'output'}
    ppSignals -= stageOutputs
    stageSignals[stage] -= stageOutputs
    stageSignals[stage] |= ppSignals  #! ppSignals is mutable
    ppSignals |= stageSignals[stage]


def gen_register(prev_stage, cur_stage, signals):
    print(
f'''module {prev_stage.capitalize()}{cur_stage.capitalize()}Registers (
    input clk,
    input rst,
    input CE,''')
    # input
    comma = False
    for signal in signals:
        if comma:
            print(',')
        print(f'    input ', end='')
        if signal.width:
            print("{} ".format(signal.width), end='')
        print("{}_{}".format(prev_stage.lower(), signal.name), end='')
        comma = True
    print(',')
    # output
    comma = False
    for signal in signals:
        if comma:
            print(',')
        print(f'    output reg ', end='')
        if signal.width:
            print("{} ".format(signal.width), end='')
        print("{}_{}".format(cur_stage.lower(), signal.name), end='')
        comma = True
    print(
'''
    );''')
    # decl finished
    print(
'''    always @(posedge clk) begin
        if (rst) begin''')
    for signal in signals:
        print(f'            {cur_stage.lower()}_{signal.name} <= 0;')
    # towards pipeline logic
    print(
'''        end 
        else if (CE) begin''')
    for signal in signals:
        print(
            f'            {cur_stage.lower()}_{signal.name} <= {prev_stage.lower()}_{signal.name};')
    print(
'''        end
    end
endmodule''')


def gen_registers():
    """ Generate 4 pipeline registers """
    global print # 输出重定向到多个文件
    old_print = print
    for i in range(1, len(stages)):
        prev_stage = stages[i - 1]
        cur_stage = stages[i]
        with open(f'PCPU/{prev_stage.capitalize()}{cur_stage.capitalize()}Registers.v', 'w') as f:
            print = partial(print, file=f)
            gen_register(prev_stage, cur_stage, stageSignals[cur_stage])
            print('')
    print = old_print

gen_registers()

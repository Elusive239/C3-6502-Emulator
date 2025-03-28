module emulator;
import emu6502;

const Word TERM_HEIGHT = 12;
const String TEXT_DIVIDER = "=-----------------------------------------------------------------=";

fn void render_status_bar(Cpu* cpu, DString* output) {
    render_divider(output);
    output.appendfn("| |c|z|i|d|b|u|v|n|  |   PC   |   A    |   X    |   Y    |   SP   |");
    render_divider(output);
    output.appendfn("| |%d|%d|%d|%d|%d|%d|%d|%d|  | 0x%04X |  0x%02X  |  0x%02X  |  0x%02X  |  0x%02X  |", 
    cpu.c, cpu.z, cpu.i, cpu.d, cpu.b, cpu.unused, cpu.v, cpu.n, cpu.pc, cpu.a, cpu.x, cpu.y, cpu.sp);
    render_divider(output);
}

fn void render_memory(Debugger* self, Cpu* cpu, Memory* mem, DString* output) {
    output.appendfn("|     INDEX |   HEX  |   INSTRUCTIONS   |    ADDRESSING   MODE    |");
    render_divider(output);
    for(int i = self.cursor_lower; i <=  self.cursor_upper; i++) {
        render_memory_slice(self, cpu, mem, output, i);
    }
    render_divider(output); 
}

fn void render_memory_slice(Debugger* self, Cpu* cpu, Memory* mem, DString* output, int index) {
    DString slice;
    defer slice.free();
    slice.temp_init();

    bool pc = cpu.pc == index;
    
    if(index == self.cursor_y){
        slice.appendf("| -> 0x%04X | 0x%04X |  ",index , (*mem)[index]);
    }
    else {
        slice.appendf("|    0x%04X | 0x%04X |  ",index , (*mem)[index]);
    }

    bool address = true;
    AddressMode mode = emu6502::address_mode((*mem)[index]);
    const String LAST_LINE = "                         |";
    if(self.renderable[index]){
        int bytes_consumed = emu6502::bytes_consumed((*mem)[index]);
        switch{
            case (*mem)[index] == emu6502::INS_BRK && (index > 0 &&( (*mem)[index-1] == emu6502::INS_BRK || emu6502::bytes_consumed((*mem)[index-1]) > 1)):
                slice.append("                |");
                address = false;
            case bytes_consumed == 1:
                slice.appendf("%s             |", emu6502::instruction_as_string((*mem)[index]));
            case bytes_consumed == 2:
                slice.appendf("%s, 0x%02X       |", emu6502::instruction_as_string((*mem)[index]), (*mem)[index+1]);
            case bytes_consumed == 3: 
                slice.appendf("%s, 0x%04X     |", emu6502::instruction_as_string((*mem)[index]), (((*mem)[index+2] << 8) | ((*mem)[index+1])) );
            default:
                slice.append("                |");
                address = false;
        }
        if(address){
            String tmp = mode.value;
            uint padding = (LAST_LINE.len - (tmp.len + 1));
            for(int i =0; i < padding/2; i++)  slice.append_char(' ');
            slice.append(tmp);
            for(int i =0; i < padding - (padding/2); i++)  slice.append_char(' ');
            slice.append_char('|');
        }else{
            slice.append(LAST_LINE);
        }
    }else{
        slice.append("                |");
        address = false;
        slice.append(LAST_LINE);
    }

    if(pc){
        output.appendfn("\e[0;32m%s\e[0m",slice);
    } else{
        output.appendfn("%s",slice);
    }
}

macro void render_divider(DString* output) => output.appendfn(TEXT_DIVIDER);

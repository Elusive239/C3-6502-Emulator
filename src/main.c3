module emulator;
import std::io;
import std::io::file;
import emu6502;

fn void main() {
    Memory mem;
    Cpu cpu; 
    cpu.init(&mem, 0x8000);
    mem[0x8000] = emu6502::INS_NOP;
    mem[0x8001] = emu6502::INS_INX;
    mem[0x8002] = emu6502::INS_CPX_IM;
    mem[0x8003] = 5;
    mem[0x8004] = emu6502::INS_BEQ;
    mem[0x8005] = 6;
    mem[0x8006] = emu6502::INS_JMP_ABS;
    mem[0x8007] = 0x00;
    mem[0x8008] = 0x80;

    // mem[0x8000] = emu6502::INS_ADC_ABS;
    // mem[0x8000+3] = emu6502::INS_ADC_ABSX;
    // mem[0x8000+6] = emu6502::INS_ADC_ABSY;
    // mem[0x8000+9] = emu6502::INS_ADC_INDX;
    // mem[0x8000+12] = emu6502::INS_ADC_INDY;
    // mem[0x8000+15] = emu6502::INS_JMP_ABS;
    // mem[0x8000+18] = emu6502::INS_JMP_IND;
    // mem[0x8000+21] = 0x90;
    // mem[0x8000+24] = 0x71;
    // mem[0x8000+27] = 0x61;
    // mem[0x8000+30] = 0xA9;
    // mem[0x8000+33] = 0x4A;
    // mem[0x8000+36] = 0xA8;
    clear_terminal();
    Word cursor_y = cpu.pc;
    Debugger debugger;
    debugger.run(&cpu, &mem);
}

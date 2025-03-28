module emu6502;
import emulator;
import std::io;

fn void Memory.init(memory){
    memory[0..] = 0;
}

fn Byte! Memory.read_byte(Memory* memory, Word address) {
    if(address >= MAX_MEM ) return Err6502.MEMORY_OUT_OF_BOUNDS?;
    Byte data = (*memory)[address];
    return data;
}

fn Word! Memory.read_word(Memory* memory, Word address) {
    if(address + 1 >= MAX_MEM ) return Err6502.MEMORY_OUT_OF_BOUNDS?;
    Byte low = memory.read_byte(address)!;
    Byte high = memory.read_byte(address+1)!;

    return low | (high << 8);
}

fn void! Memory.write_byte(Memory* memory, Byte value, Word address) {
    if(address >= MAX_MEM ) return Err6502.MEMORY_OUT_OF_BOUNDS?;
    (*memory)[address] = value;
}

fn void! Memory.write_word(Memory* memory,Word value, Word address) {
    if(address >= MAX_MEM ) return Err6502.MEMORY_OUT_OF_BOUNDS?;
    (*memory)[address++] = @byte(value & 0xFF);
    (*memory)[address] = @byte(value >> 8);
}

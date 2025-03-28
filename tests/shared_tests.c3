module emu6502::tests;
import emu6502;

Memory mem;
Cpu cpu;
Cpu copy;

macro Int32 @test_init(Int32 cycles, Word custom_pc = 0xFFFC;@body()){
    cpu.init(&mem, custom_pc);
    @body();
    copy = cpu;
    return cpu.exec(cycles, &mem)!!;
}

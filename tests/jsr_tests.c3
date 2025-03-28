module emu6502::tests;
import emu6502;
import emulator;

macro void verify_jsr_flags_unmodified() { // I would pass by ptr but not point..
    assert(cpu.c == copy.c);
    assert(cpu.z == copy.z);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
    assert(cpu.n == copy.n);
}

fn void test_jsr_and_ret() @test {
    const Int32 NUM_CYCLES = 14; // JSR + RET + LDA_IM
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_JSR;
        mem[0xFF01] = 0x00; 
        mem[0xFF02] = 0x80;
        mem[0x8000] = emu6502::INS_RTS;
        mem[0xFF03] = emu6502::INS_LDA_IM;
        mem[0xFF04] = 0x42;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.sp == copy.sp);
    assert(cpu.a == 0x42, "Expected %d Got %d",0x42, cpu.a );
    verify_jsr_flags_unmodified();
}

fn void test_jsr_doesnt_affect_ps() @test {
    const Int32 NUM_CYCLES = 6; // JSR + RET + LDA_IM
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_JSR;
        mem[0xFF01] = 0x00; 
        mem[0xFF02] = 0x80;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.ps == copy.ps );
    assert(cpu.sp != copy.sp );
    assert(cpu.pc == 0x8000 );
}

fn void test_jmp_abs() @test {
    const Int32 NUM_CYCLES = 3; // JSR + RET + LDA_IM
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_JMP_ABS;
        mem[0xFF01] = 0x00; 
        mem[0xFF02] = 0x80;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.ps == copy.ps );
    assert(cpu.sp == copy.sp );
    assert(cpu.pc == 0x8000 );
}

fn void test_jmp_ind() @test {
    const Int32 NUM_CYCLES = 5; // JSR + RET + LDA_IM
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_JMP_IND;
        mem[0xFF01] = 0x00; 
        mem[0xFF02] = 0x80;
        mem[0x8000] = 0x00;
        mem[0x8001] = 0x90;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.ps == copy.ps );
    assert(cpu.sp == copy.sp );
    assert(cpu.pc == 0x9000 );
}

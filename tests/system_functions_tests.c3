
module emu6502::tests;
import emu6502;

fn void nop_test() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.i = 0;
        mem[0xFF00] = emu6502::INS_NOP;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == copy.pc + 1);
    assert(cpu.a == copy.a);
    assert(cpu.x == copy.x);
    assert(cpu.y == copy.y);
    assert(cpu.sp == copy.sp);
}

macro verify_break_flags(){
    assert(cpu.c == copy.c);
    assert(cpu.z == copy.z);
    assert(cpu.i == 1);
    assert(cpu.d == copy.d);
    assert(cpu.v == copy.v);
    assert(cpu.n == copy.n);
}

fn void brk_loads_pc_from_reset_vector_test() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.b_bool = false;
        mem[0xFF00] = emu6502::INS_BRK;
        mem[0xFFFE] = 0x00;
        mem[0xFFFF] = 0x80;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0x8000);
    assert(cpu.b_bool == true);
    verify_break_flags();
}

fn void brk_loads_pc_from_different_reset_vector_test() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.b_bool = false;
        mem[0xFF00] = emu6502::INS_BRK;
        mem[0xFFFE] = 0x42;
        mem[0xFFFF] = 0x42;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0x4242);
    assert(cpu.b_bool == true);
    verify_break_flags();
}

fn void brk_sp_pushed_ps_and_pc_to_stack() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.b_bool = false;
        mem[0xFF00] = emu6502::INS_BRK;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0x0000);
    assert(mem[(usz)(0x100 | copy.sp-0)] == 0xFF, "Expected %d Got %d ", 0xFF, mem[(usz)(0x100 | cpu.sp-0)] );
    assert(mem[(usz)(0x100 | copy.sp-1)] == 0x02, "Expected %d Got %d ", 0x01, mem[(usz)(0x100 | cpu.sp-1)] );
    assert(mem[(usz)(0x100 | copy.sp-2)] == copy.ps | emu6502::UNUSED_FLAG | emu6502::BREAK_CMD);
    assert(cpu.b_bool == true);
    verify_break_flags();
}

fn void brk_ps_has_bit_4_and_5_set() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.b_bool = false;
        mem[0xFF00] = emu6502::INS_BRK;
        mem[0xFFFE] = 0x00;
        mem[0xFFFF] = 0x00;
        mem[0x0000] = 0x00;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0x0000);
    assert(mem[(usz)(0x100 | copy.sp-0)] == 0xFF, "Expected %d Got %d ", 0xFF, mem[(usz)(0x100 | cpu.sp-0)] );
    assert(mem[(usz)(0x100 | copy.sp-1)] == 0x02, "Expected %d Got %d ", 0x02, mem[(usz)(0x100 | cpu.sp-1)] );
    assert(mem[(usz)(0x100 | copy.sp-2)] == copy.ps | emu6502::UNUSED_FLAG | emu6502::BREAK_CMD);
    assert(cpu.b_bool == true);
    verify_break_flags();
}

fn void rti_test() @test {
    const Int32 NUM_CYCLES = 7 + 6; // 7 from BRK, 6 from RTI
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        // cpu.b_bool = false;
        mem[0xFF00] = emu6502::INS_BRK;
        mem[0xFFFE] = 0x00;
        mem[0xFFFF] = 0x80;
        mem[0x8000] = emu6502::INS_RTI;
    };
    assert(used == NUM_CYCLES, "Expected %d cycles Got %d", NUM_CYCLES, used);
    assert(cpu.sp == copy.sp);
    assert(cpu.ps == copy.ps );
    assert(cpu.pc == 0xFF02, "Expected %d Got %d", 0xFF02, cpu.pc);
}

import std::io;
import std::io::file;
// https://github.com/Klaus2m5/6502_65C02_functional_tests.git
fn void full_test_suite() @test { //basically pointless but it *does* run!
    cpu.init(&mem);
    char[]! buffer = file::load_new("6502_functional_test.bin");
    if(catch e= buffer){
        io::printfn("%s", e);
        return;
    }
    defer mem::free(buffer); 
    cpu.pc = 0x400;
    for(int i= 0; i < buffer.len; i++) mem[(usz)(0x000A + i)] == buffer[i];
    for(Int32 clock = 1000000; clock > 0; ){
        clock -= cpu.exec(1, &mem)!!;
    }
}
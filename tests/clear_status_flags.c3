module emu6502::tests;
import emu6502;

fn void clear_flag_c() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_CLC;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.c_bool == false);
    assert(cpu.z == copy.z);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
    assert(cpu.n == copy.n);
}

fn void clear_flag_d() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.d_bool = true;
        mem[0xFF00] = emu6502::INS_CLD;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.c == copy.c);
    assert(cpu.z == copy.z);
    assert(cpu.i == copy.i);
    assert(cpu.d_bool == false);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
    assert(cpu.n == copy.n);
}

fn void clear_flag_i() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.i_bool = true;
        mem[0xFF00] = emu6502::INS_CLI;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.c == copy.c);
    assert(cpu.z == copy.z);
    assert(cpu.i_bool == false);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
    assert(cpu.n == copy.n);
}

fn void clear_flag_v() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.v_bool = true;
        mem[0xFF00] = emu6502::INS_CLV;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.c == copy.c);
    assert(cpu.z == copy.c);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v_bool == false);
    assert(cpu.n == copy.n);
}

fn void set_flag_c() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.c_bool = false;
        mem[0xFF00] = emu6502::INS_SEC;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.c_bool == true);
    assert(cpu.z == copy.z);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
    assert(cpu.n == copy.n);
}

fn void set_flag_d() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.d_bool = false;
        mem[0xFF00] = emu6502::INS_SED;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.c == copy.c);
    assert(cpu.z == copy.z);
    assert(cpu.i == copy.i);
    assert(cpu.d_bool == true);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
    assert(cpu.n == copy.n);
}

fn void set_flag_i() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.i_bool = false;
        mem[0xFF00] = emu6502::INS_SEI;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.c == copy.c);
    assert(cpu.z == copy.z);
    assert(cpu.i_bool == true);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
    assert(cpu.n == copy.n);
}
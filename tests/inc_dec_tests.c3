module emu6502::tests;
import emu6502;

/*
emu6502::INS_INC
emu6502::INS_INX
emu6502::INS_INY
emu6502::INS_DEC
emu6502::INS_DEX
emu6502::INS_DEY
*/

macro verify_inc_and_dec_flags(){
    assert(cpu.c == copy.c);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
}

fn void inx_can_increment_zero_test() @test => @in_can_increment_zero_test(emu6502::INS_INX, x); // pass
fn void iny_can_increment_zero_test() @test => @in_can_increment_zero_test(emu6502::INS_INY, y); // fail
macro void @in_can_increment_zero_test(Byte opcode, #reg) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.#reg = 0;
        cpu.n_bool = cpu.z_bool = true;
        mem[0xFF00] = opcode;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.#reg == 1);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_inc_and_dec_flags();
}

fn void inx_can_increment_255_test() @test => @in_can_increment_255_test(emu6502::INS_INX, x); // pass
fn void iny_can_increment_255_test() @test => @in_can_increment_255_test(emu6502::INS_INY, y); // pass
macro void @in_can_increment_255_test(Byte opcode, #reg) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.#reg = 0xFF;
        cpu.n_bool = true;
        cpu.z_bool = false;
        mem[0xFF00] = opcode;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.#reg == 0);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_inc_and_dec_flags();
}

fn void inx_can_increment_a_negative_value_test() @test => @in_can_increment_a_negative_value_test(emu6502::INS_INX, x); // fail
fn void iny_can_increment_a_negative_value_test() @test => @in_can_increment_a_negative_value_test(emu6502::INS_INY, y); // fail
macro void @in_can_increment_a_negative_value_test(Byte opcode, #reg) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.#reg = emu6502::NEGATIVE_FLAG | 0x02;
        cpu.z_bool = true;
        cpu.n_bool = false;
        mem[0xFF00] = opcode;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.#reg == (emu6502::NEGATIVE_FLAG | 0x03), "Expected %d Got %d",  (emu6502::NEGATIVE_FLAG | 0x03), cpu.#reg);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == true,  "Expected %d Got %d", 1, cpu.n);
    verify_inc_and_dec_flags();
}

fn void inc_zp_can_increment_a_value() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        cpu.n_bool = true;
        mem[0xFF00] = emu6502::INS_INC_ZP;
        mem[0xFF01] = 0x42;
        mem[0x0042] = 0x57;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x0042] == 0x58);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == false,  "Expected %d Got %d", 0, cpu.n);
    verify_inc_and_dec_flags();
}

fn void inc_zpx_can_increment_a_value() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        cpu.n_bool = true;
        cpu.x = 0x10;
        mem[0xFF00] = emu6502::INS_INC_ZPX;
        mem[0xFF01] = 0x42;
        mem[(usz)(0x0042 + 0x10)] = 0x57;
    };
    assert(used == NUM_CYCLES);
    assert(mem[(usz)(0x0042 + 0x10)] == 0x58);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == false,  "Expected %d Got %d", 0, cpu.n);
    verify_inc_and_dec_flags();
}

fn void inc_abs_can_increment_a_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        cpu.n_bool = true;
        mem[0xFF00] = emu6502::INS_INC_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 0x42;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8000] == 0x43);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == false,  "Expected %d Got %d", 0, cpu.n);
    verify_inc_and_dec_flags();
}

fn void inc_abs_x_can_increment_a_value() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        cpu.n_bool = true;
        cpu.x = 0x10;
        mem[0xFF00] = emu6502::INS_INC_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8010] = 0x42;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8010] == 0x43);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == false,  "Expected %d Got %d", 0, cpu.n);
    verify_inc_and_dec_flags();
}


fn void dex_can_decrement_zero_test() @test => @de_can_decrement_zero_test(emu6502::INS_DEX, x); // pass
fn void dey_can_decrement_zero_test() @test => @de_can_decrement_zero_test(emu6502::INS_DEY, y); // fail
macro void @de_can_decrement_zero_test(Byte opcode, #reg) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.#reg = 0;
        cpu.n_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = opcode;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.#reg == 0xFF);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_inc_and_dec_flags();
}

fn void dex_can_decrement_255_test() @test => @de_can_decrement_255_test(emu6502::INS_DEX, x); // pass
fn void dey_can_decrement_255_test() @test => @de_can_decrement_255_test(emu6502::INS_DEY, y); // pass
macro void @de_can_decrement_255_test(Byte opcode, #reg) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.#reg = 0b11111111;
        cpu.n_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = opcode;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.#reg == 0b11111110);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_inc_and_dec_flags();
}

fn void dex_can_decrement_a_negative_value_test() @test => @de_can_decrement_a_negative_value_test(emu6502::INS_DEX, x); // fail
fn void dey_can_decrement_a_negative_value_test() @test => @de_can_decrement_a_negative_value_test(emu6502::INS_DEY, y); // fail
macro void @de_can_decrement_a_negative_value_test(Byte opcode, #reg) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.#reg = emu6502::NEGATIVE_FLAG | 0x02;
        cpu.z_bool = true;
        cpu.n_bool = false;
        mem[0xFF00] = opcode;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.#reg == (emu6502::NEGATIVE_FLAG | 0x01), "Expected %d Got %d",  (emu6502::NEGATIVE_FLAG | 0x01), cpu.#reg);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == true,  "Expected %d Got %d", 1, cpu.n);
    verify_inc_and_dec_flags();
}

fn void dec_zp_can_decrement_a_value() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        cpu.n_bool = true;
        mem[0xFF00] = emu6502::INS_DEC_ZP;
        mem[0xFF01] = 0x42;
        mem[0x0042] = 0x57;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x0042] == 0x56);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == false,  "Expected %d Got %d", 0, cpu.n);
    verify_inc_and_dec_flags();
}

fn void dec_zpx_can_decrement_a_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        cpu.n_bool = true;
        cpu.x = 0x10;
        mem[0xFF00] = emu6502::INS_DEC_ZPX;
        mem[0xFF01] = 0x42;
        mem[(usz)(0x0042 + 0x10)] = 0x57;
    };
    assert(used == NUM_CYCLES);
    assert(mem[(usz)(0x0042 + 0x10)] == 0x56);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == false,  "Expected %d Got %d", 0, cpu.n);
    verify_inc_and_dec_flags();
}

fn void dec_abs_can_decrement_a_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        cpu.n_bool = true;
        mem[0xFF00] = emu6502::INS_DEC_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 0x42;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8000] == 0x41);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == false,  "Expected %d Got %d", 0, cpu.n);
    verify_inc_and_dec_flags();
}

fn void dec_abs_x_can_decrement_a_value() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        cpu.n_bool = true;
        cpu.x = 0x10;
        mem[0xFF00] = emu6502::INS_DEC_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8010] = 0x42;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8010] == 0x41);
    assert(cpu.z_bool == false,  "Expected %d Got %d", 0, cpu.z);
    assert(cpu.n_bool == false,  "Expected %d Got %d", 0, cpu.n);
    verify_inc_and_dec_flags();
}

const Byte[*] TEST_PRG_2 = { 
    0x00, 0x10, 0xa9, 0x00, 0x85, 0x42, 0xe6, 0x42, 0xa6, 0x42, 0xe8, 0x4c, 0x04, 0x10,
};

fn void inc_dec_prg_test() {
    @test_init(20){
        cpu.pc = cpu.load_prg(TEST_PRG_2[0..], &mem);
    };
}
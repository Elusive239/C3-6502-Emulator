module emu6502::tests;
import emu6502;

/*
emu6502::INS_TAX
emu6502::INS_TAY
emu6502::INS_TXA
emu6502::INS_TYA
*/

macro verify_transfer_flags(){
    assert(cpu.c == copy.c);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
}

macro void @reg_transfer_tests(Byte op_code, #in_reg, #target_reg, Byte copy_value, bool z_flag, bool n_flag) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.#in_reg = copy_value;
        cpu.#target_reg = 0x32;
        cpu.z_bool = !z_flag;
        cpu.n_bool = !n_flag;
        mem[0xFF00] = op_code;
        //...
    };
    assert(used == NUM_CYCLES);
    assert(cpu.n_bool == n_flag);
    assert(cpu.z_bool == z_flag);
    assert(cpu.a == copy_value);
    assert(cpu.#in_reg == copy_value);
    verify_transfer_flags();
}

fn void tax_test() @test  => @reg_transfer_tests(emu6502::INS_TAX, a, x, 0x42, false, false);
fn void tax_zero_test() @test => @reg_transfer_tests(emu6502::INS_TAX, a, x, 0x00, true, false);
fn void tax_negative_test() @test => @reg_transfer_tests(emu6502::INS_TAX, a, x, 0b10000001, false, true);
fn void tay_test() @test => @reg_transfer_tests(emu6502::INS_TAY, a, y, 0x42, false, false);
fn void tay_zero_test() @test => @reg_transfer_tests(emu6502::INS_TAY, a, y, 0x00, true, false);
fn void tay_negative_test() @test => @reg_transfer_tests(emu6502::INS_TAY, a, y, 0b10000001, false, true);
fn void txa_test() @test  => @reg_transfer_tests(emu6502::INS_TXA, x,a,  0x42, false, false);
fn void txa_zero_test() @test => @reg_transfer_tests(emu6502::INS_TXA,  x,a, 0x00, true, false);
fn void txa_negative_test() @test => @reg_transfer_tests(emu6502::INS_TXA,  x,a, 0b10000001, false, true);
fn void tya_test() @test => @reg_transfer_tests(emu6502::INS_TYA,  y,a, 0x42, false, false);
fn void tya_zero_test() @test => @reg_transfer_tests(emu6502::INS_TYA,  y,a, 0x00, true, false);
fn void tya_negative_test() @test => @reg_transfer_tests(emu6502::INS_TYA,  y,a, 0b10000001, false, true);

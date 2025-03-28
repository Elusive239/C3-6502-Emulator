module emu6502::tests;
import emu6502;

macro verify_cmp_flags_untouched() {
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
}

enum CmpTestReg{
    A, X, Y
}

struct CmpTestData{
    Byte a;
    Byte operand;
    bool expectZ;
    bool expectN;
    bool expectC;
}

CmpTestData test1 = CmpTestData{
    .a = 0x26,
    .operand = 0x26,
    .expectZ = true,
    .expectN = false,
    .expectC = true,
};
CmpTestData test2 = CmpTestData{
    .a = 48,
    .operand = 0x26,
    .expectZ = false,
    .expectN = false,
    .expectC = true,
};
CmpTestData test3 = CmpTestData{
    .a = 130,
    .operand = 0x26,
    .expectZ = false,
    .expectN = false,
    .expectC = true,
};
CmpTestData test4 = CmpTestData{
    .a = 8,
    .operand = 0x26,
    .expectZ = false,
    .expectN = true,
    .expectC = false,
};

fn void cmp_im_two_positive_values_test() @test => cmp_im(test1, CmpTestReg.A, emu6502::INS_CMP_IM);
fn void cmp_im_large_positive_to_small_positive_test() @test => cmp_im(test2, CmpTestReg.A, emu6502::INS_CMP_IM);
fn void cmp_im_large_negative_to_small_positive_test() @test => cmp_im(test3, CmpTestReg.A, emu6502::INS_CMP_IM);
fn void cmp_im_two_values_that_result_in_a_negative_test() @test => cmp_im(test4, CmpTestReg.A, emu6502::INS_CMP_IM);

fn void cpx_im_two_positive_values_test() @test => cmp_im(test1, CmpTestReg.X, emu6502::INS_CPX_IM);
fn void cpx_im_large_positive_to_small_positive_test() @test => cmp_im(test2, CmpTestReg.X, emu6502::INS_CPX_IM);
fn void cpx_im_large_negative_to_small_positive_test() @test => cmp_im(test3, CmpTestReg.X, emu6502::INS_CPX_IM);
fn void cpx_im_two_values_that_result_in_a_negative_test() @test => cmp_im(test4, CmpTestReg.X, emu6502::INS_CPX_IM);

fn void cpy_im_two_positive_values_test() @test => cmp_im(test1, CmpTestReg.Y, emu6502::INS_CPY_IM);
fn void cpy_im_large_positive_to_small_positive_test() @test => cmp_im(test2, CmpTestReg.Y, emu6502::INS_CPY_IM);
fn void cpy_im_large_negative_to_small_positive_test() @test => cmp_im(test3, CmpTestReg.Y, emu6502::INS_CPY_IM);
fn void cpy_im_two_values_that_result_in_a_negative_test() @test => cmp_im(test4, CmpTestReg.Y, emu6502::INS_CPY_IM);

fn void cmp_im(CmpTestData tdata, CmpTestReg register, Byte opcode) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        switch(register){
            case CmpTestReg.A: cpu.a = tdata.a;
            case CmpTestReg.X: cpu.x = tdata.a;
            case CmpTestReg.Y: cpu.y = tdata.a;
        }
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.c_bool = !tdata.expectC;
        mem[0xFF00] = opcode;//emu6502::INS_CMP_IM;
        mem[0xFF01] = tdata.operand;
    };
    assert(used == NUM_CYCLES);
    switch(register){
        case CmpTestReg.A: assert(cpu.a == tdata.a);
        case CmpTestReg.X: assert(cpu.x == tdata.a);
        case CmpTestReg.Y: assert(cpu.y == tdata.a);
    }
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.c_bool == tdata.expectC);
    verify_cmp_flags_untouched();
}

fn void cmp_zp_two_positive_values_test() @test => cmp_zp(test1, CmpTestReg.A, emu6502::INS_CMP_ZP);
fn void cmp_zp_large_positive_to_small_positive_test() @test => cmp_zp(test2, CmpTestReg.A, emu6502::INS_CMP_ZP);
fn void cmp_zp_large_negative_to_small_positive_test() @test => cmp_zp(test3, CmpTestReg.A, emu6502::INS_CMP_ZP);
fn void cmp_zp_two_values_that_result_in_a_negative_test() @test => cmp_zp(test4, CmpTestReg.A, emu6502::INS_CMP_ZP);

fn void cpx_zp_two_positive_values_test() @test => cmp_zp(test1, CmpTestReg.X, emu6502::INS_CPX_ZP);
fn void cpx_zp_large_positive_to_small_positive_test() @test => cmp_zp(test2, CmpTestReg.X, emu6502::INS_CPX_ZP);
fn void cpx_zp_large_negative_to_small_positive_test() @test => cmp_zp(test3, CmpTestReg.X, emu6502::INS_CPX_ZP);
fn void cpx_zp_two_values_that_result_in_a_negative_test() @test => cmp_zp(test4, CmpTestReg.X, emu6502::INS_CPX_ZP);

fn void cpy_zp_two_positive_values_test() @test => cmp_zp(test1, CmpTestReg.Y, emu6502::INS_CPY_ZP);
fn void cpy_zp_large_positive_to_small_positive_test() @test => cmp_zp(test2, CmpTestReg.Y, emu6502::INS_CPY_ZP);
fn void cpy_zp_large_negative_to_small_positive_test() @test => cmp_zp(test3, CmpTestReg.Y, emu6502::INS_CPY_ZP);
fn void cpy_zp_two_values_that_result_in_a_negative_test() @test => cmp_zp(test4, CmpTestReg.Y, emu6502::INS_CPY_ZP);

fn void cmp_zp(CmpTestData tdata, CmpTestReg register, Byte opcode) {
    const Int32 NUM_CYCLES = 3;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        // cpu.a = tdata.a;
        switch(register){
            case CmpTestReg.A: cpu.a = tdata.a;
            case CmpTestReg.X: cpu.x = tdata.a;
            case CmpTestReg.Y: cpu.y = tdata.a;
        }
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.c_bool = !tdata.expectC;
        mem[0xFF00] = opcode;
        mem[0xFF01] = 0x50;
        mem[0x0050] = tdata.operand;
    };
    assert(used == NUM_CYCLES);
    switch(register){
        case CmpTestReg.A: assert(cpu.a == tdata.a);
        case CmpTestReg.X: assert(cpu.x == tdata.a);
        case CmpTestReg.Y: assert(cpu.y == tdata.a);
    }
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.c_bool == tdata.expectC);
    verify_cmp_flags_untouched();
}

fn void cmp_zp_x_two_positive_values_test() @test => cmp_zp_x(test1);
fn void cmp_zp_x_large_positive_to_small_positive_test() @test => cmp_zp_x(test2);
fn void cmp_zp_x_large_negative_to_small_positive_test() @test => cmp_zp_x(test3);
fn void cmp_zp_x_two_values_that_result_in_a_negative_test() @test => cmp_zp_x(test4);

fn void cmp_zp_x(CmpTestData tdata) {
    const Int32 NUM_CYCLES = 4;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 5;
        cpu.a = tdata.a;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.c_bool = !tdata.expectC;
        mem[0xFF00] = emu6502::INS_CMP_ZPX;
        mem[0xFF01] = 0x50;
        mem[0x0055] = tdata.operand;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.a);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.c_bool == tdata.expectC);
    verify_cmp_flags_untouched();
}

fn void cmp_abs_two_positive_values_test() @test =>                  cmp_abs(test1, CmpTestReg.A, emu6502::INS_CMP_ABS);
fn void cmp_abs_large_positive_to_small_positive_test() @test =>     cmp_abs(test2, CmpTestReg.A, emu6502::INS_CMP_ABS);
fn void cmp_abs_large_negative_to_small_positive_test() @test =>     cmp_abs(test3, CmpTestReg.A, emu6502::INS_CMP_ABS);
fn void cmp_abs_two_values_that_result_in_a_negative_test() @test => cmp_abs(test4, CmpTestReg.A, emu6502::INS_CMP_ABS);

fn void cpx_abs_two_positive_values_test() @test =>                  cmp_abs(test1, CmpTestReg.X, emu6502::INS_CPX_ABS);
fn void cpx_abs_large_positive_to_small_positive_test() @test =>     cmp_abs(test2, CmpTestReg.X, emu6502::INS_CPX_ABS);
fn void cpx_abs_large_negative_to_small_positive_test() @test =>     cmp_abs(test3, CmpTestReg.X, emu6502::INS_CPX_ABS);
fn void cpx_abs_two_values_that_result_in_a_negative_test() @test => cmp_abs(test4, CmpTestReg.X, emu6502::INS_CPX_ABS);

fn void cpy_abs_two_positive_values_test() @test =>                  cmp_abs(test1, CmpTestReg.Y, emu6502::INS_CPY_ABS);
fn void cpy_abs_large_positive_to_small_positive_test() @test =>     cmp_abs(test2, CmpTestReg.Y, emu6502::INS_CPY_ABS);
fn void cpy_abs_large_negative_to_small_positive_test() @test =>     cmp_abs(test3, CmpTestReg.Y, emu6502::INS_CPY_ABS);
fn void cpy_abs_two_values_that_result_in_a_negative_test() @test => cmp_abs(test4, CmpTestReg.Y, emu6502::INS_CPY_ABS);

fn void cmp_abs(CmpTestData tdata, CmpTestReg register, Byte opcode) {
    const Int32 NUM_CYCLES = 4;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        switch(register){
            case CmpTestReg.A: cpu.a = tdata.a;
            case CmpTestReg.X: cpu.x = tdata.a;
            case CmpTestReg.Y: cpu.y = tdata.a;
        }
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.c_bool = !tdata.expectC;
        mem[0xFF00] = opcode;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = tdata.operand;
    };
    assert(used == NUM_CYCLES);
    switch(register){
        case CmpTestReg.A: assert(cpu.a == tdata.a);
        case CmpTestReg.X: assert(cpu.x == tdata.a);
        case CmpTestReg.Y: assert(cpu.y == tdata.a);
    }
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.c_bool == tdata.expectC);
    verify_cmp_flags_untouched();
}

fn void cmp_abs_x_two_positive_values_test() @test => cmp_abs_x(test1);
fn void cmp_abs_x_large_positive_to_small_positive_test() @test => cmp_abs_x(test2);
fn void cmp_abs_x_large_negative_to_small_positive_test() @test => cmp_abs_x(test3);
fn void cmp_abs_x_two_values_that_result_in_a_negative_test() @test => cmp_abs_x(test4);

fn void cmp_abs_x(CmpTestData tdata) {
    const Int32 NUM_CYCLES = 4;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x05;
        cpu.a = tdata.a;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.c_bool = !tdata.expectC;
        mem[0xFF00] = emu6502::INS_CMP_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x05] = tdata.operand;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.a);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.c_bool == tdata.expectC);
    verify_cmp_flags_untouched();
}

fn void cmp_abs_y_two_positive_values_test() @test => cmp_abs_y(test1);
fn void cmp_abs_y_large_positive_to_small_positive_test() @test => cmp_abs_y(test2);
fn void cmp_abs_y_large_negative_to_small_positive_test() @test => cmp_abs_y(test3);
fn void cmp_abs_y_two_values_that_result_in_a_negative_test() @test => cmp_abs_y(test4);

fn void cmp_abs_y(CmpTestData tdata) {
    const Int32 NUM_CYCLES = 4;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.y = 0x05;
        cpu.a = tdata.a;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.c_bool = !tdata.expectC;
        mem[0xFF00] = emu6502::INS_CMP_ABSY;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x05] = tdata.operand;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.a);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.c_bool == tdata.expectC);
    verify_cmp_flags_untouched();
}

fn void cmp_indx_two_positive_values_test() @test => cmp_indx(test1);
fn void cmp_indx_large_positive_to_small_positive_test() @test => cmp_indx(test2);
fn void cmp_indx_large_negative_to_small_positive_test() @test => cmp_indx(test3);
fn void cmp_indx_two_values_that_result_in_a_negative_test() @test => cmp_indx(test4);

fn void cmp_indx(CmpTestData tdata) {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x05;
        cpu.a = tdata.a;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.c_bool = !tdata.expectC;
        mem[0xFF00] = emu6502::INS_CMP_INDX;
        mem[0xFF01] = 0x02;
        mem[0x0007] = 0x00;
        mem[0x0008] = 0x80;
        mem[0x8000] = tdata.operand;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.a);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.c_bool == tdata.expectC);
    verify_cmp_flags_untouched();
}

fn void cmp_indy_two_positive_values_test() @test => cmp_indy(test1);
fn void cmp_indy_large_positive_to_small_positive_test() @test => cmp_indy(test2);
fn void cmp_indy_large_negative_to_small_positive_test() @test => cmp_indy(test3);
fn void cmp_indy_two_values_that_result_in_a_negative_test() @test => cmp_indy(test4);

fn void cmp_indy(CmpTestData tdata) {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.y = 0x05;
        cpu.a = tdata.a;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.c_bool = !tdata.expectC;
        mem[0xFF00] = emu6502::INS_CMP_INDY;
        mem[0xFF01] = 0x02;
        mem[0x0002] = 0x00;
        mem[0x0003] = 0x80;
        mem[0x8000 + 0x05] = tdata.operand;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.a);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.c_bool == tdata.expectC);
    verify_cmp_flags_untouched();
}

const char[*] TEST_PRG_3 = {0x00, 0x10, 0xa9, 0x00, 0x18, 0x69, 0x08, 0xc9, 0x18, 0xd0, 0xfa, 0xa2, 0x14,};
fn void branch_prg_test() @test {
    cpu.init(&mem);
    cpu.pc = cpu.load_prg(TEST_PRG_3[0..], &mem);
   
    for(Int32 clock = 26; clock > 0; ){
        clock -= cpu.exec(1, &mem)!!;
    }
}
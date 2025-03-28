module emu6502::tests;
import emu6502;

macro void verify_shift_flags(){
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
}

fn void asl_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.z_bool = cpu.n_bool = cpu.c_bool = true;
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_ASL;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == 1 << 1);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.z_bool = true;
        cpu.n_bool = cpu.c_bool = false;
        cpu.a = 0b11000001;
        mem[0xFF00] = emu6502::INS_ASL;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == 0b10000010 );
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_zp_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.z_bool = cpu.n_bool = cpu.c_bool = true;
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_ASL_ZP;
        mem[0xFF01] = 0x50;
        mem[0x0050] = 1;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x0050] == 1 << 1);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_zp_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.z_bool = true;
        cpu.n_bool = cpu.c_bool = false;
        cpu.a = 0b11000001;
        mem[0xFF00] = emu6502::INS_ASL_ZP;
        mem[0xFF01] = 0x50;
        mem[0x0050] = 0b11000001;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x0050] == 0b10000010 );
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_zp_x_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.z_bool = cpu.n_bool = cpu.c_bool = true;
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_ASL_ZPX;
        mem[0xFF01] = 0x50;
        mem[0x0050 + 0x10] = 1;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x0050 + 0x10] == 2);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_zp_x_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.z_bool = true;
        cpu.n_bool = cpu.c_bool = false;
        cpu.a = 0b11000001;
        mem[0xFF00] = emu6502::INS_ASL_ZPX;
        mem[0xFF01] = 0x50;
        mem[0x0050 + 0x10] = 0b11000001;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x0050 + 0x10] == 0b10000010 );
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_abs_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.z_bool = cpu.n_bool = cpu.c_bool = true;
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_ASL_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 1;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8000] == 2);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_abs_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.z_bool = true;
        cpu.n_bool = cpu.c_bool = false;
        cpu.a = 0b11000001;
        mem[0xFF00] = emu6502::INS_ASL_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 0b11000001;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8000] == 0b10000010 );
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_abs_x_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.z_bool = cpu.n_bool = cpu.c_bool = true;
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_ASL_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = 1;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8000 + 0x10] == 2);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void asl_abs_x_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.z_bool = true;
        cpu.n_bool = cpu.c_bool = false;
        cpu.a = 0b11000001;
        mem[0xFF00] = emu6502::INS_ASL_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = 0b11000001;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8000 + 0x10] == 0b10000010 );
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

//LSR

fn void lsr_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = true;
        cpu.z_bool = cpu.c_bool = false;
        cpu.a = 1;
        mem[0xFF00] = emu6502::INS_LSR;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == 1 >> 1);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}

fn void lsr_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.z_bool = true;
        cpu.n_bool = cpu.c_bool = false;
        cpu.a = 0b11000001;
        mem[0xFF00] = emu6502::INS_LSR;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.a == 0b01100000 );
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void lsr_zp_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = true;
        cpu.z_bool = cpu.c_bool = false;
        mem[0xFF00] = emu6502::INS_LSR_ZP;
        mem[0xFF01] = 0x50;
        mem[0x0050] = 1;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x0050] == 0, "Expected %b Got %b", 0,  mem[0x0050]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}

fn void lsr_zp_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.z_bool = true;
        cpu.n_bool = cpu.c_bool = false;
        mem[0xFF00] = emu6502::INS_LSR_ZP;
        mem[0xFF01] = 0x50;
        mem[0x0050] = 0b11000001;
    };
    Byte value = 0b01100000;
    assert(used == NUM_CYCLES);
    assert(mem[0x0050] == 0b01100000, "Expected %b Got %b", 0b01100000,  mem[0x0050]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void lsr_zp_x_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = true;
        cpu.z_bool = cpu.c_bool = false;
        mem[0xFF00] = emu6502::INS_LSR_ZPX;
        mem[0xFF01] = 0x50;
        mem[0x0050 + 0x10] = 1;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x0050 + 0x10] == 0, "Expected %b Got %b", 0,  mem[0x0050 + 0x10]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}

fn void lsr_zp_x_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.z_bool = true;
        cpu.n_bool = cpu.c_bool = false;
        mem[0xFF00] = emu6502::INS_LSR_ZPX;
        mem[0xFF01] = 0x50;
        mem[0x0050 + 0x10] = 0b11000001;
    };
    Byte value = 0b01100000;
    assert(used == NUM_CYCLES);
    assert(mem[0x0050 + 0x10] == 0b01100000, "Expected %b Got %b", 0b01100000,  mem[0x0050 + 0x10]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void lsr_abs_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = true;
        cpu.z_bool = cpu.c_bool = false;
        mem[0xFF00] = emu6502::INS_LSR_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 1;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8000] == 0, "Expected %b Got %b", 0,  mem[0x8000]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}

fn void lsr_abs_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_LSR_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 0b11000001;
    };
    Byte value = 0b01100000;
    assert(used == NUM_CYCLES);
    assert(mem[0x8000] == 0b01100000, "Expected %b Got %b", 0b01100000,  mem[0x8000]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void lsr_abs_x_can_shift_values_of_one() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = true;
        cpu.z_bool = cpu.c_bool = false;
        mem[0xFF00] = emu6502::INS_LSR_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000+ 0x10] = 1;
    };
    assert(used == NUM_CYCLES);
    assert(mem[0x8000 + 0x10] == 0, "Expected %b Got %b", 0,  mem[0x8000 + 0x10]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}

fn void lsr_abs_x_can_shift_a_negative_value() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_LSR_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = 0b11000001;
    };
    Byte value = 0b01100000;
    assert(used == NUM_CYCLES);
    assert(mem[0x8000 + 0x10] == 0b01100000, "Expected %b Got %b", 0b01100000,  mem[0x8000 + 0x10]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_can_rotate_values_of_zero() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.a = 0;
        cpu.n_bool = cpu.z_bool = cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROL;
    };
    assert(used == NUM_CYCLES);
    Byte value = 1;
    assert(cpu.a == value, "Expected %b Got %b", value,  cpu.a);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_can_rotate_a_negative_value() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROL;
        cpu.a = 0b11000001;
    };
    Byte value = 0b10000010;
    assert(used == NUM_CYCLES);
    assert(cpu.a == value, "Expected %b Got %b", value, cpu.a);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_zp_can_rotate_zero() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.z_bool = cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROL_ZP;
        mem[0xFF01] = 0xFF;
        mem[0x00FF] = 0;
    };
    assert(used == NUM_CYCLES);
    Byte value = 1;
    assert(mem[0x00FF] == value, "Expected %b Got %b", value,  mem[0x00FF]);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_zp_can_rotate_a_negative_value() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROL_ZP;
        mem[0xFF01] = 0xFF;
        mem[0x00FF] = 0b11000001;
    };
    Byte value = 0b10000010;
    assert(used == NUM_CYCLES);
    assert(mem[0x00FF] == value, "Expected %b Got %b", value, mem[0x00FF]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_zp_x_can_rotate_zero() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.z_bool = cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROL_ZPX;
        mem[0xFF01] = 0xFF;
        mem[0x00FF + 0x10] = 0;
    };
    assert(used == NUM_CYCLES);
    Byte value = 1;
    assert(mem[0x00FF + 0x10] == value, "Expected %b Got %b", value,  mem[0x00FF + 0x10]);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_zp_x_can_rotate_a_negative_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROL_ZPX;
        mem[0xFF01] = 0xFF;
        mem[0x00FF + 0x10] = 0b11000001;
    };
    Byte value = 0b10000010;
    assert(used == NUM_CYCLES);
    assert(mem[0x00FF + 0x10] == value, "Expected %b Got %b", value, mem[0x00FF + 0x10]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_abs_can_rotate_zero() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.z_bool = cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROL_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 0;
    };
    assert(used == NUM_CYCLES);
    Byte value = 1;
    assert(mem[0x8000 ] == value, "Expected %b Got %b", value,  mem[0x8000]);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_abs_can_rotate_a_negative_value() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROL_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 0b11000001;
    };
    Byte value = 0b10000010;
    assert(used == NUM_CYCLES);
    assert(mem[0x8000] == value, "Expected %b Got %b", value, mem[0x8000]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_abs_x_can_rotate_values_of_one() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.z_bool = cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROL_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = 0;
    };
    assert(used == NUM_CYCLES);
    Byte value = 1;
    assert(mem[0x8000 + 0x10] == value, "Expected %b Got %b", value,  mem[0x8000 + 0x10]);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void rol_abs_x_can_rotate_a_negative_value() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROL_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = 0b11000001;
    };
    Byte value = 0b10000010;
    assert(used == NUM_CYCLES);
    assert(mem[0x8000 + 0x10] == value, "Expected %b Got %b", value, mem[0x8000 + 0x10]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}



/// ROR STARTS HERE

fn void ror_can_rotate_values_of_carry_flag_into_operand() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.a = 0;
        cpu.n_bool = cpu.z_bool = false;
        cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROR;
    };
    assert(used == NUM_CYCLES);
    Byte value = 0b10000000;
    assert(cpu.a == value, "Expected %b Got %b", value,  cpu.a);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}
        // ror_can_shift_a_value_into_carry_flag
fn void ror_an_shift_a_value_into_carry_flag() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.c_bool = cpu.z_bool = false;
        mem[0xFF00] = emu6502::INS_ROR;
        cpu.a = 1;
    };
    Byte value = 0;
    assert(used == NUM_CYCLES);
    assert(cpu.a == value, "Expected %b Got %b", value, cpu.a);
    assert(cpu.c_bool == true);
    assert(cpu.z_bool == true);
    assert(cpu.n_bool == false);
    verify_shift_flags();
}

fn void ror_zp_can_rotate_carry_flag_into_operand() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.z_bool = false;
        cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROR_ZP;
        mem[0xFF01] = 0xFF;
        mem[0x00FF] = 0;
    };
    assert(used == NUM_CYCLES);
    Byte value = 0b10000000;
    assert(mem[0x00FF] == value, "Expected %b Got %b", value,  mem[0x00FF]);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void ror_zp_an_shift_a_value_into_carry_flag() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROR_ZP;
        mem[0xFF01] = 0xFF;
        mem[0x00FF] = 1;
    };
    Byte value = 0;
    assert(used == NUM_CYCLES);
    assert(mem[0x00FF] == value, "Expected %b Got %b", value, mem[0x00FF]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}

fn void ror_zp_x_can_rotate_carry_flag_into_operand() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.z_bool = false;
        cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROR_ZPX;
        mem[0xFF01] = 0xFF;
        mem[0x00FF + 0x10] = 0;
    };
    assert(used == NUM_CYCLES);
    Byte value = 0b10000000;
    assert(mem[0x00FF + 0x10] == value, "Expected %b Got %b", value,  mem[0x00FF + 0x10]);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void ror_zp_x_an_shift_a_value_into_carry_flag() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROR_ZPX;
        mem[0xFF01] = 0xFF;
        mem[0x00FF + 0x10] = 1;
    };
    Byte value = 0;
    assert(used == NUM_CYCLES);
    assert(mem[0x00FF + 0x10] == value, "Expected %b Got %b", value, mem[0x00FF + 0x10]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}

fn void ror_abs_can_rotate_carry_flag_into_operand() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.z_bool = false;
        cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROR_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 0;
    };
    assert(used == NUM_CYCLES);
    Byte value = 0b10000000;
    assert(mem[0x8000 ] == value, "Expected %b Got %b", value,  mem[0x8000]);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void ror_abs_an_shift_a_value_into_carry_flag() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROR_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = 1;
    };
    Byte value = 0;
    assert(used == NUM_CYCLES);
    assert(mem[0x8000] == value, "Expected %b Got %b", value, mem[0x8000]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}

fn void ror_abs_x_can_rotate_carry_flag_into_operand() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.z_bool = false;
        cpu.c_bool = true;
        mem[0xFF00] = emu6502::INS_ROR_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = 0;
    };
    assert(used == NUM_CYCLES);
    Byte value = 0b10000000;
    assert(mem[0x8000 + 0x10] == value, "Expected %b Got %b", value,  mem[0x8000 + 0x10]);
    assert(cpu.c_bool == false);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    verify_shift_flags();
}

fn void ror_abs_x_an_shift_a_value_into_carry_flag() @test {
    const Int32 NUM_CYCLES = 7;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.n_bool = cpu.c_bool = false;
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_ROR_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = 1;
    };
    Byte value = 0;
    assert(used == NUM_CYCLES);
    assert(mem[0x8000 + 0x10] == value, "Expected %b Got %b", value, mem[0x8000 + 0x10]);
    assert(cpu.c_bool == true);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    verify_shift_flags();
}
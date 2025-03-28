module emu6502::tests;
import emu6502;
import std::io;

macro void verify_logical_op_flags_unmodified() { // I would pass by ptr but not point..
    assert(cpu.c == copy.c);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
}

enum ELogicalOp{
    AND, EOR, OR
}


macro Byte do_logical_op(ELogicalOp op, Byte a, Byte b){
    switch(op){
        case AND:
            return a & b;
        case EOR:
            return a ^ b;
        case OR:
            return a | b;
    }
}

fn void and_immediate() @test => logical_op_on_immediate_value(ELogicalOp.AND);
fn void eor_immediate() @test => logical_op_on_immediate_value(ELogicalOp.EOR);
fn void ora_immediate() @test => logical_op_on_immediate_value(ELogicalOp.OR);

fn void logical_op_on_immediate_value(ELogicalOp op) { // PASS
    const Int32 NUM_CYCLES = 2;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.a = 0xCC;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_IM;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_IM;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_IM;
        }
        mem[0xFFFD] = 0x84;
    };
    assert(cycles_used == NUM_CYCLES);
    Byte expected_result = do_logical_op(op,  0xCC, 0x84);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result, "Expected: %d Got: %d", expected_result, cpu.a);
    assert(cpu.z_bool == false);
    assert(((bool) cpu.n) == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_immediate_effect_on_zero() @test => logical_op_on_immediate_value_can_effect_zero_flag(ELogicalOp.AND);
fn void eor_immediate_effect_on_zero() @test => logical_op_on_immediate_value_can_effect_zero_flag(ELogicalOp.EOR);
fn void ora_immediate_effect_on_zero() @test => logical_op_on_immediate_value_can_effect_zero_flag(ELogicalOp.OR);

fn void logical_op_on_immediate_value_can_effect_zero_flag(ELogicalOp op) { // Pass
    const Int32 NUM_CYCLES = 2;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.a = 0xCC;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_IM;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_IM;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_IM;
        }
        mem[0xFFFD] = 0x00;
    };
    assert(cycles_used == NUM_CYCLES);
    Byte expected_result = do_logical_op(op,  0xCC, 0);
    bool expected_zero = expected_result == 0;
    assert(cpu.z_bool == expected_zero);
    verify_logical_op_flags_unmodified();
}

fn void and_on_zero_page() @test => logical_op_on_zero_page(ELogicalOp.AND);
fn void eor_on_zero_page() @test => logical_op_on_zero_page(ELogicalOp.EOR);
fn void ora_on_zero_page() @test => logical_op_on_zero_page(ELogicalOp.OR);


fn void logical_op_on_zero_page(ELogicalOp op) { // PASS
    const Int32 NUM_CYCLES = 3;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.a = 0xCC;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_ZP;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_ZP;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_ZP;
        }
        mem[0xFFFD] = 0x42;
        mem[0x0042] = 0x37;
    };
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result);
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_zero_page_x() @test => logical_op_on_zero_page_x(ELogicalOp.AND);
fn void eor_on_zero_page_x() @test => logical_op_on_zero_page_x(ELogicalOp.EOR);
fn void ora_on_zero_page_x() @test => logical_op_on_zero_page_x(ELogicalOp.OR);

fn void logical_op_on_zero_page_x(ELogicalOp op) { // FAIL
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.x = 0x05;
        cpu.a = 0xCC;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_ZPX;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_ZPX;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_ZPX;
        }
        mem[0xFFFD] = 0x42;
        mem[0x0047] = 0x37;
    };
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result);
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_absolute() @test => logical_op_on_absolute(ELogicalOp.AND);
fn void eor_on_absolute() @test => logical_op_on_absolute(ELogicalOp.EOR);
fn void ora_on_absolute() @test => logical_op_on_absolute(ELogicalOp.OR); 

fn void logical_op_on_absolute(ELogicalOp op) { // Pass
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = cpu.n_bool = true;
        cpu.a = 0xCC;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_ABS;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_ABS;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_ABS;
        }
        mem[0xFFFD] = 0x80;
        mem[0xFFFE] = 0x44;
        mem[0x4480] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_absolute_x() @test => logical_op_on_absolute_x(ELogicalOp.AND);
fn void eor_on_absolute_x() @test => logical_op_on_absolute_x(ELogicalOp.EOR);
fn void ora_on_absolute_x() @test => logical_op_on_absolute_x(ELogicalOp.OR); 

fn void logical_op_on_absolute_x(ELogicalOp op) {  // Pass
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.x = 1;
        cpu.a = 0xCC;
        cpu.z_bool = cpu.n_bool = true;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_ABSX;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_ABSX;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_ABSX;
        }
        mem[0xFFFD] = 0x80;
        mem[0xFFFE] = 0x44;
        mem[0x4481] = 0x37;
    };
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cycles_used == NUM_CYCLES, "Expected: %d cycles Got: %d", NUM_CYCLES, cycles_used);
    assert(cpu.a == expected_result);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_absolute_x_when_crossing_page() @test => logical_op_on_absolute_x_when_crossing_page(ELogicalOp.AND); // Pass
fn void eor_on_absolute_x_when_crossing_page() @test => logical_op_on_absolute_x_when_crossing_page(ELogicalOp.EOR); // Pass
fn void ora_on_absolute_x_when_crossing_page() @test => logical_op_on_absolute_x_when_crossing_page(ELogicalOp.OR);  // Pass

fn void logical_op_on_absolute_x_when_crossing_page(ELogicalOp op) {    // Pass 
    const Int32 NUM_CYCLES = 5;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.a = 0xCC;
        cpu.x = 0xFF;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_ABSX;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_ABSX;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_ABSX;
        }
        mem[0xFFFD] = 0x02;
        mem[0xFFFE] = 0x44;
        mem[0x4501] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_absolute_y() @test => logical_op_on_absolute_y(ELogicalOp.AND);
fn void eor_on_absolute_y() @test => logical_op_on_absolute_y(ELogicalOp.EOR);
fn void ora_on_absolute_y() @test => logical_op_on_absolute_y(ELogicalOp.OR);

fn void logical_op_on_absolute_y(ELogicalOp op) {   // Pass 
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.y = 1;
        cpu.a = 0xCC;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_ABSY;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_ABSY;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_ABSY;
        }
        mem[0xFFFD] = 0x80;
        mem[0xFFFE] = 0x44;
        mem[0x4481] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_absolute_y_when_crossing_page() @test => logical_op_on_absolute_y_when_crossing_page(ELogicalOp.AND);
fn void eor_on_absolute_y_when_crossing_page() @test => logical_op_on_absolute_y_when_crossing_page(ELogicalOp.EOR);
fn void ora_on_absolute_y_when_crossing_page() @test => logical_op_on_absolute_y_when_crossing_page(ELogicalOp.OR);

fn void logical_op_on_absolute_y_when_crossing_page(ELogicalOp op) {   // Pass 
    const Int32 NUM_CYCLES = 5;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.y = 0xFF;
        cpu.a = 0xCC;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_ABSY;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_ABSY;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_ABSY;
        }
        mem[0xFFFD] = 0x02;
        mem[0xFFFE] = 0x44;
        mem[0x4501] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES, "Expected %d Cycles Got %d", NUM_CYCLES, cycles_used);
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result,"Expected %d Got %d", expected_result, cpu.a);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_indirect_x() @test => logical_op_on_indirect_x(ELogicalOp.AND);
fn void eor_on_indirect_x() @test => logical_op_on_indirect_x(ELogicalOp.EOR);
fn void ora_on_indirect_x() @test => logical_op_on_indirect_x(ELogicalOp.OR);

fn void logical_op_on_indirect_x(ELogicalOp op) {  // Pass 
    const Int32 NUM_CYCLES = 6;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = cpu.n_bool = true;
 		cpu.a = 0xCC;
 		cpu.x = 0x04;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_INDX;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_INDX;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_INDX;
        }
        mem[0xFFFD] = 0x02;
        mem[0x0006] = 0x00;
        mem[0x0007] = 0x80;
        mem[0x8000] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_indirect_y() @test => logical_op_on_indirect_y(ELogicalOp.AND);
fn void eor_on_indirect_y() @test => logical_op_on_indirect_y(ELogicalOp.EOR);
fn void ora_on_indirect_y() @test => logical_op_on_indirect_y(ELogicalOp.OR);

fn void logical_op_on_indirect_y(ELogicalOp op) {  // PASS 
    const Int32 NUM_CYCLES = 5;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = cpu.n_bool = true;
 		cpu.a = 0xCC;
 		cpu.y = 0x04;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_INDY;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_INDY;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_INDY;
        }
        mem[0xFFFD] = 0x02;
        mem[0x0002] = 0x00;
        mem[0x0003] = 0x80;
        mem[0x8004] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}

fn void and_on_indirect_y_when_crossing_page() @test => logical_op_on_indirect_y_when_crossing_page(ELogicalOp.AND);
fn void eor_on_indirect_y_when_crossing_page() @test => logical_op_on_indirect_y_when_crossing_page(ELogicalOp.EOR);
fn void ora_on_indirect_y_when_crossing_page() @test => logical_op_on_indirect_y_when_crossing_page(ELogicalOp.OR);

fn void logical_op_on_indirect_y_when_crossing_page(ELogicalOp op) {  // PASS 
    const Int32 NUM_CYCLES = 6;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = cpu.n_bool = true;
 		cpu.a = 0xCC;
 		cpu.y = 0xFF;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_INDY;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_INDY;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_INDY;
        }
        mem[0xFFFD] = 0x02;
        mem[0x0002] = 0x02;
        mem[0x0003] = 0x80;
        mem[0x8101] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES, "Expected %d cycles Got %d", NUM_CYCLES, cycles_used);
    Byte expected_result = do_logical_op(op,  0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == expected_negative);
    verify_logical_op_flags_unmodified();
}


fn void and_on_zero_page_x_on_wrap() @test => logical_op_on_zero_page_x_on_wrap(ELogicalOp.AND);
fn void eor_on_zero_page_x_on_wrap() @test => logical_op_on_zero_page_x_on_wrap(ELogicalOp.EOR);
fn void ora_on_zero_page_x_on_wrap() @test => logical_op_on_zero_page_x_on_wrap(ELogicalOp.OR);

fn void logical_op_on_zero_page_x_on_wrap(ELogicalOp op) { // FAIL
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        // cpu.z_bool = cpu.n_bool = true;
 		cpu.a = 0xCC;
 		cpu.x = 0xFF;
        switch(op){
            case AND: mem[0xFFFC] = emu6502::INS_AND_ZPX;
            case EOR: mem[0xFFFC] = emu6502::INS_EOR_ZPX;
            case OR: mem[0xFFFC] = emu6502::INS_ORA_ZPX;
        }
        mem[0xFFFD] = 0x80;
        mem[0x017F] = 0x37;
    };
    // How??
    // Expected: and => 4
    // Result: 0
    // Expected: ora => 255
    // Result: 204
    // Expected: eor => 251
    // Result: 204
    assert(cycles_used == NUM_CYCLES);
    Word expected_result = do_logical_op(op, 0xCC, 0x37);
    bool expected_negative = (expected_result & emu6502::NEGATIVE_FLAG) > 0;
    assert(cpu.a == expected_result, "Expected %d Got %d", expected_result , cpu.a);
    assert(cpu.z == 0);
    assert(( (bool) cpu.n )== expected_negative);
    verify_logical_op_flags_unmodified();
}


macro verify_bit_flags_unmodified(){
    assert(cpu.c == copy.c);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
}

fn void bit_zp_testing() @test {
    const Int32 NUM_CYCLES = 3;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z = 1;
        cpu.v = cpu.n = 0;
        cpu.a = 0xCC;
        mem[0xFFFC] = emu6502::INS_BIT_ZP;
        mem[0xFFFD] = 0x0042;
        mem[0x0042] = 0xCC;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0xCC == cpu.a);
    assert(false == cpu.z_bool);
    assert(true == cpu.v_bool);
    assert(true == cpu.n_bool);
    verify_bit_flags_unmodified();
}

fn void bit_zp_testing_z() @test {
    const Int32 NUM_CYCLES = 3;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z = 0;
        cpu.v = cpu.n = 1;
        cpu.a = 0xCC;
        mem[0xFFFC] = emu6502::INS_BIT_ZP;
        mem[0xFFFD] = 0x42;
        mem[0x0042] = 0x33;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0xCC == cpu.a);
    assert(true == cpu.z_bool);
    assert(false == cpu.v_bool);
    assert(false == cpu.n_bool);
    verify_bit_flags_unmodified();
}

fn void bit_zp_testing_z_inverse() @test {
    const Int32 NUM_CYCLES = 3;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = cpu.v_bool = cpu.n_bool = true;
        cpu.a = 0x33;
        mem[0xFFFC] = emu6502::INS_BIT_ZP;
        mem[0xFFFD] = 0x42;
        mem[0x0042] = 0xCC;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0x33 == cpu.a);
    assert(true == cpu.z_bool);
    assert(true == cpu.v_bool);
    assert(true == cpu.n_bool);
    verify_bit_flags_unmodified();
}

fn void bit_zp_testing_v() @test {
    const Int32 NUM_CYCLES = 3;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = cpu.n_bool = true;
        cpu.v_bool = false;
        cpu.a = 0x33;
        mem[0xFFFC] = emu6502::INS_BIT_ZP;
        mem[0xFFFD] = 0x42;
        mem[0x0042] = emu6502::OVERFLOW_FLAG;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0x33 == cpu.a);
    assert(true == cpu.v_bool);
    assert(false == cpu.n_bool);
    verify_bit_flags_unmodified();
}

fn void bit_abs_testing() @test {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = true;
        cpu.v_bool = cpu.n_bool = false;
        cpu.a = 0xCC;
        mem[0xFFFC] = emu6502::INS_BIT_ABS;
        mem[0xFFFD] = 0x00;
        mem[0xFFFE] = 0x80;
        mem[0x8000] = 0xCC;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0xCC == cpu.a);
    assert(false == cpu.z_bool);
    assert(true == cpu.v_bool);
    assert(true == cpu.n_bool);
    verify_bit_flags_unmodified();
}

fn void bit_abs_testing_z() @test {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = false;
        cpu.v_bool = cpu.n_bool = true;
        cpu.a = 0xCC;
        mem[0xFFFC] = emu6502::INS_BIT_ABS;
        mem[0xFFFD] = 0x00;
        mem[0xFFFE] = 0x80;
        mem[0x8000] = 0x33;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(true == cpu.z_bool);
    assert(false == cpu.v_bool);
    assert(false == cpu.n_bool);
    verify_bit_flags_unmodified();
}

fn void bit_abs_testing_z_inverse() @test {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z_bool = cpu.v_bool = cpu.n_bool = false;
        cpu.a = 0x33;
        mem[0xFFFC] = emu6502::INS_BIT_ABS;
        mem[0xFFFD] = 0x00;
        mem[0xFFFE] = 0x80;
        mem[0x8000] = 0xCC;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0x33 == cpu.a);
    assert(true == cpu.z_bool);
    assert(true == cpu.v_bool);
    assert(true == cpu.n_bool);
    verify_bit_flags_unmodified();
}

fn void bit_abs_testing_v() @test {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.v_bool = true;
        cpu.z_bool = cpu.n_bool = false;
        cpu.a = 0x33;
        mem[0xFFFC] = emu6502::INS_BIT_ABS;
        mem[0xFFFD] = 0x00;
        mem[0xFFFE] = 0x80;
        mem[0x8000] = emu6502::OVERFLOW_FLAG;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0x33 == cpu.a);
    assert(true == cpu.v_bool);
    assert(false == cpu.n_bool);
    verify_bit_flags_unmodified();
}

/*
* = $1000

lda #$FF

start
sta $90
sta $8000
eor #$CC
jmp start
*/
const Byte[*] TEST_PRG_1 = { 0x00, 0x10, 0xa9, 0xff, 0x85, 0x90, 0x8d, 0x00, 0x80, 0x49, 0xcc, 0x4c, 0x02, 0x10, };
fn void load_prg_into_correct_area() @test {
    cpu.init(&mem);
    cpu.load_prg(TEST_PRG_1[0..], &mem);
    assert(mem[0x0FFF] == TEST_PRG_1[0]);
    //NOTE: Start at 2 because first 2 bits are the address of where to start
    assert(mem[0x1000] == TEST_PRG_1[2]);
    assert(mem[0x1001] == TEST_PRG_1[3]);
    assert(mem[0x1002] == TEST_PRG_1[4]);
    assert(mem[0x1003] == TEST_PRG_1[5]);
    assert(mem[0x1004] == TEST_PRG_1[6]);
    assert(mem[0x1005] == TEST_PRG_1[7]);
    assert(mem[0x1006] == TEST_PRG_1[8]);
    assert(mem[0x1007] == TEST_PRG_1[9]);
    assert(mem[0x1008] == TEST_PRG_1[10]);
    assert(mem[0x1009] == TEST_PRG_1[11]);
    assert(mem[0x100A] == TEST_PRG_1[12]);
    assert(mem[0x100B] == TEST_PRG_1[13]);
}

fn void run_test_prg() @test {
    cpu.init(&mem);
    cpu.pc = cpu.load_prg(TEST_PRG_1[0..], &mem);
   
    for(Int32 clock = 1000; clock > 0; ){
        clock -= cpu.exec(1, &mem)!!;
    }
}
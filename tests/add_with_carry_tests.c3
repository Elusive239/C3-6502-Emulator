module emu6502::tests;
import emu6502;

macro verify_adc_untouched() {
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
}

struct ADCTestData{
    Byte a;
    Byte operand;
    Byte carry;
    Byte answer;
    bool expectC;
    bool expectZ;
    bool expectN;
    bool expectV;
}


fn void adc_abs_add_zero_and_zero_and_get_zero() @test => test_adc_abs(ADCTestData{
    .a = 0,
    .operand = 0,
    .carry = 0,
    .expectC = false,
    .expectZ = true,
    .expectN = false,
    .expectV = false,
    .answer = 0
});

fn void adc_abs_add_zero_and_zero_and_get_one() @test => test_adc_abs(ADCTestData{
    .a = 0,
    .operand = 0,
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 1
});

fn void adc_abs_add_one_to_ff_and_carry() @test => test_adc_abs(ADCTestData{
    .a = 0xFF,
    .operand = 0x01,
    .carry = 0,
    .expectC = true,
    .expectZ = true,
    .expectN = false,
    .expectV = false,
    .answer = 0
});

fn void adc_abs_will_set_the_negative_flag_when_the_result_is_negative() @test => test_adc_abs(ADCTestData{
    .a = 0,
    .operand = 0b10000001,
    .carry = 0,
    .expectC = false,
    .expectZ = false,
    .expectN = true,
    .expectV = false,
    .answer = 0b10000001
});

//when signed addition fails..
fn void adc_abs_overflow_bit_negative_test() @test => test_adc_abs(ADCTestData{
    .a = 0b10000000, // -128
    .operand = 0b11111111, //-1
    .carry = 0,
    .expectC = true,
    .expectZ = false,
    .expectN = false,
    .expectV = true,
    .answer = (Byte)(0b10000000 + 0b11111111) //127
});

//when signed addition fails..
fn void adc_abs_overflow_bit_positive_test() @test => test_adc_abs(ADCTestData{
    .a = 127, 
    .operand = 1, 
    .carry = 0,
    .expectC = false,
    .expectZ = false,
    .expectN = true,
    .expectV = true,
    .answer = 128 //127
});

fn void adc_abs_two_unsigned_numbers() @test => test_adc_abs(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 38 //127
});

fn void adc_abs_signed_and_unsigned_numbers() @test => test_adc_abs(ADCTestData{
    .a = 20, 
    .operand = emu6502::@negative_to_byte(-17), 
    .carry = 1,
    .expectC = true,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 4 //127
});

fn void adc_abs_overflow_flag_when_signed_negative() @test => test_adc_abs(ADCTestData{
    .a = emu6502::@negative_to_byte(-128),
    .operand = emu6502::@negative_to_byte(-1), 
    .carry = 1,
    .expectC = true,
    .expectZ = false,
    .expectN = true,
    .expectV = false,
    .answer = emu6502::@negative_to_byte(-128)
});


fn void test_adc_abs(ADCTestData tdata, bool sub = false) {
    const Int32 NUM_CYCLES = 4;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.a = tdata.a;
        cpu.c = tdata.carry;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.v_bool = !tdata.expectV;
        mem[0xFF00] = sub ? emu6502::INS_SBC_ABS : emu6502::INS_ADC_ABS;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000] = tdata.operand;
    };
    
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.answer, "Expected %d, Got %d", tdata.answer, cpu.a);
    assert(cpu.c_bool == tdata.expectC);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.v_bool == tdata.expectV);
    verify_adc_untouched();
}

fn void adc_im_two_unsigned_numbers() @test => test_adc_im(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 38 //127
});

fn void test_adc_im(ADCTestData tdata) {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.a = tdata.a;
        cpu.c = tdata.carry;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.v_bool = !tdata.expectV;
        mem[0xFF00] = emu6502::INS_ADC_IM;
        mem[0xFF01] = tdata.operand;
        // mem[0xFF02] = 0x80;
        // mem[0x8000] = tdata.operand;
    };
    
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.answer);
    assert(cpu.c_bool == tdata.expectC);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.v_bool == tdata.expectV);
    verify_adc_untouched();
}


fn void adc_zp_two_unsigned_numbers() @test => test_adc_zp(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 38 //127
});

fn void test_adc_zp(ADCTestData tdata) {
    const Int32 NUM_CYCLES = 3;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.a = tdata.a;
        cpu.c = tdata.carry;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.v_bool = !tdata.expectV;
        mem[0xFF00] = emu6502::INS_ADC_ZP;
        mem[0xFF01] = 0x50;
        mem[0x0050] = tdata.operand;
        // mem[0xFF02] = 0x80;
        // mem[0x8000] = tdata.operand;
    };
    
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.answer, "Expected %d Got %d", tdata.answer, cpu.a);
    assert(cpu.c_bool == tdata.expectC);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.v_bool == tdata.expectV);
    verify_adc_untouched();
}

fn void adc_zp_x_two_unsigned_numbers() @test => test_adc_zp_x(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 38 //127
});

fn void test_adc_zp_x(ADCTestData tdata) {
    const Int32 NUM_CYCLES = 4;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.a = tdata.a;
        cpu.c = tdata.carry;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.v_bool = !tdata.expectV;
        mem[0xFF00] = emu6502::INS_ADC_ZPX;
        mem[0xFF01] = 0x50;
        mem[0x0050 + 0x10] = tdata.operand;
        // mem[0xFF02] = 0x80;
        // mem[0x8000] = tdata.operand;
    };
    
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.answer, "Expected %d Got %d", tdata.answer, cpu.a);
    assert(cpu.c_bool == tdata.expectC);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.v_bool == tdata.expectV);
    verify_adc_untouched();
}

fn void adc_abs_x_two_unsigned_numbers() @test => test_adc_abs_x(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 38 //127
});

fn void test_adc_abs_x(ADCTestData tdata) {
    const Int32 NUM_CYCLES = 4;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x10;
        cpu.a = tdata.a;
        cpu.c = tdata.carry;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.v_bool = !tdata.expectV;
        mem[0xFF00] = emu6502::INS_ADC_ABSX;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = tdata.operand;
        // mem[0xFF02] = 0x80;
        // mem[0x8000] = tdata.operand;
    };
    
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.answer, "Expected %d Got %d", tdata.answer, cpu.a);
    assert(cpu.c_bool == tdata.expectC);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.v_bool == tdata.expectV);
    verify_adc_untouched();
}

fn void adc_abs_y_two_unsigned_numbers() @test => test_adc_abs_y(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 38 //127
});

fn void test_adc_abs_y(ADCTestData tdata) {
    const Int32 NUM_CYCLES = 4;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.y = 0x10;
        cpu.a = tdata.a;
        cpu.c = tdata.carry;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.v_bool = !tdata.expectV;
        mem[0xFF00] = emu6502::INS_ADC_ABSY;
        mem[0xFF01] = 0x00;
        mem[0xFF02] = 0x80;
        mem[0x8000 + 0x10] = tdata.operand;
        // mem[0xFF02] = 0x80;
        // mem[0x8000] = tdata.operand;
    };
    
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.answer, "Expected %d Got %d", tdata.answer, cpu.a);
    assert(cpu.c_bool == tdata.expectC);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.v_bool == tdata.expectV);
    verify_adc_untouched();
}

fn void adc_indx_two_unsigned_numbers() @test => test_adc_indx(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 38 //127
});

fn void test_adc_indx(ADCTestData tdata) {
    const Int32 NUM_CYCLES = 6;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.x = 0x04;
        cpu.a = tdata.a;
        cpu.c = tdata.carry;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.v_bool = !tdata.expectV;
        mem[0xFF00] = emu6502::INS_ADC_INDX;
        mem[0xFF01] = 0x02;
        mem[0x0006] = 0x00;
        mem[0x0007] = 0x80;
        mem[0x8000] = tdata.operand;
        // mem[0xFF02] = 0x80;
        // mem[0x8000] = tdata.operand;
    };
    
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.answer, "Expected %d Got %d", tdata.answer, cpu.a);
    assert(cpu.c_bool == tdata.expectC);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.v_bool == tdata.expectV);
    verify_adc_untouched();
}

fn void adc_indy_two_unsigned_numbers() @test => test_adc_indy(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 38 //127
});

fn void test_adc_indy(ADCTestData tdata) {
    const Int32 NUM_CYCLES = 5;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00) {
        cpu.y = 0x04;
        cpu.a = tdata.a;
        cpu.c = tdata.carry;
        cpu.z_bool = !tdata.expectZ;
        cpu.n_bool = !tdata.expectN;
        cpu.v_bool = !tdata.expectV;
        mem[0xFF00] = emu6502::INS_ADC_INDY;
        mem[0xFF01] = 0x02;
        mem[0x0002] = 0x00;
        mem[0x0003] = 0x80;
        mem[0x8000 + 0x04] = tdata.operand;
        // mem[0xFF02] = 0x80;
        // mem[0x8000] = tdata.operand;
    };
    
    assert(used == NUM_CYCLES);
    assert(cpu.a == tdata.answer, "Expected %d Got %d", tdata.answer, cpu.a);
    assert(cpu.c_bool == tdata.expectC);
    assert(cpu.z_bool == tdata.expectZ);
    assert(cpu.n_bool == tdata.expectN);
    assert(cpu.v_bool == tdata.expectV);
    verify_adc_untouched();
}


fn void sbc_abs_sub_zero_and_zero_and_get_zero() @test => test_adc_abs(ADCTestData{
    .a = 0,
    .operand = 0,
    .carry = 1,
    .expectC = true,
    .expectZ = true,
    .expectN = false,
    .expectV = false,
    .answer = 0
}, true);

fn void sbc_abs_sub_zero_and_one_and_get_negative_one() @test => test_adc_abs(ADCTestData{
    .a = 0,
    .operand = 1,
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = true,
    .expectV = false,
    .answer = emu6502::@negative_to_byte(-1),
}, true);

fn void sbc_abs_sub_zero_and_one_with_cary_and_get_negative_two() @test => test_adc_abs(ADCTestData{
    .a = 0,
    .operand = 1,
    .carry = 0,
    .expectC = false,
    .expectZ = false,
    .expectN = true,
    .expectV = false,
    .answer = emu6502::@negative_to_byte(-2),
}, true);

fn void sbc_abs_can_sub_two_negative_numbers() @test => test_adc_abs(ADCTestData{
    .a = emu6502::@negative_to_byte(-128),
    .operand = 1,
    .carry = 1,
    .expectC = true,
    .expectZ = false,
    .expectN = false,
    .expectV = true,
    .answer = 127,
}, true);

fn void sbc_abs_can_sub_pos_and_neg_number_and_get_pos() @test => test_adc_abs(ADCTestData{
    .a = 127,
    .operand = emu6502::@negative_to_byte(-1),
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = true,
    .expectV = true,
    .answer = 128,
}, true);

fn void sbc_abs_zero_from_zero_and_carry() @test => test_adc_abs(ADCTestData{
    .a = 0,
    .operand = 0,
    .carry = 0,
    .expectC = false,
    .expectZ = false,
    .expectN = true,
    .expectV = false,
    .answer = emu6502::@negative_to_byte(-1),
}, true);

fn void sbc_abs_two_unsigned_numbers() @test => test_adc_abs(ADCTestData{
    .a = 20, 
    .operand = 17, 
    .carry = 1,
    .expectC = true,
    .expectZ = false,
    .expectN = false,
    .expectV = false,
    .answer = 3 //127
}, true);

fn void sbc_abs_two_negative_numbers() @test => test_adc_abs(ADCTestData{
    .a = emu6502::@negative_to_byte(-20), 
    .operand = emu6502::@negative_to_byte(-17), 
    .carry = 1,
    .expectC = false,
    .expectZ = false,
    .expectN = true,
    .expectV = false,
    .answer = emu6502::@negative_to_byte(-3) //127
}, true);
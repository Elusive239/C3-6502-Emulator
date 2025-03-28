module emu6502::tests;
import emu6502;

macro void verify_ld_flags_unmodified() { // I would pass by ptr but not point..
    assert(cpu.c == copy.c);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
}

fn void cpu_no_cycles() @test {
    Int32 cycles = 0;
    Int32 cycles_used = cpu.exec(cycles, &mem)!!;
    assert(cycles_used == cycles);
}

fn void execute_more_than_required_cycles() @test { 
    const Int32 NUM_CYCLES = 1;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        mem[0xFFFC] = emu6502::INS_LDA_IM;
        mem[0xFFFD] = 0x84;
    };
    assert(cycles_used > NUM_CYCLES);
}

fn void lda_immediate_load_value_into_a_reg() @test { 
    @test_immediate_load_register(emu6502::INS_LDA_IM, cpu.a);
}

fn void ldx_immediate_load_value_into_x_reg() @test { 
    @test_immediate_load_register(emu6502::INS_LDX_IM, cpu.x);
}

fn void ldy_immediate_load_value_into_y_reg() @test { 
    @test_immediate_load_register(emu6502::INS_LDY_IM, cpu.y);
}

macro @test_immediate_load_register(Byte opCode, #register){
    const Int32 NUM_CYCLES = 2;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x84;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(#register == 0x84);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == true);
    verify_ld_flags_unmodified();
}

fn void lda_immediate_can_affect_zero_flag() @test { 
    const Int32 NUM_CYCLES = 2;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.a = 0x44;
        mem[0xFFFC] = emu6502::INS_LDA_IM;
        mem[0xFFFD] = 0x00;
    };
    assert(cpu.z_bool == true);
    assert(cpu.n_bool == false);
    verify_ld_flags_unmodified();
}

macro @test_zero_page_can_load_value_into_register(Byte opCode, #register){
    const Int32 NUM_CYCLES = 3;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x42;
        mem[0x0042] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(#register == 0x37);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == false);
    verify_ld_flags_unmodified();
}

fn void lda_zero_page_can_load_value_into_a_reg() @test { 
    @test_zero_page_can_load_value_into_register(emu6502::INS_LDA_ZP, cpu.a);
}

fn void ldx_zero_page_can_load_value_into_a_reg() @test { 
    @test_zero_page_can_load_value_into_register(emu6502::INS_LDX_ZP, cpu.x);
}

fn void ldy_zero_page_can_load_value_into_a_reg() @test { 
    @test_zero_page_can_load_value_into_register(emu6502::INS_LDY_ZP, cpu.y);
}

macro @test_zero_page_x_can_load_value_into_register(Byte opCode, #register){
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.x = 5;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x42;
        mem[0x0047] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(#register == 0x37);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == false);
    verify_ld_flags_unmodified();
}

fn void lda_zero_page_x_can_load_value_into_a_reg() @test { 
    @test_zero_page_x_can_load_value_into_register(emu6502::INS_LDA_ZPX, cpu.a);
}

fn void ldx_zero_page_y_can_load_value_into_a_reg() @test { 
    // @test_zero_page_x_can_load_value_into_register(emu6502::INS_LDX_ZPY, cpu.x);
    // TODO: not yet implemented!!;
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.y = 5;
        mem[0xFFFC] = emu6502::INS_LDX_ZPY;
        mem[0xFFFD] = 0x42;
        mem[0x0047] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.x == 0x37);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == false);
    verify_ld_flags_unmodified();
}

fn void ldy_zero_page_x_can_load_value_into_a_reg() @test { 
    @test_zero_page_x_can_load_value_into_register(emu6502::INS_LDY_ZPX, cpu.y);
}

fn void lda_zero_page_x_can_load_value_into_a_reg_when_it_wraps() @test { 
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.x = 0xFF;
        mem[0xFFFC] = emu6502::INS_LDA_ZPX;
        mem[0xFFFD] = 0x80;
        mem[0x017F] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES, "Expected %d cycles, got %d", NUM_CYCLES, cycles_used);
    assert(cpu.a == 0x37, "Expected: %d Got in %s: %d", 0x37 ,$stringify(cpu.a), cpu.a);
    assert(cpu.z_bool == false, "Zero Flag Set");
    assert(cpu.n == 0, "Negative Flag Set");
    verify_ld_flags_unmodified();
}

macro @test_ld_absolute_can_load_a_value_into_register(Byte opCode, #register) {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.z = cpu.n = 1;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x80;
        mem[0xFFFE] = 0x44;
        mem[0x4480] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(#register == 0x37);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == false);
    verify_ld_flags_unmodified();
}

fn void lda_absolute_can_load_a_value_into_the_a_reg() @test {
    @test_ld_absolute_can_load_a_value_into_register( emu6502::INS_LDA_ABS , cpu.a);
}

fn void ldx_absolute_can_load_a_value_into_the_x_reg() @test {
    @test_ld_absolute_can_load_a_value_into_register( emu6502::INS_LDX_ABS ,cpu.x);
}

fn void ldy_absolute_can_load_a_value_into_the_y_reg() @test {
    @test_ld_absolute_can_load_a_value_into_register( emu6502::INS_LDY_ABS ,cpu.y);
}


macro @test_ld_absolute_x_can_load_a_value_into_register(Byte opCode, #register) {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.x = 1;
        cpu.z = cpu.n = 1;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x80;
        mem[0xFFFE] = 0x44;
        mem[0x4481] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES, "Expected %d cycles, got %d", NUM_CYCLES, cycles_used);
    assert(#register == 0x37, "Expected: %d Got in %s: %d", 0x37 ,$stringify(#register), #register);
    assert(cpu.z_bool == false, "Zero Flag Set");
    assert(cpu.n == 0, "Negative Flag Set");
    verify_ld_flags_unmodified();
}

fn void lda_absolute_x_can_load_a_value_int_the_a_reg() @test {
    @test_ld_absolute_x_can_load_a_value_into_register(emu6502::INS_LDA_ABSX, cpu.a);
}

fn void ldy_absolute_x_can_load_a_value_int_the_a_reg() @test {
    @test_ld_absolute_x_can_load_a_value_into_register(emu6502::INS_LDY_ABSX, cpu.y);
}

macro @test_ld_absolute_x_can_load_a_value_int_the_a_reg_when_crossing_page_boundry(Byte opCode, #register, #expect) {
    const Int32 NUM_CYCLES = #expect;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.x = 0x01;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0xFF;
        mem[0xFFFE] = 0x44;
        mem[0x4500] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES, "Expected %d cycles, got %d", NUM_CYCLES, cycles_used);
    assert(#register == 0x37, "Expected: %d Got in %s: %d", 0x37 ,$stringify(#register), #register);
    assert(cpu.z_bool == false, "Zero Flag Set");
    assert(cpu.n == 0, "Negative Flag Set");
    verify_ld_flags_unmodified();
}

fn void lda_absolute_x_can_load_a_value_int_the_a_reg_when_crossing_page_boundry() @test { //fail
    @test_ld_absolute_x_can_load_a_value_int_the_a_reg_when_crossing_page_boundry(emu6502::INS_LDA_ABSX, cpu.a, 5);
}

fn void ldy_absolute_x_can_load_a_value_int_the_a_reg_when_crossing_page_boundry() @test {
    @test_ld_absolute_x_can_load_a_value_int_the_a_reg_when_crossing_page_boundry(emu6502::INS_LDY_ABSX, cpu.y, 5);
}

macro @test_ld_absolute_y_can_load_a_value_into_register(Byte opCode, #register, #expect) {
    const Int32 NUM_CYCLES = #expect; //4
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.y = 1;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x80;
        mem[0xFFFE] = 0x44;
        mem[0x4481] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES, "Expected %d cycles, got %d", NUM_CYCLES, cycles_used);
    assert(#register == 0x37, "Expected: %d Got in %s: %d", 0x37 ,$stringify(#register), #register);
    assert(cpu.z_bool == false, "Zero Flag Set");
    assert(cpu.n == 0, "Negative Flag Set");
    verify_ld_flags_unmodified();
}

fn void lda_absolute_y_can_load_a_value_int_the_a_reg() @test {
    @test_ld_absolute_y_can_load_a_value_into_register(emu6502::INS_LDA_ABSY,cpu.a, 4);
}

fn void ldx_absolute_y_can_load_a_value_int_the_a_reg() @test { // pass
    @test_ld_absolute_y_can_load_a_value_into_register(emu6502::INS_LDX_ABSY,cpu.x, 4);
}

macro @test_ld_absolute_y_can_load_a_value_into_register_when_crossing_page_boundry(Byte opCode, #register, #expect) {
    Int32 num_cycles = #expect;
    Int32 cycles_used = @test_init(num_cycles){
        cpu.y = 0x01;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0xFF;
        mem[0xFFFE] = 0x44; // 0x44FF + 0x01 = 0x4500
        mem[0x4500] = 0x37;
    };
    assert(cycles_used == num_cycles, "Expected %d cycles, got %d", num_cycles, cycles_used);
    assert(#register == 0x37, "Expected: %d Got in %s: %d", 0x37 ,$stringify(#register), #register);
    assert(cpu.z_bool == false, "Zero Flag Set");
    assert(cpu.n == 0, "Negative Flag Set");
    verify_ld_flags_unmodified();
}

fn void lda_absolute_y_can_load_a_value_int_the_a_reg_when_crossing_page_boundry() @test {
    @test_ld_absolute_y_can_load_a_value_into_register_when_crossing_page_boundry(emu6502::INS_LDA_ABSY, cpu.a, 5);
}

fn void ldx_absolute_y_can_load_a_value_int_the_a_reg_when_crossing_page_boundry() @test {
    @test_ld_absolute_y_can_load_a_value_into_register_when_crossing_page_boundry(emu6502::INS_LDX_ABSY, cpu.x, 5);
}

fn void lda_indirect_x_can_load_a_value_int_the_a_reg() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.x = 4;
        mem[0xFFFC] = emu6502::INS_LDA_INDX;
        mem[0xFFFD] = 0x02;
        mem[0x0006] = 0x00;
        mem[0x0007] = 0x80;
        mem[0x8000] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.a == 0x37);
    assert(cpu.z_bool == false);
    assert(cpu.n == 0);
    verify_ld_flags_unmodified();
}

fn void lda_indirect_y_can_load_a_value_int_the_a_reg() @test {
    const Int32 NUM_CYCLES = 5;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.y = 0x04;
        mem[0xFFFC] = emu6502::INS_LDA_INDY;
        mem[0xFFFD] = 0x02;
        mem[0x0002] = 0x00;
        mem[0x0003] = 0x80;
        mem[0x8004] = 0x37;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.a == 0x37);
    assert(cpu.z_bool == false);
    assert(cpu.n == 0);
    verify_ld_flags_unmodified();
}

fn void lda_indirect_y_can_load_a_value_int_the_a_reg_when_page_boundry_crossed() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.y = 0x01;
        mem[0xFFFC] = emu6502::INS_LDA_INDY;
        mem[0xFFFD] = 0x05;
        mem[0x0005] = 0xFF;
        mem[0x0006] = 0x80; //0x80FF + 0x01 = 0x8100
        mem[0x8100] = 0x37;
    };
    assert(cpu.a == 0x37);
    assert(cpu.z_bool == false);
    assert(cpu.n == 0);
    assert(cycles_used == NUM_CYCLES); // wrong cycles
    verify_ld_flags_unmodified();
}
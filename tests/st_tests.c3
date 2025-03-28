module emu6502::tests;
import emu6502;
import emulator;

macro void verify_st_flags_unmodified() { // I would pass by ptr but not point..
    assert(cpu.c == copy.c);
    assert(cpu.i == copy.i);
    assert(cpu.d == copy.d);
    assert(cpu.b == copy.b);
    assert(cpu.v == copy.v);
    assert(cpu.z == copy.z);
    assert(cpu.n == copy.n);
}

//  STA STX STY 
macro void @test_st_zp(Byte opCode, #register){
    const Int32 NUM_CYCLES = 3;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.#register = 0x2F;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x80;
        mem[0x0080] = 0x00;
    };
    // emulator::snapshot(string::tformat("test_st%s_zp", $stringify(#register)), &cpu, &mem);
    assert(cycles_used == NUM_CYCLES, "NUM_CYCLES: Got %d expected %d", cycles_used, NUM_CYCLES);
    assert( 0x2F == mem[0x0080], "MEM: Got %d expected %d", mem[0x0080], 0x2F);
    verify_st_flags_unmodified();
}

fn void sta_zp_can_store_the_a_reg_in_mem() @test {
    @test_st_zp(emu6502::INS_STA_ZP, a);
}

fn void stx_zp_can_store_the_a_reg_in_mem() @test {
    @test_st_zp(emu6502::INS_STX_ZP, x);
}

fn void sty_zp_can_store_the_a_reg_in_mem() @test {
    @test_st_zp(emu6502::INS_STY_ZP, y);
}

macro void @test_st_absolute(Byte opCode, #register) {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.#register = 0x23;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x00;
        mem[0xFFFE] = 0x80;
        mem[0x8000] = 0x00;
    };
    assert(cycles_used == NUM_CYCLES);
    assert( 0x23 == mem[0x8000]);
    verify_st_flags_unmodified();
}

fn void sta_abs_can_store_the_a_reg_in_mem() @test {
    @test_st_absolute(emu6502::INS_STA_ABS, a);
}

fn void stx_abs_can_store_the_x_reg_in_mem() @test {
    @test_st_absolute(emu6502::INS_STX_ABS, x);
}

fn void sty_abs_can_store_the_y_reg_in_mem() @test {
    @test_st_absolute(emu6502::INS_STY_ABS, y);
}

macro void @test_st_zp_x_can_store_the_x_reg_in_mem(Byte opCode, #register) {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.#register = 0x42;
        cpu.x = 0x0F;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x80;
        mem[0x008F] = 0x00;
        // emulator::snapshot(string::tformat("st%s_can_store_the_x_reg_in_mem",$stringify(#register)), &cpu, &mem);
    };
    assert(cycles_used == NUM_CYCLES);
    assert( 0x42 == mem[0x008F]);
    verify_st_flags_unmodified();
}

fn void sta_zp_x_can_store_the_x_reg_in_mem() @test {
    @test_st_zp_x_can_store_the_x_reg_in_mem(emu6502::INS_STA_ZPX, a);
}

fn void sty_zp_x_can_store_the_x_reg_in_mem() @test {
    @test_st_zp_x_can_store_the_x_reg_in_mem(emu6502::INS_STY_ZPX, y);
}

macro void @test_st_zp_y_can_store_the_y_reg_in_mem(Byte opCode, #register) {
    const Int32 NUM_CYCLES = 4;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.#register = 0x42;
        cpu.y = 0x0F;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x80;
        mem[0x008F] = 0x00;
    };
    assert(cycles_used == NUM_CYCLES);
    assert( 0x42 == mem[0x008F]);
    verify_st_flags_unmodified();
}

fn void stx_zp_y_can_store_the_y_reg_in_mem() @test {
    @test_st_zp_y_can_store_the_y_reg_in_mem(emu6502::INS_STX_ZPY, x);
}

macro void @test_abs_reg_can_store_the_a_reg_in_mem(Byte opCode, #register) {
    const Int32 NUM_CYCLES = 5;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.a = 0x42;
        cpu.#register = 0x0F;
        mem[0xFFFC] = opCode;
        mem[0xFFFD] = 0x00;
        mem[0xFFFE] = 0x80;
        // mem[0x800F] = 0x00;
    };
    assert(cycles_used == NUM_CYCLES, "Expected %d cycles got %d", NUM_CYCLES, cycles_used);
    assert( 0x42 == mem[0x800F], "Expected %d Got %d", 0x42 , mem[0x800F]);
    verify_st_flags_unmodified();
}

fn void sta_abs_x_can_store_the_a_reg_in_mem() @test {
    @test_abs_reg_can_store_the_a_reg_in_mem(emu6502::INS_STA_ABSX, x) ;
}

fn void sta_abs_y_can_store_the_a_reg_in_mem() @test {
    @test_abs_reg_can_store_the_a_reg_in_mem(emu6502::INS_STA_ABSY, y) ;
}

fn void sta_indirect_x_can_store_the_a_reg_in_mem() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.a = 0x42;
        cpu.x = 0x0F;
        mem[0xFFFC] = emu6502::INS_STA_INDX;
        mem[0xFFFD] = 0x20;
        mem[0x002F] = 0x00;
        mem[0x0030] = 0x80;
        mem[0x8000] = 0x00;
    };
    assert(cycles_used == NUM_CYCLES);
    assert( 0x42 == mem[0x8000]);
    verify_st_flags_unmodified();
}

fn void sta_indirect_y_can_store_the_a_reg_in_mem() @test {
    const Int32 NUM_CYCLES = 6;
    Int32 cycles_used = @test_init(NUM_CYCLES){
        cpu.a = 0x42;
        cpu.y = 0x0F;
        mem[0xFFFC] = emu6502::INS_STA_INDY;
        mem[0xFFFD] = 0x20;
        mem[0x0020] = 0x00;
        mem[0x0021] = 0x80;
        mem[0x8000 + 0x0F] = 0x00;
    };
    assert(cycles_used == NUM_CYCLES);
    assert( 0x42 == mem[0x8000 + 0x0F]);
    verify_st_flags_unmodified();
}
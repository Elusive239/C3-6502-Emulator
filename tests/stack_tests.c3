module emu6502::tests;
import emu6502;

fn void tsx_can_transfer_sp_to_x_reg() @test {
    const Int32 NUM_CYCLES = 2; // JSR + RET + LDA_IM
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z = cpu.n = 0xF | cpu.n;
        cpu.x = 0x00;
        cpu.sp = 0x01;
        mem[0xFF00] = emu6502::INS_TSX;
        mem[0xFF01] = 0x00; 
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0x01 == cpu.x);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == false);
}

fn void tsx_can_transfer_a_zero_sp_to_x_reg() @test {
    const Int32 NUM_CYCLES = 2; // JSR + RET + LDA_IM
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z = cpu.n = 0xF | cpu.n;
        cpu.x = 0x00;
        cpu.sp = 0b10000000;
        mem[0xFF00] = emu6502::INS_TSX;
        mem[0xFF01] = 0x00; 
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0b10000000 == cpu.x);
    assert(cpu.z_bool == false);
    assert(cpu.n_bool == true);
}

fn void tsx_can_transfer_a_negative_sp_to_x_reg() @test {
    const Int32 NUM_CYCLES = 2; // JSR + RET + LDA_IM
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z = cpu.n = 0xF | cpu.n;
        cpu.x = 0x00;
        cpu.sp = 0x00;
        mem[0xFF00] = emu6502::INS_TSX;
        mem[0xFF01] = 0x00; 
    };
    assert(cycles_used == NUM_CYCLES);
    assert(0x00 == cpu.x);
    assert(cpu.z_bool == true);
    assert(cpu.n_bool == false);
}

fn void txs_can_transfer_x_to_sp() @test {
    const Int32 NUM_CYCLES = 2; // JSR + RET + LDA_IM
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.x = 0x01;
        cpu.sp = 0x00;
        mem[0xFF00] = emu6502::INS_TXS;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.sp == 0x01);
    assert(cpu.ps == copy.ps);
}

fn void pha_can_push_a_reg_onto_stack() @test {
    const Int32 NUM_CYCLES = 3; 
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.a = 0x42;
        mem[0xFF00] = emu6502::INS_PHA;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(mem[(usz)(cpu.sp_to_addr()+1)] == cpu.a);
    assert(cpu.ps == copy.ps);
    assert(cpu.sp == 0xFE);
}

fn void php_can_push_ps_onto_stack() @test {
    const Int32 NUM_CYCLES = 3; 
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.ps = 0xCC;
        mem[0xFF00] = emu6502::INS_PHP;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(mem[(usz)(cpu.sp_to_addr()+1)] == 0xCC | emu6502::UNUSED_FLAG | emu6502::BREAK_CMD );
    assert(cpu.ps == copy.ps);
    assert(cpu.sp == 0xFE, "Expected %x got %x", 0xFE, cpu.sp );
}

fn void php_always_sets_bits_4_and_5_on_stack() @test {
    const Int32 NUM_CYCLES = 3; 
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.ps = 0x00;
        mem[0xFF00] = emu6502::INS_PHP;
    };
    Word add_ps_on_stack = cpu.sp_to_addr()+1;
    assert(cycles_used == NUM_CYCLES);
    // assert(mem[add_ps_on_stack] == 0);
    assert(mem[add_ps_on_stack] == emu6502::UNUSED_FLAG | emu6502::BREAK_CMD);
}

fn void pla_can_pull_a_value_from_sp_to_a_reg() @test {
    const Int32 NUM_CYCLES = 4; 
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.a = 0x0;
        cpu.sp = 0xFE;
        mem[0x01FF] = 0x42;
        mem[0xFF00] = emu6502::INS_PLA;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.a == 0x42);
    assert(cpu.sp == 0xFF);
}

fn void pla_can_pull_zero_from_sp_to_a_reg() @test {
    const Int32 NUM_CYCLES = 4; 
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.a = 0x42;
        cpu.sp = 0xFE;

        mem[0xFF00] = emu6502::INS_PLA;
        mem[0x01FF] = 0;

    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.a == 0);
    assert(cpu.n_bool == false);
    assert(cpu.z_bool == true);
    assert(cpu.sp == 0xFF);
}

fn void pla_can_pull_negative_from_sp_to_a_reg() @test {
    const Int32 NUM_CYCLES = 4; 
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.n_bool = false;
 	    cpu.z_bool = true;
        cpu.a = 0x42;
        cpu.sp = 0xFE;

        mem[0x01FF] = 0b10000001;
        mem[0xFF00] = emu6502::INS_PLA;
    };
    assert(cycles_used == NUM_CYCLES, "Expected: %d Got: %d", NUM_CYCLES,cycles_used );
    assert(cpu.a == 0b10000001, "Expected: %d Got: %d", 0b10000001, cpu.a);
    assert(cpu.n_bool == true);
    assert(cpu.z_bool == false);
    assert(cpu.sp == 0xFF);
}

fn void plp_can_pull_from_sp_to_ps() @test {
    const Int32 NUM_CYCLES = 4; 
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.sp = 0xFE;
        cpu.ps = 0;
        mem[0x01FF] = 0x42 | emu6502::UNUSED_FLAG | emu6502::BREAK_CMD;
        mem[0xFF00] = emu6502::INS_PLP;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.ps == 0x42, "Expected: %d Got: %d", 0x42, cpu.ps);
}

fn void plp_clears_bits_4_and_5() @test {
    const Int32 NUM_CYCLES = 4; 
    Int32 cycles_used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.sp = 0xFE;
        cpu.ps = 0;
        mem[0x01FF] = emu6502::UNUSED_FLAG | emu6502::BREAK_CMD;
        mem[0xFF00] = emu6502::INS_PLP;
    };
    assert(cycles_used == NUM_CYCLES);
    assert(cpu.ps ==0, "Expected: %d Got: %d", 0, cpu.ps);
}
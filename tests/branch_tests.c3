module emu6502::tests;
import emu6502;

// fn void beq_can_branch_forwards_when_z_set_test() @test => 
fn void beq_can_branch_forwards_when_z() @test {
    const Int32 NUM_CYCLES = 3;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = true;
        mem[0xFF00] = emu6502::INS_BEQ;
        mem[0xFF01] = 0x01;

    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0xFF03);
    assert(cpu.ps == copy.ps);   
}

fn void beq_cant_branch_forwards_when_z_clear() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.z_bool = false;
        mem[0xFF00] = emu6502::INS_BEQ;
        mem[0xFF01] = 0x01;

    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0xFF02);
    assert(cpu.ps == copy.ps);   
}

fn void beq_can_branch_forwards_into_new_page_when_z() @test {
    //IN VIDEO THIS WOULD FAIL, BUT COMMENTS SAID TO DO THIS! https://youtu.be/W3eXW2J4swM?si=cOnuosWZC1x1gD5T
    const Int32 NUM_CYCLES = 4; 
    Int32 used = @test_init(NUM_CYCLES, 0xFEFD){
        cpu.z_bool = true;
        mem[0xFEFD] = emu6502::INS_BEQ;
        mem[0xFEFE] = 0x1;
    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0xFF00);
    assert(cpu.ps == copy.ps);   
}

fn void beq_can_branch_backwards_when_z() @test {
    const Int32 NUM_CYCLES = 3;
    Int32 used = @test_init(NUM_CYCLES, 0xFFCC){
        cpu.z_bool = true;
        mem[0xFFCC] = emu6502::INS_BEQ;
        mem[0xFFCD] = @negative_to_byte(-0x2); // have to do this explicitly
    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0xFFCC);
    assert(cpu.ps == copy.ps);   
}

fn void beq_cant_branch_backwards_when_not_z() @test {
    const Int32 NUM_CYCLES = 2;
    Int32 used = @test_init(NUM_CYCLES, 0xFFCC){
        cpu.z_bool = false;
        mem[0xFFCC] = emu6502::INS_BEQ;
        mem[0xFFCD] = @negative_to_byte(-0x2); // have to do this explicitly
    };
    assert(used == NUM_CYCLES);
    assert(cpu.pc == 0xFFCE);
    assert(cpu.ps == copy.ps);   
}

fn void beq_can_branch_forwards_when_flag_not_set() @test => @can_branch_forwards_when_flag_not_set(emu6502::INS_BEQ, 1, z);
fn void bne_can_branch_forwards_when_flag_not_set() @test => @can_branch_forwards_when_flag_not_set(emu6502::INS_BNE, 0, z);

fn void bcs_can_branch_forwards_when_flag_not_set() @test => @can_branch_forwards_when_flag_not_set(emu6502::INS_BCS, 1, c);
fn void bcc_can_branch_forwards_when_flag_not_set() @test => @can_branch_forwards_when_flag_not_set(emu6502::INS_BCC, 0, c);

fn void bmi_can_branch_forwards_when_flag_not_set() @test => @can_branch_forwards_when_flag_not_set(emu6502::INS_BMI, 1, n);
fn void bpl_can_branch_forwards_when_flag_not_set() @test => @can_branch_forwards_when_flag_not_set(emu6502::INS_BPL, 0, n);

fn void bvs_can_branch_forwards_when_flag_not_set() @test => @can_branch_forwards_when_flag_not_set(emu6502::INS_BVS, 1, v);
fn void bvc_can_branch_forwards_when_flag_not_set() @test => @can_branch_forwards_when_flag_not_set(emu6502::INS_BVC, 0, v);


macro void @can_branch_forwards_when_flag_not_set(Byte opcode, Byte expected, #register) {
    const Int32 NUM_CYCLES = 3;
    Int32 used = @test_init(NUM_CYCLES, 0xFF00){
        cpu.#register = expected;
        mem[0xFF00] = opcode;
        mem[0xFF01] = 0x01;

    };
    assert(used == NUM_CYCLES, "Expected: %d Got: %d", NUM_CYCLES, used);
    assert(cpu.pc == 0xFF03);
    assert(cpu.ps == copy.ps);   
}
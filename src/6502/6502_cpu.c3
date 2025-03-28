// https://youtu.be/qJgsuQoy9bc?si=ua1AbvCPNS3Am2Ix
module emu6502;
import emulator;
import std::io;

fn void Cpu.init(&cpu, Memory* memory, Word init_pc = 0xFFFC){
    cpu.c = cpu.z = cpu.i = cpu.d = cpu.b = cpu.v = cpu.n = 1; //status flags
    cpu.reset(memory, init_pc);
}

fn void Cpu.reset(&cpu, Memory* memory, Word init_pc){
    cpu.pc = init_pc;
    cpu.sp = 0xFF;
    cpu.ps = 0;

    cpu.a = cpu.x = cpu.y = 0; //reset registers
    memory.init();
}

fn Byte Cpu.fetch_byte(&cpu, Memory* memory) {
    Byte data = (*memory)[cpu.pc];
    cpu.pc++;
    return data;
}

fn Word Cpu.fetch_word(&cpu, Memory* memory) {
    Word data = (*memory)[cpu.pc];
    cpu.pc++;
    data |= ((*memory)[cpu.pc] << 8);
    cpu.pc++;
    return data;
}

fn Word Cpu.load_prg(&self, Byte[] prg, Memory* memory){
    if(prg.len <2) return 0;

    Word address = prg[0] | (prg[1] << 8);

    foreach(Word i, Byte b : prg[2..]){
        (*memory)[(usz)(i + address)] = b;
    }
    return address;
}

fn Int32! Cpu.exec(&cpu, Int32 cycles, Memory* memory) {
    Int32 requested = cycles;
    while(cycles > 0){
        Byte instruction = cpu.fetch_byte( memory);

        switch(instruction){
            case INS_LDA_IM:
                cpu.@load_immediate(  memory, a);
                cycles-=2;
            case INS_LDX_IM:
                cpu.@load_immediate(  memory, x);
                cycles-=2;
            case INS_LDY_IM:
                cpu.@load_immediate(  memory, y);
                cycles-=2;
            case INS_LDA_ZP:
                cpu.@load_with_address(cpu.addr_zero_page( memory),a , memory)!;
                cycles-=3;
            case INS_LDX_ZP:
                cpu.@load_with_address(cpu.addr_zero_page( memory),x , memory)!;
                cycles-=3;
            case INS_LDY_ZP:
                cpu.@load_with_address(cpu.addr_zero_page( memory),y , memory)!;
                cycles-=3;
            case INS_LDA_ZPX:
                cpu.@load_with_address(cpu.addr_zero_page_x( memory),a , memory)!;
                cycles-=4;
            case INS_LDY_ZPX:
                cpu.@load_with_address(cpu.addr_zero_page_x( memory),y , memory)!;
                cycles-=4;
            case INS_LDX_ZPY:
                cpu.@load_with_address(cpu.addr_zero_page_y( memory),x , memory)!;
                cycles-=4;
            case INS_LDA_ABS:
                cpu.@load_with_address(cpu.addr_absolute( memory),a , memory)!;
                cycles-=4;
            case INS_LDX_ABS:
                cpu.@load_with_address(cpu.addr_absolute( memory),x , memory)!;
                cycles-=4;
            case INS_LDY_ABS:
                cpu.@load_with_address(cpu.addr_absolute( memory),y , memory)!;
                cycles-=4;
            case INS_LDA_ABSX:
                cpu.@load_with_address(cpu.addr_absolute_x( memory, &cycles),a , memory)!;
                cycles-=4;
             case INS_LDY_ABSX:
                cpu.@load_with_address(cpu.addr_absolute_x( memory, &cycles),y , memory)!;
                cycles-=4;
            case INS_LDA_ABSY:
                cpu.@load_with_address(cpu.addr_absolute_y( memory, &cycles),a , memory)!;
                cycles-=4;
            case INS_LDX_ABSY:
                cpu.@load_with_address(cpu.addr_absolute_y( memory, &cycles),x , memory)!;
                cycles-=4;
            case INS_LDA_INDX:
                cpu.@load_with_address(cpu.addr_indirect_x( memory),a , memory)!;
                cycles-=6;
            case INS_LDA_INDY:
                cpu.@load_with_address(cpu.addr_indirect_y( memory, &cycles),a , memory)!;
                cycles-=5;
            
            case INS_STA_ZP : 
               memory.write_byte(cpu.a, cpu.addr_zero_page( memory))!;        
                cycles-=3;
            case INS_STX_ZP :
               memory.write_byte(cpu.x, cpu.addr_zero_page( memory))!;     
                cycles-=3;
            case INS_STY_ZP : 
               memory.write_byte(cpu.y, cpu.addr_zero_page( memory))!;     
                cycles-=3;
            case INS_STA_ABS : 
               memory.write_byte(cpu.a, cpu.addr_absolute( memory))!;        
                cycles-=4;
            case INS_STX_ABS : 
               memory.write_byte(cpu.x, cpu.addr_absolute( memory))!;  
                cycles-=4;
            case INS_STY_ABS : 
               memory.write_byte(cpu.y, cpu.addr_absolute( memory))!;  
                cycles-=4;
            case INS_STA_ZPX : 
               memory.write_byte(cpu.a, cpu.addr_zero_page_x( memory))!;   
                cycles-=4;
            case INS_STY_ZPX : 
               memory.write_byte(cpu.y, cpu.addr_zero_page_x( memory) )!;   
                cycles-=4;
            case INS_STX_ZPY : 
               memory.write_byte(cpu.x, cpu.addr_zero_page_y( memory))!;   
                cycles-=4;
            case INS_STA_ABSX: 
               memory.write_byte(cpu.a, cpu.addr_absolute_x( memory, &cycles))!;
                cycles-=5;
            case INS_STA_ABSY: 
               memory.write_byte(cpu.a, cpu.addr_absolute_y( memory, &cycles))!;
                cycles-=5;
            case INS_STA_INDX: 
               memory.write_byte(cpu.a, cpu.addr_indirect_x( memory))!;
                cycles-=6;
            case INS_STA_INDY: 
               memory.write_byte(cpu.a, cpu.addr_indirect_y_6( memory, &cycles))!;
                cycles-=6;
            case INS_JSR:
                Word sub_addr = cpu.fetch_word( memory);
                cpu.push_pc_to_stack( (cpu.pc-1), memory)!;
                cpu.pc = sub_addr;
                cycles-=6;
            case INS_RTS:
                Word ret_addr = cpu.pop_word_from_stack( memory)!;
                cpu.pc = ret_addr + 1;
                cycles-=6;
            case INS_JMP_ABS:
                Word address = cpu.addr_absolute( memory);
                cpu.pc = address;
                cycles-=3;
            case INS_JMP_IND:
                Word address = cpu.addr_absolute( memory);
                cpu.pc = memory.read_word(address)!;
                cycles-=5;
            case INS_TSX:
                cpu.x = cpu.sp;
                cpu.set_zero_and_negative_flags(cpu.x);
                cycles-=2;
            case INS_TXS:
                cpu.sp = cpu.x;
                cycles-=2;
            case INS_PHA: 
                cpu.push_byte_to_stack( cpu.a,memory);
                cycles-=3;
            case INS_PHP: 
                cpu.push_ps_to_stack( memory);
                cycles-=3;
            case INS_PLA: 
                cpu.a = cpu.pop_byte_from_stack( memory);
                cpu.set_zero_and_negative_flags(cpu.a);
                cycles-=4;
            case INS_PLP: 
                cpu.pop_ps_from_stack( memory);
                cycles-=4;
            case INS_AND_IM:
                cpu.a &= cpu.fetch_byte( memory);
                cpu.set_zero_and_negative_flags(cpu.a);
                cycles-=2;
            case INS_ORA_IM:
                cpu.a |= cpu.fetch_byte( memory);
                cpu.set_zero_and_negative_flags(cpu.a);
                cycles-=2;
            case INS_EOR_IM:
                cpu.a ^= cpu.fetch_byte( memory);
                cpu.set_zero_and_negative_flags(cpu.a);
                cycles-=2;
            case INS_AND_ZP:
                cpu.and_byte(cpu.addr_zero_page( memory),  memory)!;
                cycles-=3;
            case INS_ORA_ZP:
                cpu.ora_byte(cpu.addr_zero_page( memory),  memory)!;
                cycles-=3;
            case INS_EOR_ZP:
                cpu.eor_byte(cpu.addr_zero_page( memory),  memory)!;
                cycles-=3;
            case INS_AND_ZPX:
                cpu.and_byte(cpu.addr_zero_page_x( memory),  memory)!;
                cycles-=4;
            case INS_ORA_ZPX:
                cpu.ora_byte(cpu.addr_zero_page_x( memory),  memory)!;
                cycles-=4;
            case INS_EOR_ZPX:
                cpu.eor_byte(cpu.addr_zero_page_x( memory),  memory)!;
                cycles-=4;
            case INS_AND_ABS:
                cpu.and_byte(cpu.addr_absolute( memory),  memory)!;
                cycles-=4;
            case INS_ORA_ABS:
                cpu.ora_byte(cpu.addr_absolute( memory),  memory)!;
                cycles-=4;
            case INS_EOR_ABS:
                cpu.eor_byte(cpu.addr_absolute( memory),  memory)!;
                cycles-=4;
            case INS_AND_ABSX:
                cpu.and_byte(cpu.addr_absolute_x( memory, &cycles),  memory)!;
                cycles-=4;
            case INS_ORA_ABSX:
                cpu.ora_byte(cpu.addr_absolute_x( memory, &cycles),  memory)!;
                cycles-=4;
            case INS_EOR_ABSX:
                cpu.eor_byte(cpu.addr_absolute_x( memory, &cycles),  memory)!;
                cycles-=4;
            case INS_AND_ABSY:
                cpu.and_byte(cpu.addr_absolute_y( memory, &cycles),  memory)!;
                cycles-=4;
            case INS_ORA_ABSY:
                cpu.ora_byte(cpu.addr_absolute_y( memory, &cycles),  memory)!;
                cycles-=4;
            case INS_EOR_ABSY:
                cpu.eor_byte(cpu.addr_absolute_y( memory, &cycles),  memory)!;
                cycles-=4;
            case INS_AND_INDX:
                cpu.and_byte(cpu.addr_indirect_x( memory),  memory)!;
                cycles-=6;
            case INS_ORA_INDX:
                cpu.ora_byte(cpu.addr_indirect_x( memory),  memory)!;
                cycles-=6;
            case INS_EOR_INDX:
                cpu.eor_byte(cpu.addr_indirect_x( memory),  memory)!;
                cycles-=6;
            case INS_AND_INDY:
                cpu.and_byte(cpu.addr_indirect_y( memory, &cycles),  memory)!;
                cycles-=5;
            case INS_ORA_INDY:
                cpu.ora_byte(cpu.addr_indirect_y( memory, &cycles),  memory)!;
                cycles-=5;
            case INS_EOR_INDY:
                cpu.eor_byte(cpu.addr_indirect_y( memory, &cycles),  memory)!;
                cycles-=5;
            case INS_BIT_ZP:
                cpu.bit_test( cpu.addr_zero_page( memory),  memory )!;
                cycles-=3;
            case INS_BIT_ABS:
                cpu.bit_test( cpu.addr_absolute( memory),  memory )!;
                cycles-=4;
            case INS_TAX: 
                cpu.@tranfer_reg(x, a);
                cycles-=2;
            case INS_TAY: 
                cpu.@tranfer_reg(y, a);
                cycles-=2;
            case INS_TXA: 
                cpu.@tranfer_reg(a, x);
                cycles-=2;
            case INS_TYA: 
                cpu.@tranfer_reg(a, y);
                cycles-=2;
            case INS_INX:
                cpu.@inc_reg(x);
                cycles-=2;
            case INS_INY:
                cpu.@inc_reg(y);
                cycles-=2;
            case INS_INC_ZP:
                cpu.inc_addr(cpu.addr_zero_page( memory),  memory)!;
                cycles-=5;
            case INS_INC_ZPX:
                cpu.inc_addr(cpu.addr_zero_page_x( memory),  memory)!;
                cycles-=5;
            case INS_INC_ABS:
                cpu.inc_addr(cpu.addr_absolute( memory),  memory)!;
                cycles-=6;
            case INS_INC_ABSX:
                cpu.inc_addr(cpu.addr_absolute_x( memory, &cycles),  memory)!;
                cycles-=7;
            case INS_DEX:
                cpu.@dec_reg(x);
                cycles-=2;
            case INS_DEY:
                cpu.@dec_reg(y);
                cycles-=2;
            case INS_DEC_ZP:
                cpu.dec_addr(cpu.addr_zero_page( memory),  memory)!;
                cycles-=5;
            case INS_DEC_ZPX:
                cpu.dec_addr(cpu.addr_zero_page_x( memory),  memory)!;
                cycles-=6;
            case INS_DEC_ABS:
                cpu.dec_addr(cpu.addr_absolute( memory),  memory)!;
                cycles-=6;
            case INS_DEC_ABSX:
                cpu.dec_addr(cpu.addr_absolute_x( memory, &cycles),  memory)!;
                cycles-=7;
            case INS_BEQ:
                cpu.@branch(z, 1,  memory, &cycles);
                cycles-=2;
            case INS_BCC: 
                cpu.@branch(c,0 ,  memory, &cycles);
                cycles-=2;
            case INS_BCS: 
                cpu.@branch(c, 1,  memory, &cycles);
                cycles-=2;
            case INS_BMI: 
                cpu.@branch(n, 1,  memory, &cycles);
                cycles-=2;
            case INS_BNE: 
                cpu.@branch(z, 0,  memory, &cycles);
                cycles-=2;
            case INS_BPL: 
                cpu.@branch(n, 0,  memory, &cycles);
                cycles-=2;
            case INS_BVC: 
                cpu.@branch(v, 0,  memory, &cycles);
                cycles-=2;
            case INS_BVS: 
                cpu.@branch(v, 1,  memory, &cycles);
                cycles-=2;
            case INS_CLC: 
                cpu.c = 0;
                cycles-=2;
            case INS_CLD: 
                cpu.d = 0;
                cycles-=2;
            case INS_CLI: 
                cpu.i = 0;
                cycles-=2;
            case INS_CLV: 
                cpu.v = 0;
                cycles-=2;
            case INS_SEC: 
                cpu.c = 1;
                cycles-=2;
            case INS_SED: 
                cpu.d = 1;
                cycles-=2;
            case INS_SEI: 
                cpu.i = 1;
                cycles-=2;
            case INS_NOP:
                cycles-=2;
            case INS_ADC_IM  : 
                cpu.@adc( cpu.fetch_byte(  memory));
                cycles-=2;
            case INS_ADC_ZP  :
                cpu.@adc( memory.read_byte( cpu.addr_zero_page( memory))!);
                cycles-=3;
            case INS_ADC_ZPX : 
                cpu.@adc( memory.read_byte( cpu.addr_zero_page_x( memory))!);
                cycles-=4;
            case INS_ADC_ABS : 
                cpu.@adc( memory.read_byte( cpu.addr_absolute( memory))!);
                cycles-=4;
            case INS_ADC_ABSX: 
                cpu.@adc( memory.read_byte( cpu.addr_absolute_x( memory, &cycles))!);
                cycles-=4;
            case INS_ADC_ABSY: 
                cpu.@adc( memory.read_byte( cpu.addr_absolute_y( memory, &cycles))!);
                cycles-=4;
            case INS_ADC_INDX: 
                cpu.@adc( memory.read_byte( cpu.addr_indirect_x( memory))!);
                cycles-=6;
            case INS_ADC_INDY: 
                cpu.@adc( memory.read_byte( cpu.addr_indirect_y( memory, &cycles))!);
                cycles-=5;
            case INS_SBC_IM : 
                cpu.@sbc( cpu.fetch_byte(  memory));
                cycles-=2;
            case INS_SBC_ZP : 
                cpu.@sbc(memory.read_byte( cpu.addr_zero_page( memory))!);
                cycles-=3;
            case INS_SBC_ZPX  : 
                cpu.@sbc(memory.read_byte( cpu.addr_zero_page_x( memory))!);
                cycles-=4;
            case INS_SBC_ABS  : 
                cpu.@sbc(memory.read_byte( cpu.addr_absolute( memory))!);
                cycles-=4;
            case INS_SBC_ABSX : 
                cpu.@sbc(memory.read_byte( cpu.addr_absolute_x( memory, &cycles))!);
                cycles-=4;
            case INS_SBC_ABSY : 
                cpu.@sbc(memory.read_byte( cpu.addr_absolute_y( memory, &cycles))!);
                cycles-=4;
            case INS_SBC_INDX : 
                cpu.@sbc(memory.read_byte( cpu.addr_indirect_x( memory))!);
                cycles-=6;
            case INS_SBC_INDY : 
                cpu.@sbc(memory.read_byte( cpu.addr_indirect_y( memory, &cycles))!);
                cycles-=5;
            case INS_CMP_IM  :
                cpu.@cmp(a, cpu.fetch_byte( memory));
                cycles-=2;
            case INS_CMP_ZP  :
                Word addr = cpu.addr_zero_page( memory);
                cpu.@cmp(a, memory.read_byte(addr)!);
                cycles-=3;
            case INS_CMP_ZPX :
                Word addr = cpu.addr_zero_page_x( memory);
                cpu.@cmp(a, memory.read_byte(addr)!);
                cycles-=4;
            case INS_CMP_ABS :
                Word addr = cpu.addr_absolute( memory);
                cpu.@cmp(a, memory.read_byte(addr)!);
                cycles-=4;
            case INS_CMP_ABSX:
                Word addr = cpu.addr_absolute_x( memory, &cycles);
                cpu.@cmp(a, memory.read_byte(addr)!);
                cycles-=4;
            case INS_CMP_ABSY:
                Word addr = cpu.addr_absolute_y( memory, &cycles);
                cpu.@cmp(a, memory.read_byte(addr)!);
                cycles-=4;
            case INS_CMP_INDX:
                Word addr = cpu.addr_indirect_x( memory)!;
                cpu.@cmp(a, memory.read_byte(addr)!);
                cycles-=6;
            case INS_CMP_INDY:
                Word addr = cpu.addr_indirect_y( memory, &cycles)!;
                cpu.@cmp(a, memory.read_byte(addr)!);
                cycles-=5;
            case INS_CPX_IM  :
                cpu.@cmp(x, cpu.fetch_byte( memory));
                cycles-=2;
            case INS_CPX_ZP  :
                Word addr = cpu.addr_zero_page( memory);
                cpu.@cmp(x, memory.read_byte(addr)!);
                cycles-=3;
            case INS_CPX_ABS :
                Word addr = cpu.addr_absolute( memory);
                cpu.@cmp(x, memory.read_byte(addr)!);
                cycles-=4;
            case INS_CPY_IM  :
                cpu.@cmp(y, cpu.fetch_byte( memory));
                cycles-=2;
            case INS_CPY_ZP  :
                Word addr = cpu.addr_zero_page( memory);
                cpu.@cmp(y, memory.read_byte(addr)!);
                cycles-=3;
            case INS_CPY_ABS :
                Word addr = cpu.addr_absolute( memory);
                cpu.@cmp(y, memory.read_byte(addr)!);
                cycles-=4;
            case INS_ASL     : 
                cpu.c = cpu.a & NEGATIVE_FLAG > 0 ? 1 : 0;
                cpu.a = cpu.a << 1;
                cpu.set_zero_and_negative_flags(cpu.a);
                cycles-=2;
            case INS_ASL_ZP  : 
                Word addr = cpu.addr_zero_page( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.shift_left(operand, addr,  memory)!;
                cycles-=5;
            case INS_ASL_ZPX : 
                Word addr = cpu.addr_zero_page_x( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.shift_left(operand, addr,  memory)!;
                cycles-=6;
            case INS_ASL_ABS :
                Word addr = cpu.addr_absolute( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.shift_left(operand, addr,  memory)!; 
                cycles-=6;
            case INS_ASL_ABSX: 
                Word addr = cpu.addr_absolute_x( memory, &cycles);
                Byte operand = memory.read_byte( addr)!;
                cpu.shift_left(operand, addr,  memory)!; 
                cycles-=7;
            case INS_LSR     :
                cpu.c = cpu.a & CARRY_FLAG > 0 ? 1 : 0;
                cpu.n = 0;
                cpu.a = cpu.a >> 1;
                cpu.z = cpu.a == 0 ? 1 : 0  ;
                cycles-=2;
            case INS_LSR_ZP  :
                Word addr = cpu.addr_zero_page( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.shift_right(operand, addr,  memory)!;
                cycles-=5;
            case INS_LSR_ZPX :
                Word addr = cpu.addr_zero_page_x( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.shift_right(operand, addr,  memory)!;
                cycles-=6;
            case INS_LSR_ABS :
                Word addr = cpu.addr_absolute( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.shift_right(operand, addr,  memory)!;
                cycles-=6;
            case INS_LSR_ABSX:
                Word addr = cpu.addr_absolute_x( memory, &cycles);
                Byte operand = memory.read_byte( addr)!;
                cpu.shift_right(operand, addr,  memory)!;
                cycles-=7;
            case INS_ROL:
                Byte bit1 = cpu.c;
                cpu.c = cpu.a & NEGATIVE_FLAG > 0 ? 1 : 0;
                cpu.a = cpu.a << 1;
                cpu.a |= bit1;
                cpu.set_zero_and_negative_flags(cpu.a);
                cycles-=2;
            case INS_ROL_ZP  :
                Word addr = cpu.addr_zero_page( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.rotate_left(operand, addr,  memory)!;
                cycles-=5;
            case INS_ROL_ZPX :
                Word addr = cpu.addr_zero_page_x( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.rotate_left(operand, addr,  memory)!;
                cycles-=6;
            case INS_ROL_ABS :
                Word addr = cpu.addr_absolute( memory);
                Byte operand = memory.read_byte( addr)!;
                cpu.rotate_left(operand, addr,  memory)!;
                cycles-=6;
            case INS_ROL_ABSX:
                Word addr = cpu.addr_absolute_x( memory, &cycles);
                Byte operand = memory.read_byte( addr)!;
                cpu.rotate_left(operand, addr,  memory)!;
                cycles-=7;
            case INS_ROR     :
                Byte oldBit = cpu.a & CARRY_FLAG;
                cpu.a = cpu.a >> 1;
                if(cpu.c == 1) cpu.a |= NEGATIVE_FLAG;
                cpu.c = oldBit > 0 ? 1 : 0;
                cpu.set_zero_and_negative_flags(cpu.a);
                cycles-=2;
            case INS_ROR_ZP  :
                Word addr = cpu.addr_zero_page( memory);
                Byte operand = memory.read_byte( addr)!;
               cpu.rotate_right(operand, addr,  memory)!;
                cycles-=5;
            case INS_ROR_ZPX :
                Word addr = cpu.addr_zero_page_x( memory);
                Byte operand = memory.read_byte( addr)!;
               cpu.rotate_right(operand, addr,  memory)!;
                cycles-=6;
            case INS_ROR_ABS :
                Word addr = cpu.addr_absolute( memory);
                Byte operand = memory.read_byte( addr)!;
               cpu.rotate_right(operand, addr,  memory)!;
                cycles-=6;
            case INS_ROR_ABSX:
                Word addr = cpu.addr_absolute_x( memory, &cycles);
                Byte operand = memory.read_byte( addr)!;
               cpu.rotate_right(operand, addr,  memory)!;
                cycles-=7;
            case INS_BRK:
                cpu.push_pc_to_stack((cpu.pc+1),  memory)!;
                cpu.push_ps_to_stack(memory);
                cpu.pc = memory.read_word(INTERRUPT_VECTOR_ADDR)!;
                cpu.b = 1;
                cpu.i = 1;
                cycles-=7;
            case INS_RTI:
                cpu.pop_ps_from_stack( memory);
                cpu.pc = cpu.pop_word_from_stack( memory)!;
                cycles-=6;
            default:
                return Err6502.INVALID_INSTRUCTION?;
        }
    }
    return requested - cycles;
}

macro void! Cpu.@load_with_address(Cpu* cpu, Word address, #register, Memory* memory) {
    cpu.#register = memory.read_byte( address)!;
    cpu.set_zero_and_negative_flags(cpu.#register);
}

macro void Cpu.@load_immediate(Cpu* cpu, Memory* memory, #register) {
    Byte value = cpu.fetch_byte( memory);
    cpu.#register = value;
    cpu.set_zero_and_negative_flags(cpu.#register);
}

macro void Cpu.set_zero_and_negative_flags(Cpu* cpu, Byte value) {
    cpu.z = @byte(value == 0);
    cpu.n = @byte((value & 0b10000000) > 0);
}

macro Byte @byte(#expr) @builtin {
    return (Byte) #expr;
}

macro Byte @negative_to_byte(#expr) @builtin {
    return (Byte) (SByte) #expr;
}

macro Word Cpu.addr_zero_page(Cpu* cpu, Memory* memory) {
 	return cpu.fetch_byte(  memory );
}

macro Word Cpu.addr_zero_page_x(Cpu* cpu, Memory* memory) {
 	return (cpu.fetch_byte(  memory ) + cpu.x) ;
}

macro Word Cpu.addr_zero_page_y(Cpu* cpu, Memory* memory) {
 	return (cpu.fetch_byte( memory ) + cpu.y);
}

macro Word Cpu.addr_absolute(Cpu* cpu, Memory* memory) {
 	return cpu.fetch_word( memory );
}

macro Word Cpu.addr_absolute_x(Cpu* cpu, Memory* memory, Int32* cycles) {
    Word abs_addr = cpu.addr_absolute(memory);
    Word abs_addr_x = abs_addr + cpu.x;
    
    bool crossed_page_boundry = (abs_addr ^ abs_addr_x) >> 8 > 0;
    if ( crossed_page_boundry)
 	{
 		(*cycles)--;
 	}
    return abs_addr_x;
}

macro Word Cpu.addr_absolute_y(Cpu* cpu, Memory* memory, Int32* cycles) {
    Word abs_addr = cpu.addr_absolute( memory);
    Word abs_addr_y = abs_addr + cpu.y;
    bool crossed_page_boundry = (abs_addr ^ abs_addr_y) >> 8 > 0;
    if ( crossed_page_boundry )
 	{
 		(*cycles)--;
 	}
    return abs_addr_y;
}

macro Word! Cpu.addr_indirect_x(Cpu* cpu, Memory* memory) {
    Byte zp_addr = cpu.fetch_byte(memory) + cpu.x;
    Word effective_addr = memory.read_word (zp_addr )!;
    return effective_addr;
}

macro Word! Cpu.addr_indirect_y(Cpu* cpu, Memory* memory, Int32* cycles) {
    Byte zp_addr = cpu.fetch_byte(memory);
    Word effective_addr = memory.read_word (zp_addr )!;
    Word effective_addr_y = effective_addr + cpu.y;
    bool crossed_page_boundry = (effective_addr ^ effective_addr_y) >> 8 > 0;
    if ( crossed_page_boundry )
 	{
 		(*cycles)--;
 	}
    return effective_addr_y;
}

macro Word! Cpu.addr_indirect_y_6(Cpu* cpu, Memory* memory, Int32* cycles) {
    Byte zp_addr = cpu.fetch_byte(memory);
    Word effective_addr = memory.read_word (zp_addr )!;
    Word effective_addr_y = effective_addr + cpu.y;
    return effective_addr_y;
}

fn void! Cpu.push_pc_to_stack(Cpu* cpu, Word pc, Memory* memory) {
    memory.write_word( pc, cpu.sp_to_addr()-1)!;
    cpu.sp -= 2;
}

fn Word! Cpu.pop_word_from_stack(Cpu* cpu, Memory* memory) {
    Word sub_addr = memory.read_word( cpu.sp_to_addr() + 1)!;
    cpu.sp += 2;
    return  sub_addr;
}

fn void Cpu.push_byte_to_stack(Cpu* cpu, Byte value, Memory* memory) {
    Word addr = cpu.sp_to_addr();
    (*memory)[addr] = value;
    cpu.sp--;
}

fn Byte Cpu.pop_byte_from_stack(Cpu* cpu, Memory* memory){
    cpu.sp++;
    Word addr = cpu.sp_to_addr();
    Byte value = (*memory)[addr];
    return value;
}

macro Word Cpu.sp_to_addr(Cpu* cpu) {
    return cpu.sp | 0x100;
}

macro void! Cpu.and_byte(Cpu* cpu,  Word addr, Memory* memory) {
    cpu.a &= memory.read_byte(addr)!;
    cpu.set_zero_and_negative_flags(cpu.a);
}

macro void! Cpu.eor_byte(Cpu* cpu,  Word addr,Memory* memory) {
    cpu.a ^= memory.read_byte(addr)!;
    cpu.set_zero_and_negative_flags(cpu.a);
}

macro void! Cpu.ora_byte(Cpu* cpu, Word addr, Memory* memory) {
    cpu.a |= memory.read_byte(addr)!;
    cpu.set_zero_and_negative_flags(cpu.a);
}

macro void! Cpu.bit_test(Cpu* cpu,  Word addr,Memory* memory) {
    Byte value = memory.read_byte( addr)!;
    cpu.z = (Byte) !((bool)(cpu.a & value));
    cpu.n = (Byte) ((value & NEGATIVE_FLAG) != 0);
    cpu.v = (Byte) ((value & OVERFLOW_FLAG) != 0);
}

macro void Cpu.@tranfer_reg(Cpu* cpu, #in_reg, #target_reg) {
    cpu.#in_reg = cpu.#target_reg;
    cpu.set_zero_and_negative_flags(cpu.#in_reg);
}

macro void Cpu.@inc_reg(Cpu* cpu, #register){
    cpu.#register++;
    cpu.set_zero_and_negative_flags(cpu.#register);
}

macro void! Cpu.inc_addr(Cpu* cpu, Word address, Memory* memory) {
    Byte value = memory.read_byte( address)! +1;
    memory.write_byte(value, address)!;
    cpu.set_zero_and_negative_flags(value);
}

macro void Cpu.@dec_reg(Cpu* cpu, #register) {
    cpu.#register--;
    cpu.set_zero_and_negative_flags(cpu.#register);
}

macro void! Cpu.dec_addr(Cpu* cpu, Word address, Memory* memory) {
    Byte value = memory.read_byte( address)! -1;
    memory.write_byte(value, address)!;
    cpu.set_zero_and_negative_flags(value);
}

macro void Cpu.@branch(Cpu* cpu, #flag, set, Memory* memory, Int32* cycles) {
    Byte offset = cpu.fetch_byte( memory);
    if(cpu.#flag == set){ //branch if flag set
        Word old_pc = cpu.pc;
        cpu.pc += (SByte) offset;
        (*cycles)--;
        bool crossed_page_boundry = (cpu.pc  ^ old_pc) >> 8 > 0;
        if ( crossed_page_boundry )
        {
            (*cycles)--;
        }
    }
}

macro void Cpu.@adc(Cpu* cpu, Byte operand){
    assert(cpu.d == 0, "decimal mode unhandled!");
    Word sum = cpu.a + operand + cpu.c;
    //if a and the operand are both negative,
    //but the sum is NOT negative,
    //we set overflow!
    cpu.v = !((cpu.a ^ operand) & (NEGATIVE_FLAG)) && (((Byte)(sum & 0x00FF)) ^ operand) & NEGATIVE_FLAG ? 1 : 0;
    cpu.a = (Byte)(sum & 0x00FF);
    cpu.set_zero_and_negative_flags(cpu.a);
    cpu.c = (sum > 0xFF) ? 1 :0;
}

macro void Cpu.@sbc(Cpu* cpu, Byte operand) {
    cpu.@adc(~operand );
}

macro void Cpu.@cmp(Cpu* cpu, #register, Byte operand){
    Byte temp = cpu.#register - operand;
    cpu.n = (temp & NEGATIVE_FLAG) > 0 ? 1 : 0;
    cpu.z = temp == 0 ? 1 : 0;
    cpu.c = cpu.#register >= operand ? 1 : 0;
}

macro void! Cpu.shift_left(Cpu* cpu, Byte operand, Word addr, Memory* memory) {
    cpu.c = operand & NEGATIVE_FLAG > 0 ? 1 : 0;
    cpu.set_zero_and_negative_flags(operand << 1);
    memory.write_byte(operand << 1, addr)!;
}

macro void! Cpu.shift_right(Cpu* cpu, Byte operand, Word addr, Memory* memory) {
    cpu.c = operand & CARRY_FLAG > 0 ? 1 : 0;
    cpu.n = 0;
    operand = operand >> 1;
    cpu.z = operand == 0 ? 1 : 0  ;
    memory.write_byte(operand , addr)!;
}

macro void! Cpu.rotate_left(Cpu* cpu, Byte operand, Word addr, Memory* memory) {
    Byte bit1 = cpu.c;
    cpu.c = operand & NEGATIVE_FLAG > 0 ? 1 : 0;
    operand = operand << 1;
    operand |= bit1;
    cpu.set_zero_and_negative_flags(operand);
    memory.write_byte(operand, addr)!;
}

macro void! Cpu.rotate_right(Cpu* cpu, Byte operand, Word addr, Memory* memory) {
    Byte oldBit = operand & CARRY_FLAG;
    operand = operand >> 1;
    if(cpu.c == 1) operand |= NEGATIVE_FLAG;
    cpu.c = oldBit > 0 ? 1 : 0;
    cpu.set_zero_and_negative_flags(operand);
    memory.write_byte(operand, addr)!;
}

macro void Cpu.push_ps_to_stack(Cpu* cpu, Memory* memory) {
    Byte ps = (Byte)(cpu.ps | UNUSED_FLAG | BREAK_CMD);
    cpu.push_byte_to_stack(ps, memory);
}

fn void! Cpu.push_word_to_stack(Cpu* cpu, Word value, Memory* memory) {
    memory.write_byte((Byte) value >> 8, cpu.sp_to_addr())!;
    cpu.sp--;
    memory.write_byte((Byte) value & 0xFF, cpu.sp_to_addr())!;
    cpu.sp--;
}

macro void Cpu.pop_ps_from_stack(Cpu* cpu, Memory* memory) {
    cpu.ps = cpu.pop_byte_from_stack( memory);
    cpu.unused = 0;
    cpu.b = 0;
}
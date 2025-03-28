module emu6502;
import emulator;
import std::io;

const Uint32 KILO_BYTE = 1024;
const Uint32 MAX_MEM = KILO_BYTE*64;

// Reused Values
// for constant purposes

const Byte CARRY_FLAG         = 0b00000001;
const Byte ZERO_FLAG          = 0b00000010;
const Byte INTERRUPT_DISABLE  = 0b00000100;
const Byte DECIMAL_MODE_FLAG  = 0b00001000;
const Byte BREAK_CMD          = 0b00010000;
const Byte UNUSED_FLAG        = 0b00100000;
const Byte OVERFLOW_FLAG      = 0b01000000;
const Byte NEGATIVE_FLAG      = 0b10000000;

// INSTRUCTIONS
// LOAD OPS

const Byte INS_LDA_IM = 0xA9;   // Cycles: 2
const Byte INS_LDA_ZP = 0xA5;   // Cycles: 3
const Byte INS_LDA_ZPX = 0xB5;  // Cycles: 4
const Byte INS_LDA_ABS = 0xAD;  // Cycles: 4
const Byte INS_LDA_ABSX = 0xBD; // Cycles: 4 (+1 if page crossed)
const Byte INS_LDA_ABSY = 0xB9; // Cycles: 4 (+1 if page crossed)
const Byte INS_LDA_INDX = 0xA1; // Cycles: 6
const Byte INS_LDA_INDY = 0xB2; // Cycles: 5 (+1 if page crossed)

const Byte INS_LDX_IM = 0xA2;   // Cycles: 2
const Byte INS_LDX_ZP = 0xA6;   // Cycles: 3
const Byte INS_LDX_ZPY = 0xB6;  // Cycles: 4
const Byte INS_LDX_ABS = 0xAE;  // Cycles: 4
const Byte INS_LDX_ABSY = 0xBE; // Cycles: 4 (+1 if page crossed)

const Byte INS_LDY_IM = 0xA0;   // Cycles: 2
const Byte INS_LDY_ZP = 0xA4;   // Cycles: 3
const Byte INS_LDY_ZPX = 0xB4;  // Cycles: 4
const Byte INS_LDY_ABS = 0xAC;  // Cycles: 4
const Byte INS_LDY_ABSX = 0xBC; // Cycles: 4 (+1 if page crossed)

// STORE OPS

const Byte INS_STA_ZP = 0x85;   // Cycles: 3
const Byte INS_STA_ZPX = 0x95;  // Cycles: 4
const Byte INS_STA_ABS = 0x8D;  // Cycles: 4
const Byte INS_STA_ABSX = 0x9D; // Cycles: 5
const Byte INS_STA_ABSY = 0x99; // Cycles: 5
const Byte INS_STA_INDX = 0x81; // Cycles: 6
const Byte INS_STA_INDY = 0x91; // Cycles: 6

const Byte INS_STX_ZP = 0x86;   // Cycles: 3
const Byte INS_STX_ZPY = 0x96;  // Cycles: 4
const Byte INS_STX_ABS = 0x8E;  // Cycles: 4

const Byte INS_STY_ZP = 0x84;   // Cycles: 3
const Byte INS_STY_ZPX = 0x94;  // Cycles: 4
const Byte INS_STY_ABS = 0x8C;  // Cycles: 4

//JMP OPS
const Byte INS_JSR = 0x20;      // Cycles: 6
const Byte INS_RTS = 0x60;      // Cycles: 6
const Byte INS_JMP_ABS = 0x4C;  // Cycles: 3
const Byte INS_JMP_IND = 0x6C;  // Cycles: 5

// Register Transfers:
const Byte INS_TAX = 0xAA;      // Cycles: 2
const Byte INS_TAY = 0xA8;      // Cycles: 2
const Byte INS_TXA = 0x8A;      // Cycles: 2
const Byte INS_TYA = 0x98;      // Cycles: 2
// STACK OPS
const Byte INS_TSX = 0xBA;      // Cycles: 2
const Byte INS_TXS = 0x9A;      // Cycles: 2
const Byte INS_PHA = 0x48;      // Cycles: 3
const Byte INS_PHP = 0x08;      // Cycles: 3
const Byte INS_PLA = 0x68;      // Cycles: 4
const Byte INS_PLP = 0x28;      // Cycles: 4

// LOGICAL OPS
// const Byte INS_AND = 0x48;
const Byte INS_AND_IM = 0x29;   // Cycles: 2
const Byte INS_AND_ZP = 0x25;   // Cycles: 3
const Byte INS_AND_ZPX = 0x35;  // Cycles: 4
const Byte INS_AND_ABS = 0x2D;  // Cycles: 4
const Byte INS_AND_ABSX = 0x3D; // Cycles: 4 (+1 if page crossed)
const Byte INS_AND_ABSY = 0x39; // Cycles: 4 (+1 if page crossed)
const Byte INS_AND_INDX = 0x21; // Cycles: 6
const Byte INS_AND_INDY = 0x31; // Cycles: 5 (+1 if page crossed)

// const Byte INS_EOR = 0x08;
const Byte INS_EOR_IM = 0x49;   // Cycles: 2
const Byte INS_EOR_ZP = 0x45;   // Cycles: 3
const Byte INS_EOR_ZPX = 0x55;  // Cycles: 4
const Byte INS_EOR_ABS = 0x4D;  // Cycles: 4
const Byte INS_EOR_ABSX = 0x5D; // Cycles: 4 (+1 if page crossed)
const Byte INS_EOR_ABSY = 0x59; // Cycles: 4 (+1 if page crossed)
const Byte INS_EOR_INDX = 0x41; // Cycles: 6
const Byte INS_EOR_INDY = 0x51; // Cycles: 5 (+1 if page crossed)

// const Byte INS_ORA = 0x68;
const Byte INS_ORA_IM = 0x09;   // Cycles: 2
const Byte INS_ORA_ZP = 0x05;   // Cycles: 3
const Byte INS_ORA_ZPX = 0x15;  // Cycles: 4
const Byte INS_ORA_ABS = 0x0D;  // Cycles: 4
const Byte INS_ORA_ABSX = 0x1D; // Cycles: 4 (+1 if page crossed)
const Byte INS_ORA_ABSY = 019;  // Cycles: 4 (+1 if page crossed)
const Byte INS_ORA_INDX = 0x01; // Cycles: 6
const Byte INS_ORA_INDY = 0x11; // Cycles: 5 (+1 if page crossed)

// const Byte INS_BIT = 0x28;
const Byte INS_BIT_ZP = 0x24;   // Cycles: 3
const Byte INS_BIT_ABS = 0x2C;  // Cycles: 4


// MATH OPS
// Add with carry
const Byte INS_ADC_IM = 0x69;   // Cycles: 2
const Byte INS_ADC_ZP = 0x65;   // Cycles: 3
const Byte INS_ADC_ZPX = 0x75;  // Cycles: 4
const Byte INS_ADC_ABS = 0x6D;  // Cycles: 4
const Byte INS_ADC_ABSX = 0x7D; // Cycles: 4 (+1 if page crossed)
const Byte INS_ADC_ABSY = 0x79; // Cycles: 4 (+1 if page crossed)
const Byte INS_ADC_INDX = 0x61; // Cycles: 6
const Byte INS_ADC_INDY = 0x71; // Cycles: 5 (+1 if page crossed)

// Sub with carry
const Byte INS_SBC_IM =   0xE9; // Cycles: 2
const Byte INS_SBC_ZP =   0xE5; // Cycles: 3
const Byte INS_SBC_ZPX =  0xF5; // Cycles: 4
const Byte INS_SBC_ABS =  0xED; // Cycles: 4
const Byte INS_SBC_ABSX = 0xFD; // Cycles: 4 (+1 page crossed)
const Byte INS_SBC_ABSY = 0xF9; // Cycles: 4 (+1 page crossed)
const Byte INS_SBC_INDX = 0xE1; // Cycles: 6
const Byte INS_SBC_INDY = 0xF1; // Cycles: 5 (+1 page crossed)

// COMPARE OPS
const Byte INS_CMP_IM   = 0xC9; // Cycles: 2
const Byte INS_CMP_ZP   = 0xC5; // Cycles: 3
const Byte INS_CMP_ZPX  = 0xD5; // Cycles: 4
const Byte INS_CMP_ABS  = 0xCD; // Cycles: 4
const Byte INS_CMP_ABSX = 0xDD; // Cycles: 4 (+1 page crossed)
const Byte INS_CMP_ABSY = 0xD9; // Cycles: 4 (+1 page crossed)
const Byte INS_CMP_INDX = 0xC1; // Cycles: 6
const Byte INS_CMP_INDY = 0xD1; // Cycles: 5 (+1 page crossed)

const Byte INS_CPX_IM   = 0xE0; // Cycles: 2
const Byte INS_CPX_ZP   = 0xE4; // Cycles: 3
const Byte INS_CPX_ABS  = 0xEC; // Cycles: 4
const Byte INS_CPY_IM   = 0xC0; // Cycles: 2
const Byte INS_CPY_ZP   = 0xC4; // Cycles: 3
const Byte INS_CPY_ABS  = 0xCC; // Cycles: 4

// INCS AND DECS
const Byte INS_INC_ZP = 0xE6;   // Cycles: 5
const Byte INS_INC_ZPX = 0xF6;  // Cycles: 5
const Byte INS_INC_ABS = 0xEE;  // Cycles: 6
const Byte INS_INC_ABSX = 0xFE; // Cycles: 7

const Byte INS_DEC_ZP = 0xC6;   // Cycles: 5
const Byte INS_DEC_ZPX = 0xD6;  // Cycles: 6
const Byte INS_DEC_ABS = 0xCE;  // Cycles: 6
const Byte INS_DEC_ABSX = 0xDE; // Cycles: 7

const Byte INS_INX = 0xE8;      // Cycles: 2
const Byte INS_DEX = 0xCA;      // Cycles: 2
const Byte INS_INY = 0xC8;      // Cycles: 2
const Byte INS_DEY = 0x88;      // Cycles: 2

// SHIFTS
const Byte INS_ASL     = 0x0A;  // Cycles: 2
const Byte INS_ASL_ZP  = 0x06;  // Cycles: 5
const Byte INS_ASL_ZPX = 0x16;  // Cycles: 6
const Byte INS_ASL_ABS = 0x0E;  // Cycles: 6
const Byte INS_ASL_ABSX=0x1E;   // Cycles: 7

const Byte INS_LSR     = 0x4A;  // Cycles: 2
const Byte INS_LSR_ZP  = 0x46;  // Cycles: 5
const Byte INS_LSR_ZPX = 0x56;  // Cycles: 6
const Byte INS_LSR_ABS = 0x4E;  // Cycles: 6
const Byte INS_LSR_ABSX= 0x5E;  // Cycles: 7

const Byte INS_ROL     = 0x2A;  // Cycles: 2
const Byte INS_ROL_ZP  = 0x26;  // Cycles: 5
const Byte INS_ROL_ZPX = 0x36;  // Cycles: 6
const Byte INS_ROL_ABS = 0x2E;  // Cycles: 6
const Byte INS_ROL_ABSX= 0x3E;  // Cycles: 7

const Byte INS_ROR     = 0x6A;  // Cycles: 2
const Byte INS_ROR_ZP  = 0x66;  // Cycles: 5
const Byte INS_ROR_ZPX = 0x76;  // Cycles: 6
const Byte INS_ROR_ABS = 0x6E;  // Cycles: 6
const Byte INS_ROR_ABSX= 0x7E;  // Cycles: 7

// BRANCHES
const Byte INS_BCC = 0x90;      // Cycles: 2  (+1 if succesful)  (+1 if page crossed) //br if carry == 0   
const Byte INS_BCS = 0xB0;      // Cycles: 2  (+1 if succesful)  (+1 if page crossed) //br if carry == 1   
const Byte INS_BEQ = 0xF0;      // Cycles: 2  (+1 if succesful)  (+1 if page crossed)  //br if zero == 1    
const Byte INS_BMI = 0x30;      // Cycles: 2  (+1 if succesful)  (+1 if page crossed) //br if negative == 1
const Byte INS_BNE = 0xD0;      // Cycles: 2  (+1 if succesful)  (+1 if page crossed) //br if zero == 0    
const Byte INS_BPL = 0x10;      // Cycles: 2  (+1 if succesful)  (+1 if page crossed) //br if negative == 0
const Byte INS_BVC = 0x50;      // Cycles: 2  (+1 if succesful)  (+1 if page crossed) //br if overflow == 0
const Byte INS_BVS = 0x70;      // Cycles: 2  (+1 if succesful)  (+1 if page crossed) //br if overflow == 1

// Clear Status Flags
const Byte INS_CLC = 0x18;      // Cycles: 2 // clear carry       
const Byte INS_CLD = 0xD8;      // Cycles: 2 // clear decimal mode
const Byte INS_CLI = 0x58;      // Cycles: 2 // clear interrupt   
const Byte INS_CLV = 0xB8;      // Cycles: 2 // clear overflow    
const Byte INS_SEC = 0x38;      // Cycles: 2 // set carry         
const Byte INS_SED = 0xF8;      // Cycles: 2 // set decimal mode  
const Byte INS_SEI = 0x78;      // Cycles: 2 // set interrupt     

// NO OPERATION // set interrupt
const Byte INS_NOP = 0xEA;      // Cycles: 2

const Byte INS_BRK = 0x00;      // Cycles: 7
const Byte INS_RTI = 0x40;      // Cycles: 6

const Word INTERRUPT_VECTOR_ADDR =0xFFFE; // For BRK!
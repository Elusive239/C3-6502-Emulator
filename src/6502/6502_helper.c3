module emu6502;
fn int bytes_consumed(Byte instruction) {
    switch(instruction){
        case INS_LDA_IM  : return 2;
        case INS_LDA_ZP  : return 2;
        case INS_LDA_ZPX : return 2;
        case INS_LDA_ABS : return 3;
        case INS_LDA_ABSX: return 3;
        case INS_LDA_ABSY: return 3;
        case INS_LDA_INDX: return 2;
        case INS_LDA_INDY: return 2;

        case INS_LDX_IM  : return 2;
        case INS_LDX_ZP  : return 2;
        case INS_LDX_ZPY : return 2;
        case INS_LDX_ABS : return 3;
        case INS_LDX_ABSY: return 3;

        case INS_LDY_IM  :return 2;
        case INS_LDY_ZP  :return 2;
        case INS_LDY_ZPX :return 2;
        case INS_LDY_ABS :return 3;
        case INS_LDY_ABSX:return 3;

        case INS_STA_ZP  : return 2;
        case INS_STA_ZPX : return 2;
        case INS_STA_ABS : return 3;
        case INS_STA_ABSX: return 3;
        case INS_STA_ABSY: return 3;
        case INS_STA_INDX: return 2;
        case INS_STA_INDY: return 2;

        case INS_STX_ZP  : return 2;
        case INS_STX_ZPY : return 2;
        case INS_STX_ABS : return 3;

        case INS_STY_ZP  : return 2;
        case INS_STY_ZPX : return 2;
        case INS_STY_ABS : return 3;

        case INS_JSR     : return 3;
        case INS_RTS     : return 1;
        case INS_JMP_ABS : return 3;
        case INS_JMP_IND : return 3;

        case INS_TAX     :
        case INS_TAY     :
        case INS_TXA     :
        case INS_TYA     : return 1;

        case INS_TSX     :
        case INS_TXS     :
        case INS_PHA     :
        case INS_PHP     :
        case INS_PLA     :
        case INS_PLP     : return 1;

        case INS_AND_IM  : return 2;
        case INS_AND_ZP  : return 2;
        case INS_AND_ZPX : return 2;
        case INS_AND_ABS : return 3;
        case INS_AND_ABSX: return 3;
        case INS_AND_ABSY: return 3;
        case INS_AND_INDX: return 2;
        case INS_AND_INDY: return 2;

        case INS_EOR_IM  : return 2;
        case INS_EOR_ZP  : return 2;
        case INS_EOR_ZPX : return 2;
        case INS_EOR_ABS : return 3;
        case INS_EOR_ABSX: return 3;
        case INS_EOR_ABSY: return 3;
        case INS_EOR_INDX: return 2;
        case INS_EOR_INDY: return 2;

        case INS_ORA_IM  : return 2;
        case INS_ORA_ZP  : return 2;
        case INS_ORA_ZPX : return 2;
        case INS_ORA_ABS : return 3;
        case INS_ORA_ABSX: return 3;
        case INS_ORA_ABSY: return 3;
        case INS_ORA_INDX: return 2;
        case INS_ORA_INDY: return 2;

        case INS_BIT_ZP  : return 2;
        case INS_BIT_ABS : return 3;

        case INS_ADC_IM  : return 2;
        case INS_ADC_ZP  : return 2;
        case INS_ADC_ZPX : return 2;
        case INS_ADC_ABS : return 3;
        case INS_ADC_ABSX: return 3;
        case INS_ADC_ABSY: return 3;
        case INS_ADC_INDX: return 2;
        case INS_ADC_INDY: return 2;

        case INS_SBC_IM  : return 2;
        case INS_SBC_ZP  : return 2;
        case INS_SBC_ZPX : return 2;
        case INS_SBC_ABS : return 3;
        case INS_SBC_ABSX: return 3;
        case INS_SBC_ABSY: return 3;
        case INS_SBC_INDX: return 2;
        case INS_SBC_INDY: return 2;

        case INS_CMP_IM  : return 2;
        case INS_CMP_ZP  : return 2;
        case INS_CMP_ZPX : return 2;
        case INS_CMP_ABS : return 3;
        case INS_CMP_ABSX: return 3;
        case INS_CMP_ABSY: return 3;
        case INS_CMP_INDX: return 2;
        case INS_CMP_INDY: return 2;

        case INS_CPX_IM  : return 2;
        case INS_CPX_ZP  : return 2;
        case INS_CPX_ABS : return 3;
        case INS_CPY_IM  : return 2;
        case INS_CPY_ZP  : return 2;
        case INS_CPY_ABS : return 3;

        case INS_INC_ZP  : return 2;
        case INS_INC_ZPX : return 2;
        case INS_INC_ABS : return 3;
        case INS_INC_ABSX: return 3;
        case INS_DEC_ZP  : return 2;
        case INS_DEC_ZPX : return 2;
        case INS_DEC_ABS : return 3;
        case INS_DEC_ABSX: return 3;
        case INS_INX     : return 1;
        case INS_DEX     : return 1;
        case INS_INY     : return 1;
        case INS_DEY     : return 1;

        case INS_ASL     : return 1;
        case INS_ASL_ZP  : return 2;
        case INS_ASL_ZPX : return 2;
        case INS_ASL_ABS : return 3;
        case INS_ASL_ABSX: return 3;

        case INS_LSR     : return 1;
        case INS_LSR_ZP  : return 2;
        case INS_LSR_ZPX : return 2;
        case INS_LSR_ABS : return 3;
        case INS_LSR_ABSX: return 3;

        case INS_ROL     : return 1;
        case INS_ROL_ZP  : return 2;
        case INS_ROL_ZPX : return 2;
        case INS_ROL_ABS : return 3;
        case INS_ROL_ABSX: return 3;

        case INS_ROR     : return 1;
        case INS_ROR_ZP  : return 2;
        case INS_ROR_ZPX : return 2;
        case INS_ROR_ABS : return 3;
        case INS_ROR_ABSX: return 3;

        case INS_BCC     :
        case INS_BCS     :
        case INS_BEQ     :
        case INS_BMI     :
        case INS_BNE     :
        case INS_BPL     :
        case INS_BVC     :
        case INS_BVS     : return 2;

        case INS_CLC     :
        case INS_CLD     :
        case INS_CLI     :
        case INS_CLV     :
        case INS_SEC     :
        case INS_SED     :
        case INS_SEI     : return 1;

        case INS_NOP     : return 1;

        case INS_BRK     : return 1;
        case INS_RTI     : return 1;
        default: return -1;
    }
}

fn String instruction_as_string(Byte instruction) {
    switch(instruction){
        case INS_LDA_IM  :
        case INS_LDA_ZP  :
        case INS_LDA_ZPX :
        case INS_LDA_ABS :
        case INS_LDA_ABSX:
        case INS_LDA_ABSY:
        case INS_LDA_INDX:
        case INS_LDA_INDY: 
            return "LDA";

        case INS_LDX_IM  :
        case INS_LDX_ZP  :
        case INS_LDX_ZPY :
        case INS_LDX_ABS :
        case INS_LDX_ABSY: 
            return "LDX";

        case INS_LDY_IM  :
        case INS_LDY_ZP  :
        case INS_LDY_ZPX :
        case INS_LDY_ABS :
        case INS_LDY_ABSX:  
            return "LDY";

        case INS_STA_ZP  : 
        case INS_STA_ZPX : 
        case INS_STA_ABS : 
        case INS_STA_ABSX: 
        case INS_STA_ABSY: 
        case INS_STA_INDX: 
        case INS_STA_INDY: 
            return "STA";

        case INS_STX_ZP  :
        case INS_STX_ZPY :
        case INS_STX_ABS : 
            return "STX";

        case INS_STY_ZP  :
        case INS_STY_ZPX :
        case INS_STY_ABS : 
            return "STX";

        case INS_JSR     : return "JSR";
        case INS_RTS     : return "RTS";
        case INS_JMP_ABS :
        case INS_JMP_IND : 
            return "JMP";

        case INS_TAX     : return "TAX";
        case INS_TAY     : return "TAY";
        case INS_TXA     : return "TXA";
        case INS_TYA     : return "TYA";

        case INS_TSX     : return "TSX";
        case INS_TXS     : return "TXS";
        case INS_PHA     : return "PHA";
        case INS_PHP     : return "PHP";
        case INS_PLA     : return "PLA";
        case INS_PLP     : return "PLP";

        case INS_AND_IM  : 
        case INS_AND_ZP  : 
        case INS_AND_ZPX : 
        case INS_AND_ABS : 
        case INS_AND_ABSX: 
        case INS_AND_ABSY: 
        case INS_AND_INDX: 
        case INS_AND_INDY: 
            return "AND";

        case INS_EOR_IM  : 
        case INS_EOR_ZP  : 
        case INS_EOR_ZPX : 
        case INS_EOR_ABS : 
        case INS_EOR_ABSX: 
        case INS_EOR_ABSY: 
        case INS_EOR_INDX: 
        case INS_EOR_INDY: 
            return "EOR";

        case INS_ORA_IM  :
        case INS_ORA_ZP  :
        case INS_ORA_ZPX :
        case INS_ORA_ABS :
        case INS_ORA_ABSX:
        case INS_ORA_ABSY:
        case INS_ORA_INDX:
        case INS_ORA_INDY: 
            return "ORA";

        case INS_BIT_ZP  :
        case INS_BIT_ABS : 
            return "BIT";

        case INS_ADC_IM  : 
        case INS_ADC_ZP  : 
        case INS_ADC_ZPX : 
        case INS_ADC_ABS : 
        case INS_ADC_ABSX: 
        case INS_ADC_ABSY: 
        case INS_ADC_INDX: 
        case INS_ADC_INDY: 
            return "ADC";

        case INS_SBC_IM  : 
        case INS_SBC_ZP  : 
        case INS_SBC_ZPX : 
        case INS_SBC_ABS : 
        case INS_SBC_ABSX: 
        case INS_SBC_ABSY: 
        case INS_SBC_INDX: 
        case INS_SBC_INDY: 
            return "SBC";

        case INS_CMP_IM  : 
        case INS_CMP_ZP  : 
        case INS_CMP_ZPX : 
        case INS_CMP_ABS : 
        case INS_CMP_ABSX: 
        case INS_CMP_ABSY: 
        case INS_CMP_INDX: 
        case INS_CMP_INDY: 
            return "CMP";

        case INS_CPX_IM  : 
        case INS_CPX_ZP  : 
        case INS_CPX_ABS : 
            return "CPX";
        case INS_CPY_IM  : 
        case INS_CPY_ZP  : 
        case INS_CPY_ABS : 
            return "CPY";

        case INS_INC_ZP  : 
        case INS_INC_ZPX : 
        case INS_INC_ABS : 
        case INS_INC_ABSX: 
            return "INC";

        case INS_DEC_ZP  :
        case INS_DEC_ZPX :
        case INS_DEC_ABS :
        case INS_DEC_ABSX: 
            return "DEC";
        case INS_INX     : 
            return "INX";
        case INS_DEX     : 
            return "DEX";
        case INS_INY     : 
            return "INY";
        case INS_DEY     : 
            return "DEY";

        case INS_ASL     :
        case INS_ASL_ZP  :
        case INS_ASL_ZPX :
        case INS_ASL_ABS :
        case INS_ASL_ABSX: 
            return "ASL";

        case INS_LSR     :
        case INS_LSR_ZP  :
        case INS_LSR_ZPX :
        case INS_LSR_ABS :
        case INS_LSR_ABSX: 
            return "LSR";

        case INS_ROL     :
        case INS_ROL_ZP  :
        case INS_ROL_ZPX :
        case INS_ROL_ABS :
        case INS_ROL_ABSX: 
            return "ROL";

        case INS_ROR     :
        case INS_ROR_ZP  :
        case INS_ROR_ZPX :
        case INS_ROR_ABS :
        case INS_ROR_ABSX: 
            return "ROR";

        case INS_BCC     : return "BCC";
        case INS_BCS     : return "BCS";
        case INS_BEQ     : return "BEQ";
        case INS_BMI     : return "BMI";
        case INS_BNE     : return "BNE";
        case INS_BPL     : return "BPL";
        case INS_BVC     : return "BVC";
        case INS_BVS     : return "BVS";

        case INS_CLC     : return "CLC";
        case INS_CLD     : return "CLD";
        case INS_CLI     : return "CLI";
        case INS_CLV     : return "CLV";
        case INS_SEC     : return "SEC";
        case INS_SED     : return "SED";
        case INS_SEI     : return "SEI";

        case INS_NOP     : return "NOP";

        case INS_BRK     : return "BRK";
        case INS_RTI     : return "RTI";
        default: return "   ";
    }
    //  return "   ";
}

fn AddressMode address_mode(Byte instruction) {
    switch(instruction){
        case 0x00:
        case 0x18:
        case 0xD8:
        case 0x58:
        case 0xB8:
        case 0xCA:
        case 0x88:
        case 0xE8:
        case 0xC8:
        case 0xEA:
        case 0x48:
        case 0x08:
        case 0x68:
        case 0x28:
        case 0x40:
        case 0x60:
        case 0x38:
        case 0xF8:
        case 0x78:
        case 0xAA:
        case 0xA8:
        case 0xBA:
        case 0x8A:
        case 0x9A:
        case 0x98:  return AddressMode.IMPLIED;

        case 0x0A:
        case 0x4A:
        case 0x2A:
        case 0x6A:  return AddressMode.ACCUMULATOR;

        case  0x69: 
        case  0x29: 
        case  0xC9: 
        case  0xE0: 
        case  0xC0: 
        case  0x49: 
        case  0xA9: 
        case  0xA2: 
        case  0xA0: 
        case  0x09: 
        case  0xE9: return AddressMode.IMMEDIATE;

        case 0x6D: 
        case 0x2D: 
        case 0x0E: 
        case 0x2C: 
        case 0xCD: 
        case 0xEC: 
        case 0xCC: 
        case 0xCE: 
        case 0x4D: 
        case 0xEE: 
        case 0x4C: 
        case 0x20: 
        case 0xAD: 
        case 0xAE: 
        case 0xAC: 
        case 0x4E: 
        case 0x0D: 
        case 0x2E: 
        case 0x6E: 
        case 0xED: 
        case 0x8D: 
        case 0x8E: 
        case 0x8C: return AddressMode.ABSOLUTE;

        case 0x7D:
        case 0x3D:
        case 0x1E:
        case 0xDD:
        case 0xDE:
        case 0x5D:
        case 0xFE:
        case 0xBD:
        case 0xBC:
        case 0x5E:
        case 0x1D:
        case 0x3E:
        case 0x7E:
        case 0xFD:
        case 0x9D: return AddressMode.ABSOLUTE_X;

        case 0x79:
        case 0x39:
        case 0xD9:
        case 0x59:
        case 0xB9:
        case 0xBE:
        case 0x19:
        case 0xF9:
        case 0x99:  return AddressMode.ABSOLUTE_Y;

        case 0x6C: return AddressMode.ABSOLUTE_INDIRECT;

        case 0x65:
        case 0x25:
        case 0x06:
        case 0x24:
        case 0xC5:
        case 0xE4:
        case 0xC4:
        case 0xC6:
        case 0x45:
        case 0xE6:
        case 0xA5:
        case 0xA6:
        case 0xA4:
        case 0x46:
        case 0x05:
        case 0x26:
        case 0x66:
        case 0xE5:
        case 0x85:
        case 0x86:
        case 0x84: return AddressMode.ZERO_PAGE;

        case 0x75:
        case 0x35:
        case 0x16:
        case 0xD5:
        case 0xD6:
        case 0x55:
        case 0xF6:
        case 0xB5:
        case 0xB4:
        case 0x56:
        case 0x15:
        case 0x36:
        case 0x76:
        case 0xF5:
        case 0x95:
        case 0x94: return AddressMode.ZERO_PAGE_X;

        case 0xB6:
        case 0x96: return AddressMode.ZERO_PAGE_Y;

        case 0x61:
        case 0x21:
        case 0xC1:
        case 0x41:
        case 0xA1:
        case 0x01:
        case 0xE1:
        case 0x81: return AddressMode.ZERO_PAGE_X_INDIRECT;

        case 0x71:
        case 0x31:
        case 0xD1:
        case 0x51:
        case 0xB1:
        case 0x11:
        case 0xF1:
        case 0x91: return AddressMode.ZERO_PAGE_Y_INDIRECT;

        case 0x90:
        case 0xB0:
        case 0xF0:
        case 0x30:
        case 0xD0:
        case 0x10:
        case 0x50:
        case 0x70: return AddressMode.RELATIVE;
        default: return AddressMode.NONE;
    }
    // return AddressMode.NONE;
}
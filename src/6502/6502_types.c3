module emu6502;
import emulator;
import std::io;

fault Err6502{
    INVALID_INSTRUCTION,
    MEMORY_OUT_OF_BOUNDS
}

def Byte = char;
def SByte = ichar; // Signed Byte
def Word = ushort;
def Uint32 = uint;
def Int32 = int;

distinct Memory = Byte[MAX_MEM];

struct Cpu{
    Word pc;    //program counter
    Byte sp;    //stack pointer

    Byte a;     //registers
    Byte x;
    Byte y;

    bitstruct : Byte @overlap{
        Byte ps : 0..7;
        Byte c : 0..0;     //status flags
        Byte z : 1..1;
        Byte i : 2..2;
        Byte d : 3..3;
        Byte b : 4..4;
        Byte unused : 5..5;
        Byte v : 6..6;
        Byte n : 7..7;

        bool c_bool : 0..0;     //status flags as boolean
        bool z_bool : 1..1;
        bool i_bool : 2..2;
        bool d_bool : 3..3;
        bool b_bool : 4..4;
        bool unused_bool : 5..5;
        bool v_bool : 6..6;
        bool n_bool : 7..7;
    }
}

enum AddressMode : (String value) {
    NONE                    = ""    ,
    IMPLIED                 = "IMPLIED",
    ACCUMULATOR             = "ACCUMULATOR",
    IMMEDIATE               = "IMMEDIATE",
    ABSOLUTE                = "ABSOLUTE",
    ABSOLUTE_X              = "ABSOLUTE X",
    ABSOLUTE_Y              = "ABSOLUTE Y",
    ABSOLUTE_INDIRECT       = "ABSOLUTE  INDIRECT",
    ZERO_PAGE               = "ZERO PAGE",
    ZERO_PAGE_X             = "ZERO PAGE X ",
    ZERO_PAGE_X_INDIRECT    = "ZERO PAGE X-INDIRECT",
    ZERO_PAGE_Y             = "ZERO PAGE Y ",
    ZERO_PAGE_Y_INDIRECT    = "ZERO PAGE Y-INDIRECT",
    RELATIVE                = "RELATIVE",
}

module emulator;
import std::io;
import std::io::file;
import emu6502;

extern fn char getch() @extern("_getch") @if(env::WIN32);
fn char getch() @if(!env::WIN32){
    unreachable("TODO: create or find equivalent for linux");
}


struct Debugger{
    bool app_continue;
    bool do_render;
    Word cursor_y;
    Word cursor_upper;
    Word cursor_lower;

    Cpu copy_cpu;
    Memory copy_mem;
    bool[emu6502::MAX_MEM] renderable;
}

fn void Debugger.run(Debugger* self, Cpu* cpu, Memory* mem) {
    int idx;
    while(idx < mem.len){
        int bytes_consumed = emu6502::bytes_consumed((*mem)[idx]);
        self.renderable[idx] = true;
        idx+=bytes_consumed;
    }

    self.copy_cpu = *cpu;
    self.copy_mem = *mem;
    self.do_render = self.app_continue = true;
    self.cursor_y = cpu.pc;
    self.cursor_lower = self.cursor_y;
    self.cursor_upper = self.cursor_y + TERM_HEIGHT;
    while(self.app_continue){
        if(self.do_render){
            self.render(cpu, mem);
            self.do_render = false;
        }
        if(self.do_render = self.handle_input(cpu, mem)){
            self.update_bounds(TERM_HEIGHT);
            clear_terminal();
        }
    }
    clear_terminal();
}

fn void Debugger.render(Debugger* self, Cpu* cpu, Memory* mem) => @pool() {
    DString output;
    output.temp_init();
    render_status_bar(cpu, &output);
    render_memory(self, cpu, mem, &output);
    output.appendf("\nh + CTRL to open key binds.");
    io::printfn("%s", output);
    output.clear();
}

fn bool Debugger.handle_input(Debugger* self, Cpu* cpu, Memory* mem) {
    char input = getch();
    switch (input) {
        case 'Q' : self.app_continue = false;   // q + SHIFT
        case 'w' : self.inc_cursor(1);          // w
        case 'W' : self.inc_cursor(TERM_HEIGHT);// w + SHIFT
        case 23  : self.inc_cursor(0x1000);     // w + CTRL
        case 's' : self.dec_cursor(1);          // s
        case 'S' : self.dec_cursor(TERM_HEIGHT);// s + SHIFT
        case 19  : self.dec_cursor(0x1000);     // s + CTRL
        case 2   : self.cursor_y = cpu.pc;      // b + CTRL (Goto pc)
        case 'R' :                              // r + SHIFT (reset)
            self.reset_cpu_and_mem(cpu, mem);
        case ' ' :                             // ' ' (Goto pc, Execute 1 instruction)
            return self.step(cpu, mem); 
        case 9   :                             // i + CTRL (Goto: $value)
            self.goto(cpu, mem);
        case 8   :                             // h + CTRL (help)
            do{
                clear_terminal();
                const String MSG = "KEYBINDS: \n"
                "\t-Quit\n"
                "\t\tq + SHIFT -> quit debugging.\n\n"
                "\t-Scroll Up by X \n"
                "\t\tw         -> by 1.\n"
                "\t\tw + SHIFT -> by debugger height.\n"
                "\t\tw + CTRL  -> by 0x1000.\n\n"
                "\t-Scroll Down by X \n"
                "\t\ts         -> by 1.\n"
                "\t\ts + SHIFT -> by debugger height.\n"
                "\t\ts + CTRL  -> by 0x1000.\n\n"
                "\t-Step through code\n"
                "\t\t' '       -> One step. \n\n"
                "\t-Reset\n"
                "\t\tr + SHIFT -> Resets the emulator to its inital state.\n\n"
                "\t-Go to\n"
                "\t\ti + CTRL  -> Go to a provided index. Does nothing if input is not a number.\n\n"
                "\t-Go to pc\n"
                "\t\tb + CTRL  -> Go to the current memory location of the program counter.\n\n"
                "\t-Help\n"
                "\t\th + CTRL  -> Toggle help menu.\n";
                io::print(MSG);
            }while(getch() != 8);
        default  : return false;
    }
    return true;
}

fn bool Debugger.step(&self, Cpu* cpu, Memory* mem) {
    if(catch err = cpu.exec(1, mem)){
        io::printfn("Error: %s during exection", err);
        return false;
    }
    self.cursor_y = cpu.pc;
    return true;     
}

fn void Debugger.goto(&self, Cpu* cpu, Memory* mem) {
    io::printf("go to: ");
    String! tstr = io::readline();
    defer (void) tstr.free();
    if(catch e = tstr) return;
    Word! tint = tstr.to_integer(Word);
    if(catch e = tint) return;
    self.cursor_y = tint;
}

fn void Debugger.reset_cpu_and_mem(&self, Cpu* cpu, Memory* mem) {
    cpu.ps = self.copy_cpu.ps;
    cpu.pc = self.copy_cpu.pc;
    cpu.sp = self.copy_cpu.sp;
    cpu.a = self.copy_cpu.a;
    cpu.x = self.copy_cpu.x;
    cpu.y = self.copy_cpu.y;
    (*mem)[0..] = self.copy_mem[0..];
    self.cursor_y = cpu.pc; 
    self.cursor_lower = self.cursor_y;
    self.cursor_upper = self.cursor_y + TERM_HEIGHT;
}

fn void Debugger.update_bounds(&self, Word terminal_height) {
    if(self.cursor_y > self.cursor_upper) {
        self.cursor_lower = self.cursor_y - (terminal_height );
        self.cursor_upper = self.cursor_y ;
    }
    if(self.cursor_y <= self.cursor_lower) {
        self.cursor_lower = self.cursor_y;
        self.cursor_upper = self.cursor_y + terminal_height;
    }
}

fn void Debugger.inc_cursor(&self , Word amount) {
    self.cursor_y -=amount;    // w + CTRL
    // if(self.cursor_y == (0xFFFF)) self.cursor_y = 0x0000;
}

fn void Debugger.dec_cursor(&self , Word amount){
    self.cursor_y +=amount;    // w + CTRL
    // if(self.cursor_y == 0x0000) self.cursor_y = 0xFFFF;
}

fn void clear_terminal() {
    io::printf("\x1B[2J\x1B[H");
    io::stdout().flush()!!;
}
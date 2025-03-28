# A 6502 emulator written in C3!  

Decided to follow along with [davepoo's](https://github.com/davepoo/6502Emulator) 6502 emulator [series](https://youtube.com/playlist?list=PLLwK93hM93Z13TRzPx9JqTIn33feefl37&si=EhTCDCjILDLfYWhP) in C3 for fun!  

I've also made a little terminal debugger toy thing for it? Currently only builds for Windows, but the actual emulation code should compile just fine regardless...

> [!NOTE]  
> This emulators accuracy is questionable *at best*, play with at your own discretion! I'd say it's close to being as accurate as the original emulator was, go check it out! 

This is all a bit scuffed but it was fun practice! I'm not sure if ill continue from where they left off..

### Debugger:

![alt text](image.png)

Keybindings:  
- Quit  
  - q + SHIFT -> quit debugging.  
- Scroll Up by X   
  - w         -> by 1.  
  - w + SHIFT -> by debugger height.  
  - w + CTRL  -> by 0x1000.  
- Scroll Down by X   
  - s         -> by 1.  
  - s + SHIFT -> by debugger height.  
  - s + CTRL  -> by 0x1000.
- Step through code  
  - `' '`       -> One step.
- Reset  
  - r + SHIFT -> Resets the emulator to its inital state.
- Go to  
  - i + CTRL  -> Go to a provided index. Does nothing if input is not a number.
- Go to pc  
  - b + CTRL  -> Go to the current memory location of the program counter.  
- Help  
  - h + CTRL  -> Toggle help menu. (Shows Keybinds)
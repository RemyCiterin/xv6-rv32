//
// low-level driver routines for 16550a UART.
//

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

// the UART control registers are memory-mapped
// at address UART0. this macro returns the
// address of one of the registers.
#define Reg(reg) ((volatile unsigned char *)(UART0 + reg))

#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{}

// write one output character to the UART.
void
uartputc(int c)
{
  while (0x01 & ~ReadReg(1)) {}
  WriteReg(0, c);
}

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
  if (ReadReg(2) & 0x01) {
    return ReadReg(0);
  } else {
    return -1;
  }
}

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
  while(1){
    int c = uartgetc();
    if(c == -1)
      break;
    consoleintr(c);
  }
}

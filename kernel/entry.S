	# qemu -kernel starts at 0x1000. the instructions
        # there seem to be provided by qemu, as if it
        # were a ROM. the code at 0x1000 jumps to
        # 0x8000000, the _start function here,
        # in machine mode. each CPU starts here.
.section .data
.globl stack0
.section .text
.globl start
.section .text
.globl _entry
_entry:
  la t0, bss_start
  la t1, bss_end
  bgeu t0, t1, .bss_zero_loop_end
.bss_zero_loop:
  sb zero, (t0)
  addi t0, t0, 1
  bltu t0, t1, .bss_zero_loop
.bss_zero_loop_end:
	# set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + (hartid * 4096)
        la sp, stack0
	csrr a1, mhartid
        addi a1, a1, 1
        # a0 = hartid << 12 (= hartid * 4096)
        slli a0, a1, 12
        add sp, sp, a0
	# jump to start() in start.c
        call start
junk:
        j junk

.section .data
.globl RAMDISK
RAMDISK:
  .incbin "fs.img"

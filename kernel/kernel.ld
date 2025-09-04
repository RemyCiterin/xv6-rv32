OUTPUT_ARCH( "riscv" )
ENTRY( _entry )

SECTIONS
{
  /*
   * ensure that entry.S / _entry is at 0x80000000,
   * where qemu's -kernel jumps.
   */
  . = 0x80010000;
  .text :
  {
    *(.text)
    . = ALIGN(0x1000);
    *(trampsec)
  }

  . = ALIGN(0x1000);
  PROVIDE(etext = .);

  /*
   * make sure end is after data and bss.
   */
  .data : {
    *(.data)
  }

  . = ALIGN(4K);
  PROVIDE(bss_start = .);
  .bss : {
    *(.bss)
    *(.sbss*)
     PROVIDE(end = .);
  }
  . = ALIGN(4K);
  PROVIDE(bss_end = .);
}

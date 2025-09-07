

OUTPUT_ARCH(riscv)
ENTRY( main )

SECTIONS
{
  . = 0x00000000;
  . = ALIGN(4K);

  .text : {
    *(.text._start)
    *(.text .text.*)
  }

  . = ALIGN(4K); /* alignment  for page size 4k */
  rodata_start = .;
  .rodata : {
      *(.rodata .rodata.*)
  }

  . = ALIGN(4K); /* alignment  for page size 4k */
  data_start = .;
  .data : {
      *(.data .data.*)
      *(.sdata .sdata.*)
  }

  . = ALIGN(4K); /* alignment  for page size 4k */
  .bss : {
      *(.bss .bss.*)
      *(.sbss .sbss.*)
  }
  . = ALIGN(4);
}

OUTPUT_ARCH( "riscv" )

SECTIONS
{
    . = 0x0000;
    .text : { *(.text) }

    . = 0x8000;
    .data : { *(.data) }

    . = 0x9000;
    _answer = .;

    . = 0xfff0;
    _stack = .;

    . = 0xfffc;
    _sim_end = .;

}

PROG ?= prog0
PRO_PATH ?= ./test/$(PROG)/
SRC_NAME ?= main
ELF_NAME ?= main
SET_NAME ?= setup
CLEAN_FILES ?= BSSLib.lib++ INCA_libs nWaveLog *.history *.log *.conf *.fsdb *.svf *.txt *.key *.X *.. *.d novas.rc

SRC ?= $(PRO_PATH)$(SRC_NAME)
ELF ?= $(PRO_PATH)$(ELF_NAME)
SET ?= $(PRO_PATH)$(SET_NAME)

export CROSS_PREFIX ?= riscv32-unknown-elf-
export RISCV_AS ?= $(CROSS_PREFIX)as
export RISCV_LD ?= $(CROSS_PREFIX)ld
export RISCV_OBJDUMP ?= $(CROSS_PREFIX)objdump -xsd
export RISCV_OBJCOPY ?= $(CROSS_PREFIX)objcopy -O verilog

LDFILE := link.ld
CFLAGS := -march=rv32i -mabi=ilp32
LDFLAGS := -b elf32-littleriscv -T $(LDFILE)


.PHONY: all build_hex build_elf build_object build_dump

all: build_hex build_dump 

# Generate binary file (format: verilog byte by byte) (.elf -> .hex)
build_hex: build_elf
	$(RISCV_OBJCOPY) $(ELF).elf $(ELF).hex

# Generate Executable and Linkable Format (elf) file (.o .o .o ... -> .elf)
# Put setup first, then source file
build_elf: build_object
	$(RISCV_LD) $(LDFLAGS) $(SET).o $(SRC).o -o $(ELF).elf

# Generate object files (*.s -> *.o)
build_object :
	$(RISCV_AS) $(CFLAGS) $(SET).s -o $(SET).o
	$(RISCV_AS) $(CFLAGS) $(SRC).s -o $(SRC).o

# Disassemble for debugging (.elf -> .dump)
build_dump: build_elf
	$(RISCV_OBJDUMP) $(ELF).elf > $(ELF).dump

.PHONY: clean

clean:
	rm -rf $(CLEAN_FILES) $(PRO_PATH)*.elf $(PRO_PATH)*.dump  $(ELF).hex  $(PRO_PATH)*.o $(PRO_PATH)*.mem
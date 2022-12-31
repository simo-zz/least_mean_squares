SRC_DIR = "../../src/"

OUTPUT_DIR = output
TCL_SOURCE = $(wildcard *.tcl)

FPGA_PART = xczu3eg-sfva625-1-i
mode := tcl

VIVADO := vivado
VIVADO_NO_LOG_NO_JOURNAL_OPTION := -nolog -nojournal

MODULE_TO_SYNTH = lms_filter.v
TOP_NAME = $(MODULE_TO_SYNTH:.v=)

SOURCES_V := $(shell find $(SRC_DIR) -name $(MODULE_TO_SYNTH))

.PHONY : all synthesize clean

all: clean synthesize

synthesize:
	@mkdir $(OUTPUT_DIR)
	$(eval VIVADO_CMD = $(VIVADO_NO_LOG_NO_JOURNAL_OPTION) -mode $(mode) -source $(TCL_SOURCE)  -tclargs $(SOURCES_V) $(TOP_NAME) $(FPGA_PART) $(OUTPUT_DIR))
	$(VIVADO) $(VIVADO_CMD)

clean :
	rm -rf *.jou *.log *.pb *.wdb xsim.dir *.vcd
	rm -rf .*.timestamp
	rm -rf .Xil
	rm -fr vivado_pid*.str
	rm -fr $(OUTPUT_DIR)

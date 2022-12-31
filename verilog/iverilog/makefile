IVERILOG := iverilog
VVP = vvp
GTKWAVE := gtkwave

SRC_DIR = "../src/"

VERILOG_SRC = $(shell find $(SRC_DIR) -name '*.v')
TB_FILE = $(filter %_tb.v,$(VERILOG_SRC))
VCD_OUTPUT = $(notdir $(TB_FILE:.v=.vcd))
GTKW_OUTPUT = $(notdir $(TB_FILE:.v=.gtkw))

.PHONY: all compile run clean

all: clean compile run

compile:
	@echo "Compiling verilog"
	@echo "VCD_OUTPUT = $(VCD_OUTPUT)"
	@if [ ! -e $(GTKW_OUTPUT) ]; then \
		touch $(GTKW_OUTPUT); \
	fi
	$(IVERILOG) $(VERILOG_SRC) -o $(VCD_OUTPUT)
	@if [ -e $(VCD_OUTPUT) ]; then \
		$(VVP) $(VCD_OUTPUT); \
	fi


run:
	@echo "Running"
	@echo "GTKW_OUTPUT = $(GTKW_OUTPUT)"
	@if [ -e $(VCD_OUTPUT) ]; then \
		$(GTKWAVE) $(VCD_OUTPUT) $(GTKW_OUTPUT); \
	else  \
		echo "$(VCD_OUTPUT) file not found";\
	fi

clean:
	rm -fr $(VCD_OUTPUT)

SRC_DIR = "../../src/"
VERILOG_SRC_DIR = $(SRC_DIR)"verilog"
SYSTEM_VERILOG_SRC_DIR = $(SRC_DIR)"system_verilog"

SOURCES_V := $(shell find $(VERILOG_SRC_DIR) -name '*.v')
SOURCES_SV := $(shell find $(SYSTEM_VERILOG_SRC_DIR) -name '*.sv')

COMP_OPTS_SV := \
    --incr \
    --relax \

DEFINES_SV :=
COMP_OPTS_VHDL := --incr --relax

TB_TOP := $(basename $(notdir $(shell find $(VERILOG_SRC_DIR) -name '*_tb')))

.PHONY : all simulate elaborate compile waves clean

all: clean simulate elaborate compile waves

simulate : $(TB_TOP)_snapshot.wdb
elaborate : .elab.timestamp
compile : .comp_sv.timestamp .comp_v.timestamp 

waves : $(TB_TOP)_snapshot.wdb
	@echo
	@echo "Opening waves view"
	xsim --nolog --gui $(TB_TOP)_snapshot.wdb 2>/dev/null &

$(TB_TOP)_snapshot.wdb : .elab.timestamp
	@echo
	@echo "Running behavioral simulation"
	xsim --nolog $(TB_TOP)_snapshot -tclbatch xsim_cfg.tcl

.elab.timestamp : .comp_sv.timestamp .comp_v.timestamp 
	@echo
	@echo "Running elaboration"
	xelab --nolog -debug all -top $(TB_TOP) -snapshot $(TB_TOP)_snapshot
	touch .elab.timestamp

ifeq ($(SOURCES_SV),)
.comp_sv.timestamp:
	@echo "No System Verilog files found, skipping"
	touch .comp_sv.timestamp
else
.comp_sv.timestamp: $(SOURCES_SV)
	@echo
	@echo "Compiling System Verilog sources"
	xvlog --nolog --sv $(SV_OPTIONS) $(SV_DEFINES) $(SOURCES_SV)
	touch .comp_sv.timestamp
endif

ifeq ($(SOURCES_V),)
.comp_v.timestamp :
	@echo "No Verilog files found, skipping"
	touch .comp_v.timestamp
else
.comp_v.timestamp : $(SOURCES_V)
	@echo "Compiling Verilog sources"
	xvlog --nolog $(COMP_OPTS_V) $(DEFINES_V) $(SOURCES_V)
	touch .comp_v.timestamp
endif

clean :
	rm -rf *.jou *.log *.pb *.wdb xsim.dir *.vcd
	rm -rf .*.timestamp
	rm -rf .Xil
	rm -fr vivado_pid*.str

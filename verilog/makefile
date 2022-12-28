IVERILOG_SIM_DIR = "iverilog/"
VIVADO_SIM_DIR = "vivado/sim"
VIVADO_SYNTH_DIR = "vivado/synth"

.PHONY: all iverilog_sim vivado_sim vivado_synth clean

all:
	@echo "Please choose \"iverilog\" or \"vivado\" target";

iverilog_sim:
	$(MAKE) -C $(IVERILOG_SIM_DIR)

vivado_sim: 
	$(MAKE) -C $(VIVADO_SIM_DIR)

vivado_synth: 
	$(MAKE) -C $(VIVADO_SYNTH_DIR)

clean:
	$(MAKE) -C $(IVERILOG_SIM_DIR) clean
	$(MAKE) -C $(VIVADO_SIM_DIR) clean
	$(MAKE) -C $(VIVADO_SYNTH_DIR) clean
set vsource [lindex $argv 0]
set top_name [lindex $argv 1]
set fpga_part [lindex $argv 2]
set output_dir [lindex $argv 3]

# xczu3eg-sfva625-1-i
read_verilog ${vsource}
synth_design -top ${top_name} -part ${fpga_part}
write_verilog ${output_dir}/${top_name}.v
report_datasheet -file ${output_dir}/datasheet.txt
report_utilization -file ${output_dir}/utilization.txt
report_timing_summary -file ${output_dir}/timing_summary.txt
start_gui
show_schematic [get_nets]
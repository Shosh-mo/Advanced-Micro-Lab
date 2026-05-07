read_verilog netlist.v
read_liberty /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
link_design LUT 
read_sdc constraints.sdc



set_power_activity -input_ports {in0 in1 in2 in3} -activity 0.2

set_power_activity -input_ports {input_combination[0]} -activity 0.2
set_power_activity -input_ports {input_combination[1]} -activity 0.2
set_power_activity -input_ports {input_combination[2]} -activity 0.2
set_power_activity -input_ports {input_combination[3]} -activity 0.2


set_power_activity -input_ports {f_sel[0] f_sel[1]} -activity 0.01
set_power_activity -input_ports wr_en      -activity 0.01
set_power_activity -input_ports rst        -activity 0.01
set_power_activity -input_ports is_synced  -activity 0.05


set_power_activity -pins [get_pins */CLK] -activity 1.0

report_power > power.rpt
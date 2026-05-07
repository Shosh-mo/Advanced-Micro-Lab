read_verilog netlist.v
read_liberty /home/asiclab/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
link_design LUT 
read_sdc constraints.sdc

report_checks -path_delay max >setup.rpt
report_checks -path_delay min >hold.rpt

report_tns
report_wns
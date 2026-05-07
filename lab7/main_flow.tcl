#read main files
read_lef sky130_fd_sc_hd__nom.tlef
read_lef sky130_fd_sc_hd.lef

read_verilog netlist.v
read_liberty sky130_fd_sc_hd__tt_025C_1v80.lib

read_verilog netlist.v
link_design LUT


read_sdc constraints.sdc

report_checks
#floorplanning

initialize_floorplan -site unithd -utilization 0.4 -core_space 20




clock_tree_synthesis -root_buf sky130_fd_sc_hd__clkbuf_16 -buf_list "sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2"
set_propagated_clock [all_clocks]
estimate_parasitics -placement
report_checks
report_clock_skew

make_tracks

place_pins -hor_layers met3 -ver_layers met4 -random

#PLACEMENT

global_placement -density 0.4
detailed_placement 

# Check and repair
check_placement -verbose
repair_design

# Set wire RC for both signal and clock
set_wire_rc -signal -layer met2
set_wire_rc -clock -layer met3


##tapcells (connects nwells and pwells to gnd and vdd)

tapcell -tapcell_master sky130_fd_sc_hd__tapvpwrvgnd_1 -endcap_master sky130_fd_sc_hd__decap_4

#powergrid
add_global_connection -net VDD -pin_pattern VPWR -power
add_global_connection -net VSS -pin_pattern VGND -ground

set_voltage_domain -name CORE -power VDD -ground VSS

define_pdn_grid -name grid -voltage_domains CORE

add_pdn_stripe -grid grid -layer met1 -width 0.48 -followpins
add_pdn_stripe -grid grid -layer met4 -width 1.6 -pitch 50.0
add_pdn_stripe -grid grid -layer met5 -width 1.6 -pitch 50.0

add_pdn_connect -grid grid -layers {met1 met4}
add_pdn_connect -grid grid -layers {met4 met5}

pdngen
report_clock_skew
#CTS 
#clock_tree_synthesis -root_buf sky130_fd_sc_hd__clkbuf_16 -buf_list "sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2"
#set_propagated_clock [all_clocks]
#estimate_parasitics -placement
#report_checks
#report_clock_skew

#report_clock_latency


#routing
set_routing_layers -signal met1-met5
global_route 
global_route \
  -congestion_iterations 200 \
  -congestion_report_file congestion.rpt \
  -verbose
filler_placement {\
    sky130_fd_sc_hd__fill_1 \
    sky130_fd_sc_hd__fill_2 \
    sky130_fd_sc_hd__fill_4 \
    sky130_fd_sc_hd__fill_8}


detailed_route

detailed_route -output_drc drc.rpt

write_def routed.def
#parastics extraction
extract_parasitics -ext_model_file "rules.openrcx.sky130A.min.calibre"


##outputs
write_def final.def
write_verilog final.v
write_spef final.spef

get_die_area
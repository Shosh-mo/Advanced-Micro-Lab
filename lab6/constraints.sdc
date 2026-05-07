create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay -clock clk -max 2 [get_ports {in0 in1 in2 in3 input_combination[*] wr_en f_sel[*]  is_synced }]
set_input_delay -clock clk -min 0.5 [get_ports {in0 in1 in2 in3 input_combination[*] wr_en f_sel[*]  is_synced }]

set_output_delay -clock clk -max 2 [get_ports {out_ff}]
set_output_delay -clock clk -min 0.5  [get_ports {out_ff}]

set_input_transition 0.2 [all_inputs]

set_clock_uncertainty -setup 0.3 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]

set_load 0.5 [all_outputs]


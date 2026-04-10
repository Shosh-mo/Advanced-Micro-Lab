quit -sim
vdel -all
vlib work
vmap work work

# Compile UVM 1.2
vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src C:/questasim64_2021.1/verilog_src/uvm-1.2/src/uvm_pkg.sv

# Compile RTL
vlog FIFO.v +cover
vlog FF2.v +cover

# Compile SystemVerilog
vlog -sv shared_pkg.sv
vlog -sv FIFO_if_read.sv
vlog -sv FIFO_if_write.sv
vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src pack1_FIFO.sv
vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src agent1_wr.sv
vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src agent2_rd.sv
vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src env.sv
vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src parent_sequencer.svh

vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src parent_sequence.svh

vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src my_test.svh
vlog -sv +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.2/src top.sv


# Simulate with UVM 1.2 
vsim -c -voptargs="+acc" work.top -classdebug -uvmcontrol=all -coverage -sv_lib C:/questasim64_2021.1/uvm-1.2/win64/uvm_dpi

run 0
add wave /top/FIFOifwrite/*
add wave /top/FIFOifread/*

coverage save FIFO.ucdb -onexit
run -all
#quit -f
#vcover report FIFO.ucdb -details -annotate -all -output cov1.txt
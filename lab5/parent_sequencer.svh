import uvm_pkg::*;
`include "uvm_macros.svh"

import pack1_FIFO::*;
import agent1_wr::*;
import agent2_rd::*;

class parent_sequencer extends uvm_sequencer;
    `uvm_component_utils(parent_sequencer)

    function new(string name = "parent_sequencer", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    my_sequencer_wr child_sequencer_wr;
    my_sequencer_rd child_sequencer_rd;
endclass
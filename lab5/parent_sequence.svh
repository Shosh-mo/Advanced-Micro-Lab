import uvm_pkg::*;
`include "uvm_macros.svh"
//`include "parent_sequencer.svh"
import env::*;
import pack1_FIFO::*;

class parent_sequence extends uvm_sequence;
    `uvm_object_utils(parent_sequence)

    parent_sequencer parent_sequencer_inst;

    reset_sequence_wr reset_sequence_wr_inst;
    reset_sequence_rd reset_sequence_rd_inst;

    wr_sequence wr_sequence_inst;
    wr_sequence2 wr_sequence2_inst;

    rd_sequence rd_sequence_inst;
    rd_sequence2 rd_sequence2_inst;

    rd_wr_sequence rd_wr_sequence_inst;
    rd_wr_sequence2 rd_wr_sequence2_inst;

    function new(string name = "parent_sequence");
        super.new(name);
    endfunction

    task pre_body;
        $cast(parent_sequencer_inst,m_sequencer);
        reset_sequence_wr_inst = reset_sequence_wr::type_id::create("reset_sequence_wr_inst");
        reset_sequence_rd_inst = reset_sequence_rd::type_id::create("reset_sequence_rd_inst");

        wr_sequence_inst = wr_sequence::type_id::create("wr_sequence_inst");
        rd_sequence_inst = rd_sequence::type_id::create("rd_sequence_inst");

        wr_sequence2_inst = wr_sequence2::type_id::create("wr_sequence2_inst");
        rd_sequence2_inst = rd_sequence2::type_id::create("rd_sequence2_inst");

        rd_wr_sequence_inst = rd_wr_sequence::type_id::create("rd_wr_sequence_inst");
        rd_wr_sequence2_inst = rd_wr_sequence2::type_id::create("rd_wr_sequence2_inst");     
    endtask

    task body;
    fork begin
        reset_sequence_wr_inst.start(parent_sequencer_inst.child_sequencer_wr);
    end
    begin
        reset_sequence_rd_inst.start(parent_sequencer_inst.child_sequencer_rd);
    end
    join


    fork begin
            wr_sequence_inst.start(parent_sequencer_inst.child_sequencer_wr);
    end
    begin
        wr_sequence2_inst.start(parent_sequencer_inst.child_sequencer_rd);

    end
    join

    fork begin
        rd_sequence_inst.start(parent_sequencer_inst.child_sequencer_rd);
    end
    begin
        rd_sequence2_inst.start(parent_sequencer_inst.child_sequencer_wr);

    end
    join
    
    fork begin
        wr_sequence_inst.start(parent_sequencer_inst.child_sequencer_wr);

    end
    begin
        rd_sequence_inst.start(parent_sequencer_inst.child_sequencer_rd);

    end
    join

    fork begin
        rd_wr_sequence_inst.start(parent_sequencer_inst.child_sequencer_wr);
    end
    begin
        rd_wr_sequence2_inst.start(parent_sequencer_inst.child_sequencer_rd);
    end 
    join

    endtask
endclass
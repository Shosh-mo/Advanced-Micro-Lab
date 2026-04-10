import uvm_pkg::*;
`include "uvm_macros.svh"

import env::*;
import pack1_FIFO::*;
//`include "parent_sequencer.svh" //take care all .svh are in same compilation scope
`include "parent_sequence.svh"

class my_test extends uvm_test;
        `uvm_component_utils(my_test)

        my_env_FIFO my_env_FIFO_inst;

        env_config_FIFO env_config_FIFO_inst;

        virtual FIFO_if_write config_virtual_FIFOwr;
        virtual FIFO_if_read config_virtual_FIFOrd;
  
        parent_sequence parent_sequence_inst;


        function new(string name = "my_test", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            my_env_FIFO_inst = my_env_FIFO::type_id::create("my_env_FIFO_inst",this);

            env_config_FIFO_inst = env_config_FIFO::type_id::create("env_config_FIFO_inst");

            parent_sequence_inst = parent_sequence::type_id::create("parent_sequence_inst"); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            if(!uvm_config_db #(virtual FIFO_if_write)::get(this , "" , "FIFO_if_write" , config_virtual_FIFOwr)) //tests if the "virtual interface" only is retrieved or not
                `uvm_fatal("build_phase" , "Test - unable to get write virtual interface");

            if(!uvm_config_db #(virtual FIFO_if_read)::get(this , "" , "FIFO_if_read" , config_virtual_FIFOrd)) //tests if the "virtual interface" only is retrieved or not
                `uvm_fatal("build_phase" , "Test - unable to get read virtual interface");

            env_config_FIFO_inst.config_vif_wr = config_virtual_FIFOwr;
            env_config_FIFO_inst.config_vif_rd = config_virtual_FIFOrd;
  
            //setting the flags

            env_config_FIFO_inst.is_active = UVM_ACTIVE;
            env_config_FIFO_inst.has_agent_wr = 1;
            env_config_FIFO_inst.has_agent_rd = 1;
            env_config_FIFO_inst.has_scoreboard = 1;
            env_config_FIFO_inst.has_subscriber = 1; 
            

            //send the config object to env
            uvm_config_db #(env_config_FIFO)::set(this,"my_env_FIFO_inst","env_config_FIFO",env_config_FIFO_inst);


           // uvm_resource_db #(env_config)::set("my_env_mem_inst","env_config",env_config_inst);
            $display("inside my_test build phase");
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
            $display("inside my_test run phase");
            parent_sequence_inst.start(my_env_FIFO_inst.parent_sequencer_inst);
            phase.drop_objection(this);
        endtask
    endclass
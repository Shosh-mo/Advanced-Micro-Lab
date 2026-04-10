package agent1_wr;
import pack1_FIFO::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

import shared_pkg::*;

    class my_driver_wr extends uvm_driver #(my_sequence_item_FIFO);
        `uvm_component_utils(my_driver_wr)

        virtual FIFO_if_write config_vif_wr;

        my_sequence_item_FIFO seq_item_inst;

        driver_mon_config_FIFOwr driver_mon_config_inst;
        function new(string name = "my_driver_wr", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);


            if(!uvm_config_db #(driver_mon_config_FIFOwr)::get(this , "" , "drv_mon_config_FIFOwr" , driver_mon_config_inst))
                `uvm_fatal("build_phase" , "driver wr - unable to get the config");

            config_vif_wr = driver_mon_config_inst.config_vif_wr;
            $display("inside my_driver_wr build phase");
        endfunction


        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("inside my_driver_wr run phase");
            forever begin
                seq_item_inst = my_sequence_item_FIFO::type_id::create("seq_item_inst");

                seq_item_port.get_next_item(seq_item_inst);

                config_vif_wr.rst = seq_item_inst.rst; 
                config_vif_wr.wr_en = seq_item_inst.wr_en; 
                config_vif_wr.data_in = seq_item_inst.data_in; 

                @(negedge config_vif_wr.clk_w);

                seq_item_port.item_done();

            end
        endtask
    endclass

    //monitor class
    class my_monitor_wr extends uvm_monitor;
        `uvm_component_utils(my_monitor_wr)
        virtual FIFO_if_write config_virtual_if;
        my_sequence_item_FIFO my_sequence_item_FIFO_inst;
        uvm_analysis_port #(my_sequence_item_FIFO) my_analysis_port;

        driver_mon_config_FIFOwr driver_mon_config_inst;

        function new(string name = "my_monitor_wr", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            my_analysis_port = new("my_analysis_port",this);
            $display("inside my_monitor_wr build phase");


            if(!uvm_config_db #(driver_mon_config_FIFOwr)::get(this , "" , "drv_mon_config_FIFOwr" , driver_mon_config_inst))
                `uvm_fatal("build_phase" , "monitor wr - unable to get the config");

            config_virtual_if = driver_mon_config_inst.config_vif_wr;

        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("inside my_monitor_wr run phase");

            forever begin
                @(negedge config_virtual_if.clk_w);

                my_sequence_item_FIFO_inst = my_sequence_item_FIFO::type_id::create("my_sequence_item_FIFO_inst", this);
                
                // Sample DUT output
                my_sequence_item_FIFO_inst.full = config_virtual_if.full;

                // Also capture input values
                my_sequence_item_FIFO_inst.rst = config_virtual_if.rst;
                my_sequence_item_FIFO_inst.wr_en = config_virtual_if.wr_en;
                my_sequence_item_FIFO_inst.data_in = config_virtual_if.data_in;

                // Send to scoreboard and subscriber
                my_analysis_port.write(my_sequence_item_FIFO_inst);
            end
        endtask
    endclass

    //sequencer class
    class my_sequencer_wr extends uvm_sequencer #(my_sequence_item_FIFO);
        `uvm_component_utils(my_sequencer_wr)

        function new(string name = "my_sequencer_wr", uvm_component parent = null);
            super.new(name,parent);
        endfunction
    endclass

    //agent class
    class my_agent_wr extends uvm_agent;
        `uvm_component_utils(my_agent_wr)
        uvm_analysis_port #(my_sequence_item_FIFO) agent_port;

        agent_wr_config_FIFO agent_config_inst;
        driver_mon_config_FIFOwr driver_mon_config_inst;

        my_sequencer_wr my_sequencer_wr_inst;
        my_driver_wr my_driver_wr_inst;
        my_monitor_wr my_monitor_wr_inst;

        virtual FIFO_if_write config_vif_wr;

        function new(string name = "my_agent_wr", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent_port = new("agent_port",this);

            if(!uvm_config_db #(agent_wr_config_FIFO)::get(this , "" , "agent_wr_config_FIFO" , agent_config_inst))
                `uvm_fatal("build_phase" , "agent - unable to get the config");

            if(agent_config_inst.is_active == UVM_ACTIVE) begin
                my_sequencer_wr_inst = my_sequencer_wr::type_id::create("my_sequencer_wr_inst",this);
                my_driver_wr_inst = my_driver_wr::type_id::create("my_driver_wr_inst",this);
            end
          
            my_monitor_wr_inst = my_monitor_wr::type_id::create("my_monitor_wr_inst",this);

            driver_mon_config_inst = driver_mon_config_FIFOwr::type_id::create("driver_mon_config_inst");
            
            driver_mon_config_inst.config_vif_wr = agent_config_inst.config_vif_wr;
        
            uvm_config_db #(driver_mon_config_FIFOwr)::set(this,"*","drv_mon_config_FIFOwr",driver_mon_config_inst); //the driver and monitor should get it

            $display("inside my_agent_wr build phase");
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            my_monitor_wr_inst.my_analysis_port.connect(agent_port);

            if(agent_config_inst.is_active == UVM_ACTIVE)
                my_driver_wr_inst.seq_item_port.connect(my_sequencer_wr_inst.seq_item_export);
                
            $display("inside my_agent_wr connect phase");
        endfunction
    endclass

endpackage

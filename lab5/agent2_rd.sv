package agent2_rd;
import pack1_FIFO::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

import shared_pkg::*;

    class my_driver_rd extends uvm_driver #(my_sequence_item_FIFO);
        `uvm_component_utils(my_driver_rd)

        virtual FIFO_if_read config_vif_rd;

        my_sequence_item_FIFO seq_item_inst;

        driver_mon_config_FIFOrd driver_mon_config_inst;
        function new(string name = "my_driver_rd", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);


            if(!uvm_config_db #(driver_mon_config_FIFOrd)::get(this , "" , "drv_mon_config_FIFOrd" , driver_mon_config_inst))
                `uvm_fatal("build_phase" , "driver rd - unable to get the config");

            config_vif_rd = driver_mon_config_inst.config_vif_rd;
            $display("inside my_driver_rd build phase");
        endfunction


        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("inside my_driver_rd run phase");
            forever begin
                seq_item_inst = my_sequence_item_FIFO::type_id::create("seq_item_inst");

                seq_item_port.get_next_item(seq_item_inst);

                config_vif_rd.rd_en = seq_item_inst.rd_en; 

                @(negedge config_vif_rd.clk_r);

                seq_item_port.item_done();

            end
        endtask
    endclass

    //monitor class
    class my_monitor_rd extends uvm_monitor;
        `uvm_component_utils(my_monitor_rd)
        virtual FIFO_if_read config_virtual_if;
        my_sequence_item_FIFO my_sequence_item_FIFO_inst;

        uvm_analysis_port #(my_sequence_item_FIFO) my_analysis_port;

        driver_mon_config_FIFOrd driver_mon_config_inst;

        function new(string name = "my_monitor_rd", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            my_analysis_port = new("my_analysis_port",this);
            $display("inside my_monitor_rd build phase");


            if(!uvm_config_db #(driver_mon_config_FIFOrd)::get(this , "" , "drv_mon_config_FIFOrd" , driver_mon_config_inst))
                `uvm_fatal("build_phase" , "monitor rd - unable to get the config");

            config_virtual_if = driver_mon_config_inst.config_vif_rd;

        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("inside my_monitor_rd run phase");

            forever begin
                @(negedge config_virtual_if.clk_r);

                my_sequence_item_FIFO_inst = my_sequence_item_FIFO::type_id::create("my_sequence_item_FIFO_inst");
                
                // Sample DUT output
                my_sequence_item_FIFO_inst.empty = config_virtual_if.empty;
                my_sequence_item_FIFO_inst.data_out = config_virtual_if.data_out;

                // Also capture input values
                my_sequence_item_FIFO_inst.rd_en = config_virtual_if.rd_en;

                // Send to scoreboard and subscriber
                my_analysis_port.write(my_sequence_item_FIFO_inst);
            end
        endtask
    endclass

    //sequencer class
    class my_sequencer_rd extends uvm_sequencer #(my_sequence_item_FIFO);
        `uvm_component_utils(my_sequencer_rd)

        function new(string name = "my_sequencer_rd", uvm_component parent = null);
            super.new(name,parent);
        endfunction
    endclass

    //agent class
    class my_agent_rd extends uvm_agent;
        `uvm_component_utils(my_agent_rd)
        uvm_analysis_port #(my_sequence_item_FIFO) agent_port;

        agent_rd_config_FIFO agent_config_inst;
        driver_mon_config_FIFOrd driver_mon_config_inst;

        my_sequencer_rd my_sequencer_rd_inst;
        my_driver_rd my_driver_rd_inst;
        my_monitor_rd my_monitor_rd_inst;

        virtual FIFO_if_read config_vif_rd;

        function new(string name = "my_agent_rd", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent_port = new("agent_port",this);

            if(!uvm_config_db #(agent_rd_config_FIFO)::get(this , "" , "agent_rd_config_FIFO" , agent_config_inst))
                `uvm_fatal("build_phase" , "agent rd - unable to get the config");

            if(agent_config_inst.is_active == UVM_ACTIVE) begin
                my_sequencer_rd_inst = my_sequencer_rd::type_id::create("my_sequencer_rd_inst",this);
                my_driver_rd_inst = my_driver_rd::type_id::create("my_driver_rd_inst",this);
            end
          
            my_monitor_rd_inst = my_monitor_rd::type_id::create("my_monitor_rd_inst",this);

            driver_mon_config_inst = driver_mon_config_FIFOrd::type_id::create("driver_mon_config_inst");
            
            driver_mon_config_inst.config_vif_rd = agent_config_inst.config_vif_rd;
        
            uvm_config_db #(driver_mon_config_FIFOrd)::set(this,"*","drv_mon_config_FIFOrd",driver_mon_config_inst); //the driver and monitor should get it

            $display("inside my_agent_rd build phase");
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            my_monitor_rd_inst.my_analysis_port.connect(agent_port);

            if(agent_config_inst.is_active == UVM_ACTIVE)
                my_driver_rd_inst.seq_item_port.connect(my_sequencer_rd_inst.seq_item_export);
                
            $display("inside my_agent_rd connect phase");
        endfunction
    endclass

endpackage

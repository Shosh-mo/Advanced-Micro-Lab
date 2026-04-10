package env;
import pack1_FIFO::*;
import agent1_wr::*;
import agent2_rd::*;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "parent_sequencer.svh"
import shared_pkg::*;

class my_env_FIFO extends uvm_env;
        `uvm_component_utils(my_env_FIFO)

        env_config_FIFO env_config_inst;

        agent_wr_config_FIFO agent_wr_config_inst;
        agent_rd_config_FIFO agent_rd_config_inst;

        my_agent_wr my_agent_wr_inst;
        my_agent_rd my_agent_rd_inst;

        my_scoreboard_FIFO my_scoreboard_FIFO_inst;
        my_subscriber_FIFO my_subscriber_FIFO_inst;

        parent_sequencer parent_sequencer_inst;

        virtual FIFO_if_write env_vif_wr;
        virtual FIFO_if_read env_vif_rd;
  

        function new(string name = "my_env_FIFO", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if(!uvm_config_db #(env_config_FIFO)::get(this , "" , "env_config_FIFO" , env_config_inst)) //tests if the config is retrieved or not
                `uvm_fatal("build_phase" , "env - unable to get the config");

            parent_sequencer_inst = parent_sequencer::type_id::create("parent_sequencer_inst",this);

//building the write agent
            if(env_config_inst.has_agent_wr) begin
                my_agent_wr_inst = my_agent_wr::type_id::create("my_agent_wr_inst",this);

                agent_wr_config_inst = agent_wr_config_FIFO::type_id::create("agent_wr_config_inst");
                agent_wr_config_inst.config_vif_wr = env_config_inst.config_vif_wr;

                agent_wr_config_inst.is_active = env_config_inst.is_active;

                uvm_config_db #(agent_wr_config_FIFO)::set(this,"my_agent_wr_inst","agent_wr_config_FIFO",agent_wr_config_inst);
            end

//building the read agent
            if(env_config_inst.has_agent_rd) begin
                my_agent_rd_inst = my_agent_rd::type_id::create("my_agent_rd_inst",this);

                agent_rd_config_inst = agent_rd_config_FIFO::type_id::create("agent_rd_config_inst");
                agent_rd_config_inst.config_vif_rd = env_config_inst.config_vif_rd;

                agent_rd_config_inst.is_active = env_config_inst.is_active;

                uvm_config_db #(agent_rd_config_FIFO)::set(this,"my_agent_rd_inst","agent_rd_config_FIFO",agent_rd_config_inst);
            end

            if(env_config_inst.has_scoreboard)
                my_scoreboard_FIFO_inst = my_scoreboard_FIFO::type_id::create("my_scoreboard_FIFO_inst",this);

            if(env_config_inst.has_subscriber)
                my_subscriber_FIFO_inst = my_subscriber_FIFO::type_id::create("my_subscriber_FIFO_inst",this);

            $display("inside my_env_FIFO build phase");
        endfunction

        function void connect_phase(uvm_phase phase);

            parent_sequencer_inst.child_sequencer_wr = my_agent_wr_inst.my_sequencer_wr_inst;
            parent_sequencer_inst.child_sequencer_rd = my_agent_rd_inst.my_sequencer_rd_inst;


            if(env_config_inst.has_scoreboard)begin
                my_agent_wr_inst.agent_port.connect(my_scoreboard_FIFO_inst.monwr_imp);
                my_agent_rd_inst.agent_port.connect(my_scoreboard_FIFO_inst.monrd_imp);

            end

            if(env_config_inst.has_subscriber) begin
                my_agent_wr_inst.agent_port.connect(my_subscriber_FIFO_inst.monwr_imp);
                my_agent_rd_inst.agent_port.connect(my_subscriber_FIFO_inst.monrd_imp);

            end
        endfunction
    endclass
endpackage

package pack1_FIFO;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import shared_pkg::*;

//scoreboard takes signals from 2 monitors
    `uvm_analysis_imp_decl(_monwr)
    `uvm_analysis_imp_decl(_monrd)

//the env config 
 class env_config_FIFO extends uvm_object;
    `uvm_object_utils(env_config_FIFO)

    virtual FIFO_if_write config_vif_wr;
    virtual FIFO_if_read config_vif_rd;
  
    uvm_active_passive_enum is_active;

    bit has_scoreboard;
    bit has_subscriber;
    bit has_agent_wr;
    bit has_agent_rd;

    function new (string name = "env_config_FIFO");
        super.new(name);
    endfunction
    endclass

//agent_wr config
    class agent_wr_config_FIFO extends uvm_object;
    `uvm_object_utils(agent_wr_config_FIFO)

    virtual FIFO_if_write config_vif_wr;  

    uvm_active_passive_enum is_active;

    function new (string name = "agent_wr_config_FIFO");
        super.new(name);
    endfunction
    endclass


//agent_rd config 
    class agent_rd_config_FIFO extends uvm_object;
    `uvm_object_utils(agent_rd_config_FIFO)

    virtual FIFO_if_read config_vif_rd;  

    uvm_active_passive_enum is_active;

    function new (string name = "agent_rd_config_FIFO");
        super.new(name);
    endfunction
    endclass

//wr driver mon config
    class driver_mon_config_FIFOwr extends uvm_object;
    `uvm_object_utils(driver_mon_config_FIFOwr)
    
    virtual FIFO_if_write config_vif_wr;

    function new (string name = "driver_mon_config_FIFOwr");
        super.new(name);
    endfunction
    endclass

//rd driver mon config
    class driver_mon_config_FIFOrd extends uvm_object;
    `uvm_object_utils(driver_mon_config_FIFOrd)
    
    virtual FIFO_if_read config_vif_rd;

    function new (string name = "driver_mon_config_FIFOrd");
        super.new(name);
    endfunction
    endclass


    //sequence item class
    class my_sequence_item_FIFO extends uvm_sequence_item; 
        `uvm_object_utils(my_sequence_item_FIFO)

        rand logic rst;
        rand logic wr_en , rd_en;
        rand logic [fifo_width - 1 : 0] data_in;

        logic [fifo_width - 1 : 0] data_out;
        logic full , empty;

        function new(string name = "my_sequence_item_FIFO");
            super.new(name);
        endfunction

        //constraints
        constraint FIFO_const1 {
        rst dist {1:=90 , 0:=10};
        wr_en dist {1:=50 , 0:=50};
        rd_en dist {1:=50 , 0:=50};
        }

        constraint FIFO_const2{
            data_in dist {max_data_value:/35 , min_data_value:/5 , [1 : max_data_value-1]:/60};
        }

        function void print();

        endfunction

    endclass

    //sequence class rst seq wr
    class reset_sequence_wr extends uvm_sequence #(my_sequence_item_FIFO); //parametrized or not?
        `uvm_object_utils(reset_sequence_wr)
        my_sequence_item_FIFO seq_item;
        function new(string name = "reset_sequence_wr");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item_FIFO::type_id::create("seq_item"); //momkn da ytktb fe task l body 3ade
        endtask

        task body;
        int i;
        //reset
        for(i=0;i<4;i=i+1) begin
            start_item(seq_item);
            
            seq_item.rst = 0;
            seq_item.data_in = 0;
            seq_item.wr_en = 0; 


            finish_item(seq_item);
        end
        endtask
    endclass


    //sequence class rst seq rd
    class reset_sequence_rd extends uvm_sequence #(my_sequence_item_FIFO); //parametrized or not?
        `uvm_object_utils(reset_sequence_rd)
        my_sequence_item_FIFO seq_item;
        function new(string name = "reset_sequence_rd");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item_FIFO::type_id::create("seq_item"); //momkn da ytktb fe task l body 3ade
        endtask

        task body;
        int i;
        //reset
        for(i=0;i<4;i=i+1) begin
            start_item(seq_item);
            
            seq_item.rd_en = 0; 

            finish_item(seq_item);
        end

        endtask
    endclass
    //wr_sequence write until full
    class wr_sequence extends uvm_sequence #(my_sequence_item_FIFO);
        `uvm_object_utils(wr_sequence)
        my_sequence_item_FIFO seq_item;
        function new(string name = "wr_sequence");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item_FIFO::type_id::create("seq_item"); //momkn da ytktb fe task l body 3ade
        endtask

        task body;
        int i;
        
            for(i=0;i<16;i=i+1) begin
                start_item(seq_item);

                seq_item.randomize()with {
                                            wr_en == 1;
                                            rd_en == 0;
                                            rst == 1;};

                finish_item(seq_item);
            end
        endtask
    endclass

    //wr_sequence2 write until full
    class wr_sequence2 extends uvm_sequence #(my_sequence_item_FIFO);
        `uvm_object_utils(wr_sequence2)
        my_sequence_item_FIFO seq_item;
        function new(string name = "wr_sequence2");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item_FIFO::type_id::create("seq_item"); //momkn da ytktb fe task l body 3ade
        endtask

        task body;
        int i;
        
            for(i=0;i<16;i=i+1) begin
                start_item(seq_item);

                seq_item.randomize()with {
                                            wr_en == 1;
                                            rd_en == 0;
                                            rst == 1;};

                finish_item(seq_item);
            end
        endtask
    endclass



        //rd sequence read until empty
    class rd_sequence extends uvm_sequence #(my_sequence_item_FIFO);
        `uvm_object_utils(rd_sequence)
        my_sequence_item_FIFO seq_item;
        function new(string name = "rd_sequence");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item_FIFO::type_id::create("seq_item"); //momkn da ytktb fe task l body 3ade
        endtask

        task body;
        int i;
        
            for(i=0;i<16;i=i+1) begin
                start_item(seq_item);
                
                seq_item.randomize()with {
                                            wr_en == 0;
                                            rd_en == 1;
                                            rst == 1;};

                finish_item(seq_item);
            end
            
        endtask
    endclass

        //rd sequence2 read until empty
class rd_sequence2 extends uvm_sequence #(my_sequence_item_FIFO);
        `uvm_object_utils(rd_sequence2)
        my_sequence_item_FIFO seq_item;
        function new(string name = "rd_sequence2");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item_FIFO::type_id::create("seq_item"); //momkn da ytktb fe task l body 3ade
        endtask

        task body;
        int i;
        
            for(i=0;i<16;i=i+1) begin
                start_item(seq_item);
                
                seq_item.randomize()with {
                                            wr_en == 0;
                                            rd_en == 1;
                                            rst == 1;};

                finish_item(seq_item);
            end
            
        endtask
    endclass



    // read and write
    class rd_wr_sequence extends uvm_sequence #(my_sequence_item_FIFO);
        `uvm_object_utils(rd_wr_sequence)
        my_sequence_item_FIFO seq_item;
        function new(string name = "rd_wr_sequence");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item_FIFO::type_id::create("seq_item"); //momkn da ytktb fe task l body 3ade
        endtask

        task body;
        int i;
        
            for(i=0;i<150;i=i+1) begin
                start_item(seq_item);
                
                seq_item.randomize();

                finish_item(seq_item);
            end
            
        endtask
    endclass

    // read and write
    class rd_wr_sequence2 extends uvm_sequence #(my_sequence_item_FIFO);
        `uvm_object_utils(rd_wr_sequence2)
        my_sequence_item_FIFO seq_item;
        function new(string name = "rd_wr_sequence2");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item_FIFO::type_id::create("seq_item"); //momkn da ytktb fe task l body 3ade
        endtask

        task body;
        int i;
        
            for(i=0;i<75;i=i+1) begin
                start_item(seq_item);
                
                seq_item.randomize();

                finish_item(seq_item);
            end
            
        endtask
    endclass

    //scoreboard
    class my_scoreboard_FIFO extends uvm_scoreboard;
        `uvm_component_utils(my_scoreboard_FIFO)

        my_sequence_item_FIFO my_sequence_item_FIFO_inst2;
        uvm_analysis_imp_monwr #(my_sequence_item_FIFO, my_scoreboard_FIFO) monwr_imp; 
        uvm_analysis_imp_monrd #(my_sequence_item_FIFO, my_scoreboard_FIFO) monrd_imp; 

        logic [fifo_width - 1 : 0] data_out_ref;
        bit full_ref , empty_ref;
        int error_count , correct_count;
        bit [fifo_width-1 : 0] q[$];   //a queue to mimic the fifo

        function new(string name = "my_scoreboard_FIFO", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monwr_imp = new("monwr_imp",this);
            monrd_imp = new("monrd_imp",this);

            $display("inside my_scoreboard_FIFO build phase");
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            $display("inside my_scoreboard_FIFO connect phase");
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("inside my_scoreboard_FIFO run phase");
        endtask


logic prev_full;
logic prev_empty;

function void write_monwr(my_sequence_item_FIFO tr);
    if (tr == null) begin
        `uvm_error("SCOREBOARD", "Received null transaction from wr mon")
        return;
    end

    if (!tr.rst) begin
        q.delete();
        prev_full  = 0;
        prev_empty = 1;
        data_out_ref = 0;
        return;
    end

    if (tr.wr_en && !prev_full) begin
        q.push_back(tr.data_in);
        //$display("SB-WR pushed %0d, q size=%0d, time=%0t", $signed(tr.data_in), q.size(), $time);
       // $display(q);
    end

    prev_full = tr.full;
endfunction


function void write_monrd(my_sequence_item_FIFO tm);
    if (tm == null) begin
        `uvm_error("SCOREBOARD", "Received null transaction from rd mon")
        return;
    end

    if (tm.rd_en && !prev_empty) begin
        if (q.size() > 0) begin
            data_out_ref = q.pop_front();
            //$display("SB-RD popped %0d, q size=%0d, time=%0t",$signed(data_out_ref), q.size(), $time);
            //$display(q);
            if (tm.data_out !== data_out_ref) begin
                `uvm_error("SCOREBOARD", $sformatf(
                    "MISMATCH: expected=%0d actual=%0d",$signed(data_out_ref), $signed(tm.data_out)))
                error_count++;
            end else begin
                //$display("SB-RD MATCH: data_out=%0d time=%0t",$signed(tm.data_out), $time);
                correct_count++;
            end
        end
    end

    prev_empty = tm.empty;
endfunction


    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("number of correct is %0d" , correct_count);
        $display("number of errors is %0d" , error_count);
    endfunction
    endclass



    //subscriber class
    class my_subscriber_FIFO extends uvm_subscriber #(my_sequence_item_FIFO);
        `uvm_component_utils(my_subscriber_FIFO)
        uvm_analysis_imp_monwr #(my_sequence_item_FIFO,my_subscriber_FIFO) monwr_imp; 
        uvm_analysis_imp_monrd #(my_sequence_item_FIFO,my_subscriber_FIFO) monrd_imp; 

        my_sequence_item_FIFO my_sequence_item_FIFO_inst;

        logic rst;
        logic wr_en , rd_en, full , empty;
        logic [fifo_width - 1 : 0] data_in;
        logic [fifo_width - 1 : 0] data_out;

        covergroup cov_grp;

            rst_cp: coverpoint rst;
            wr_en_cp: coverpoint wr_en;
            rd_en_cp: coverpoint rd_en;
            full_cp: coverpoint full;
            empty_cp: coverpoint empty;

            data_in_cp: coverpoint data_in{
                bins max_i = {max_data_value};
                bins min_i = {min_data_value};
                bins others_i = {[min_data_value+1 : max_data_value-1]};
            }

            data_out_cp: coverpoint data_out{
                bins max_o = {max_data_value};
                bins min_o = {min_data_value};
                bins others_o = {[min_data_value+1 : max_data_value-1]};
            }

            cross wr_en_cp , rd_en_cp;

            cross wr_en_cp , full_cp;
            cross rd_en_cp , empty_cp;

            cross full_cp, empty_cp {
                illegal_bins full_empty = binsof(full_cp) intersect {1} &&binsof(empty_cp) intersect {1};}

        endgroup

        function new(string name = "my_subscriber_FIFO", uvm_component parent = null);
            super.new(name,parent);
                        cov_grp = new();

        endfunction


        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monwr_imp = new("monwr_imp",this);
            monrd_imp = new("monrd_imp",this);

            $display("inside my_subscriber_FIFO build phase");
        endfunction

        function void write(my_sequence_item_FIFO t);//to override all virtual methods of abstract superclass uvm_subscriber

        endfunction

        function void write_monwr (my_sequence_item_FIFO t); 
            rst = t.rst;
            wr_en = t.wr_en;
            data_in = t.data_in;
            full = t.full;
            cov_grp.sample();
        endfunction

        function void write_monrd (my_sequence_item_FIFO tm); 
            rd_en = tm.rd_en;
            data_out = tm.data_out;
            empty = tm.empty;
            cov_grp.sample();
        endfunction
    endclass

endpackage



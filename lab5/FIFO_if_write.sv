import shared_pkg::*;

interface FIFO_if_write(clk_w);
    input clk_w;

    logic [fifo_width -1 : 0] data_in; 
    logic wr_en;
    logic rst;
    logic full;


endinterface
import shared_pkg::*;
interface FIFO_if_read(clk_r);
    input clk_r;
    logic rd_en;
    logic empty;
    logic [fifo_width -1 : 0] data_out;
endinterface
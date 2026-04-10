package shared_pkg;

parameter fifo_width = 8;
parameter fifo_depth = 16;

parameter int unsigned max_data_value = (2**fifo_width - 1);
parameter int unsigned min_data_value = 0;

endpackage
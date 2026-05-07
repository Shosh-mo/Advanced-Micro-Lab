module d_mux(f_out , is_synced , out , ff_out);
input f_out , is_synced;
output out , ff_out;

assign out = (~is_synced) ? f_out : 1'b0;
assign ff_out  = (is_synced) ? f_out : 1'b0;

endmodule